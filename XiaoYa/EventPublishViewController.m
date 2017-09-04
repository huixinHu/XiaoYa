//
//  EventPublishViewController.m
//  XiaoYa
//
//  Created by commet on 2017/8/1.
//  Copyright © 2017年 commet. All rights reserved.
//事件发布

#import "EventPublishViewController.h"
#import "CommentViewController.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "Masonry.h"
#import "DateUtils.h"
#import "NSDate+Calendar.h"
#import "DatePicker.h"
#import "MonthPicker.h"
#import "SectionSelect.h"
#import "HXTextField.h"
#import "businessviewcell.h"
#import "MutipleChoiceView.h"
#import "BgView.h"

#define scaleToWidth [UIApplication sharedApplication].keyWindow.bounds.size.width/750.0
#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define kScreenHeight [UIApplication sharedApplication].keyWindow.bounds.size.height

@interface EventPublishViewController () <UITextFieldDelegate ,DatePickerDelegate ,MonthPickerDelegate ,SectionSelectDelegate>
@property (nonatomic ,weak) HXTextField *eventDescription;
@property (nonatomic ,weak) businessviewcell *eventTimeView;
@property (nonatomic ,weak) UIView *coverLayer;
@property (nonatomic ,weak) DatePicker *datePicker;
@property (nonatomic ,weak) SectionSelect *selectSection;
@property (nonatomic ,weak) UIButton *replyDL;
@property (nonatomic ,weak) HXTextField *commentfield;
@property (nonatomic ,weak) MutipleChoiceView *dlRemindView;

@property (nonatomic , strong) NSDate *currentDate;//当前日期
@property (nonatomic , strong) NSDate *lastSelectedDate;//上一次选择的日期
@property (nonatomic , strong) NSDate *firstDateOfTerm;//传入本学期第一天的日期
@property (nonatomic , strong) NSMutableArray *sectionArray;//选择节数数组
@property (nonatomic , strong) NSDate *originDate;//记录一点进来时初始的日期
@property (nonatomic , strong) NSMutableArray *originArr;//初始节数数组
@property (nonatomic ,copy) NSString *commentInfo;
@property (nonatomic , strong) NSArray *remindItem;
@property (nonatomic , strong) NSArray *remindArray;
@end

@implementation EventPublishViewController
{
    CGFloat weekWidth;//“第几周”label宽度
    CGFloat cellWidth;//“日期”btn高度、宽度
    CGFloat datePickerWidth;//日期选择器宽度
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentDate =  [NSDate date];
    self.remindArray = [NSArray array];//暂时测试
    [self viewsSetting];
}

- (void)cancel{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)confirm{
    
}

//导航栏右按钮要在描述和时间都有才能点击
- (void)rightBarBtnCanBeSelect{
//    UIViewController *vc = self.view.superview.viewController;
//    if (_busDescription.text.length > 0 && self.sectionArray.count > 0) {
//        vc.navigationItem.rightBarButtonItem.enabled = YES;//设置导航栏右按钮可以点击
//        self.navigationItem.rightBarButtonItem.enabled = YES;
//    }else{
//        vc.navigationItem.rightBarButtonItem.enabled = NO;
//        self.navigationItem.rightBarButtonItem.enabled = NO;
//    }
}

#pragma mark textfield
//点击空白处收回键盘
-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer{
    [self.view endEditing:YES];
}

- (void)textFiledDidChange:(UITextField *)textField{
    [self rightBarBtnCanBeSelect];
    if ([Utils indexOfCharacter:textField.text] != -1) {
        textField.text = [textField.text substringToIndex:[Utils indexOfCharacter:textField.text]];//输入字数超过了就截断
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField.tag == 101) {
        __weak typeof(self) ws = self;
        CommentViewController *commentVC = [[CommentViewController alloc] initWithTextStr:self.commentInfo successBlock:^(NSString * _Nonnull text) {
            ws.commentInfo = text;
            NSString *tempStr;
            if (text.length > 20) {
                tempStr = [[text substringToIndex:20] stringByAppendingString:@"..."];
            }else{
                tempStr = text;
            }
            ws.commentfield.text = tempStr;
        }];
        [self.navigationController pushViewController:commentVC animated:YES];
        return NO;
    }else{
        return YES;
    }
}

#pragma mark ui相关
//截止日期提醒
- (void)remindSetting{
    [self.view endEditing:YES];
    
    UIView *coverLayer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    coverLayer.backgroundColor = [UIColor colorWithRed:88/255.0 green:88/255.0  blue:88/255.0  alpha:0.5];
    _coverLayer = coverLayer;
    AppDelegate *app = (AppDelegate *)[[UIApplication  sharedApplication] delegate];
    [app.window addSubview:_coverLayer];
    
    __weak typeof(self) ws = self;
    MutipleChoiceView *dlRemindView =
    [[MutipleChoiceView alloc]initWithItems:self.remindItem
                              selectedIndex:self.remindArray
                                  viewWidth:265
                                 cellHeight:40
                     confirmCancelBtnHeight:40
                               confirmBlock:^(NSMutableArray * _Nullable selectIndexs) {
                                   if (selectIndexs.count == 0) {
                                       [selectIndexs addObject:@"0"];//默认是“当事件发生时”
                                   }
                                   [Utils sortArrayFromMinToMax:selectIndexs];
                                   //拼接字符串
                                   NSString *str = [Utils appendRemindStringWithArray:selectIndexs itemsArray:ws.remindItem];
                                   [ws.replyDL setTitle:str forState:UIControlStateNormal];
                                   ws.remindArray = [selectIndexs mutableCopy];
                                   [ws.coverLayer removeFromSuperview];
                               }
                                cancelBlock:^{
                                    [ws.coverLayer removeFromSuperview];
                                }
                            selectCellBlock:^(UITableView * _Nonnull tableView, NSMutableArray * _Nullable selectIndexs, NSIndexPath * _Nullable indexPath) {
                                [selectIndexs addObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:indexPath.row]]];
                            }];
    _dlRemindView = dlRemindView;
    CGPoint center =  _dlRemindView.center;
    center.x = self.view.frame.size.width/2;
    center.y = self.view.frame.size.height/2;
    _dlRemindView.center = center;
    [_coverLayer addSubview:_dlRemindView];
}

#pragma mark viewsSetting
- (void)viewsSetting{
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[Utils colorWithHexString:@"#333333"],NSFontAttributeName:[UIFont systemFontOfSize:17]};
    self.navigationItem.title = @"发布信息";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"confirm"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(confirm)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"cancel"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    self.view.backgroundColor = [Utils colorWithHexString:@"#F0F0F6"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //点击空白处收回键盘
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    [self.view addGestureRecognizer:singleTap];
    
    [self eventDescSetting];
    [self eventTimeViewSetting];
    [self commentAndReplyDL];
}

//描述
- (void)eventDescSetting{
    BgView *bg = [[BgView alloc] init];
    bg.backgroundColor = [Utils colorWithHexString:@"#FFFFFF"];
    [self.view addSubview:bg];
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.top.width.centerX.equalTo(self.view);
    }];
    
    //文本框
    HXTextField *eventDescription = [[HXTextField alloc] init];
    //边框
    _eventDescription = eventDescription;
    _eventDescription.layer.borderColor = [[Utils colorWithHexString:@"#d9d9d9"]CGColor];
    _eventDescription.layer.borderWidth = 0.5f;
    _eventDescription.layer.cornerRadius = 2.0f;
    UIView *lv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 1)];
    [_eventDescription appearanceWithTextColor:[Utils colorWithHexString:@"#333333"] textFontSize:12.0 placeHolderColor:[Utils colorWithHexString:@"#d9d9d9"] placeHolderFontSize:12.0 placeHolderText:@"请描述你的事务" leftView:lv];
//    _busDescription.text = self.busModel.desc;
    [bg addSubview:_eventDescription];
    [_eventDescription mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(bg);
        make.size.mas_equalTo(CGSizeMake(500 * scaleToWidth, 32));
    }];
    _eventDescription.tag = 100;
    _eventDescription.delegate = self;
    [_eventDescription addTarget:self action:@selector(textFiledDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    UIImageView *pen = [[UIImageView alloc] init];
    pen.image = [UIImage imageNamed:@"pencil"];
    [bg addSubview:pen];
    [pen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bg);
        make.right.equalTo(_eventDescription.mas_left).offset(-24 * scaleToWidth);
    }];
}

//时间选择板块
- (void)eventTimeViewSetting{
    NSArray *iconarray = @[@"日历"];
    businessviewcell *eventTimeView = [[businessviewcell alloc]initWithFrame:CGRectZero andNSArray:iconarray];
    _eventTimeView = eventTimeView;
    [self.view addSubview:_eventTimeView];
    [_eventTimeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.centerX.equalTo(self.view);
        make.height.mas_equalTo(120);
        make.top.equalTo(self.view).offset(60);
    }];
    
    [_eventTimeView.button1 addTarget:self action:@selector(dateSelected) forControlEvents:UIControlEventTouchUpInside];
    [_eventTimeView.button2 addTarget:self action:@selector(sectionSelected) forControlEvents:UIControlEventTouchUpInside];
    [self bsTVBtnSetting:self.currentDate];
    if (self.sectionArray.count > 0) {
        NSString *subTimeStr = [Utils appendSectionStringWithArray:self.sectionArray];
        [self.eventTimeView.button2 setTitle:[NSString stringWithFormat:@"第%@节",subTimeStr] forState:UIControlStateNormal];
        [self.eventTimeView.button2 setTitleColor:[Utils colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    }else{
        [self.eventTimeView.button2 setTitle:@"选择时间" forState:UIControlStateNormal];
        [self.eventTimeView.button2 setTitleColor:[Utils colorWithHexString:@"#d9d9d9"] forState:UIControlStateNormal];
    }
}

//日期选择
- (void)dateSelected{
    [self.view endEditing:YES];
    
    UIView *coverLayer = [self coverLayerInit];
    self.coverLayer = coverLayer;
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [app.window addSubview:_coverLayer];
    
    //生成自定义日期选择器
    weekWidth = 50;
    cellWidth = 38;
    
    datePickerWidth = weekWidth +cellWidth *7 +5;//5边界预留
    int weekRow = [DateUtils rowNumber:self.currentDate];//日历该有多少行
    CGFloat datePickerHeight = cellWidth * (weekRow+1) + (76 + 178)/2 + 10;//+1:显示周几的一行，76：两个btn高度，178：顶部年月高度 10:确认取消上的预留位
    DatePicker * picker = [[DatePicker alloc]initWithFrame:CGRectMake(0, 64, datePickerWidth, datePickerHeight) date:self.currentDate firstDateOfTerm:self.firstDateOfTerm];
    CGPoint center =  picker.center;
    center.x = self.view.frame.size.width/2;
    center.y = self.view.frame.size.height/2;
    picker.center = center;
    _datePicker = picker;
    [_coverLayer addSubview:_datePicker];
    _datePicker.delegate = self;
    
    self.lastSelectedDate = self.currentDate;
}

//时间段（节）选择
- (void)sectionSelected{
    [self.view endEditing:YES];
    
    UIView *coverLayer = [self coverLayerInit];
    self.coverLayer = coverLayer;
    AppDelegate *app = (AppDelegate *)[[UIApplication  sharedApplication] delegate];
    [app.window addSubview:_coverLayer];
    
    CGFloat width = 650 / 750.0 * kScreenWidth;
    CGFloat height = (178 + 76)/2 + 245;
    SectionSelect *selectSection = [[SectionSelect alloc]initWithFrame:CGRectMake(0, 0, width, height) sectionArr:self.sectionArray selectedDate:self.currentDate originIndexs:self.originArr originDate:self.originDate termFirstDate:self.firstDateOfTerm];
    CGPoint center =  selectSection.center;
    center.x = self.view.frame.size.width/2;
    center.y = self.view.frame.size.height/2;
    selectSection.center = center;
    _selectSection = selectSection;
    [_coverLayer addSubview:_selectSection];
    _selectSection.delegate = self;
}

//_businessTime_view.button1按钮文本设置
- (void)bsTVBtnSetting:(NSDate *) selectedDate{
    //确定这一天是周几
    NSString * dayStr = [selectedDate dayOfCHNWeek];
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *curDateComp = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:selectedDate];
    NSInteger month = curDateComp.month;
    NSInteger day = curDateComp.day;
    NSInteger dateDistance = [DateUtils dateDistanceFromDate:selectedDate toDate:self.firstDateOfTerm];
    NSInteger week = dateDistance / 7 + 1;
    if (week < 1 || week > 24){
        [_eventTimeView.button1 setTitle:[NSString stringWithFormat:@"第 周 周%@ %@月%@日",dayStr,[NSNumber numberWithInteger:month],[NSNumber numberWithInteger:day]] forState:UIControlStateNormal];
    }else{
        [_eventTimeView.button1 setTitle:[NSString stringWithFormat:@"第%@周 周%@ %@月%@日",[NSNumber numberWithInteger:week],dayStr,[NSNumber numberWithInteger:month],[NSNumber numberWithInteger:day]] forState:UIControlStateNormal];
    }
}

//截止回复时间和备注
- (void)commentAndReplyDL{
    BgView *bg = [[BgView alloc]init];
    bg.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bg];
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenWidth, 40));
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.eventTimeView.mas_bottom).offset(20);
    }];
    
    //截止时间
    UIButton *replyDL = [[UIButton alloc]init];
    _replyDL = replyDL;
    _replyDL.backgroundColor = [UIColor whiteColor];
    _replyDL.titleLabel.font = [UIFont systemFontOfSize:14.0];
    NSString *str = [Utils appendRemindStringWithArray:self.remindArray itemsArray:self.remindItem];
    [_replyDL setTitle:str forState:UIControlStateNormal];
    [_replyDL setTitleColor:[Utils colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    [_replyDL addTarget:self action:@selector(remindSetting) forControlEvents:UIControlEventTouchUpInside];
    [bg addSubview:_replyDL];
    [_replyDL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(bg);
        make.size.mas_equalTo(CGSizeMake(500*scaleToWidth, 36));
    }];
    UIImageView *clock = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"钟"]];
    [bg addSubview:clock];
    [clock mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_replyDL.mas_left).offset(-12);
        make.centerY.equalTo(bg);
    }];
    
    BgView *bg2 = [[BgView alloc] init];
    bg2.backgroundColor = [UIColor whiteColor];
    [self.view  addSubview:bg2];
    [bg2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(bg.mas_bottom).offset(20);
        make.centerX.equalTo(self.view);
    }];
    //备注
    HXTextField *commentfield = [[HXTextField alloc] init];
    //边框
    _commentfield = commentfield;
    _commentfield.layer.borderColor = [[Utils colorWithHexString:@"#d9d9d9"]CGColor];
    _commentfield.layer.borderWidth = 0.5f;
    _commentfield.layer.cornerRadius = 2.0f;
    UIView *lv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 1)];
    [_commentfield appearanceWithTextColor:[Utils colorWithHexString:@"#333333"] textFontSize:12.0 placeHolderColor:[Utils colorWithHexString:@"#d9d9d9"] placeHolderFontSize:12.0 placeHolderText:@"备注" leftView:lv];
    [bg2 addSubview:_commentfield];
    [_commentfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bg2);
        make.top.equalTo(bg2).offset(4);
        make.size.mas_equalTo(CGSizeMake(500 * scaleToWidth, 32));
    }];
    _commentfield.tag = 101;
    _commentfield.delegate = self;
    
    UIImageView *comment = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edit"]];
    [bg2 addSubview:comment];
    [comment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_commentfield.mas_left).offset(-12);
        make.centerY.equalTo(_commentfield);
    }];
}

- (UIView *)coverLayerInit{
    UIView *coverLayer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    coverLayer.backgroundColor = [UIColor colorWithRed:88/255.0 green:88/255.0  blue:88/255.0  alpha:0.5];
    return coverLayer;
}

#pragma mark DatePickerDelegate
- (void)datePicker:(DatePicker *)datePicker createMonthPickerWithDate:(NSDate *)currentDate{
    MonthPicker *monthPicker = [[MonthPicker alloc]initWithFrame:CGRectMake(0, 0, 265, 322) date:currentDate];
    [_coverLayer addSubview:monthPicker];
    CGPoint center =  monthPicker.center;
    center.x = self.view.frame.size.width/2;
    center.y = self.view.frame.size.height/2;
    monthPicker.center = center;
    monthPicker.delegate = self;
    self.datePicker.hidden = YES;//先隐藏，如果monthpicker里面选了“取消”就让它再显示出来
}

//日历日期选择点击了确认
- (void)datePicker:(DatePicker *)datePicker selectedDate:(NSDate *)selectedDate{
    [_coverLayer removeFromSuperview];//移除遮罩
    self.currentDate = selectedDate;//下次就会默认选中上次的日期
    [self bsTVBtnSetting:selectedDate];
}

- (void)datePickerCancelAction:(DatePicker *)datePicker{
    [_coverLayer removeFromSuperview];//移除遮罩
}

#pragma mark MonthPickerDelegate
- (void)monthPickerCancelAction:(MonthPicker *)monthPicker{
    self.datePicker.hidden = NO;
}

- (void)monthPickerConfirmAction:(MonthPicker *)monthPicker date:(NSDate *)currentDate{
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *Comp1 = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:currentDate];
    NSDateComponents *Comp2 = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self.lastSelectedDate];
    if (Comp1.year == Comp2.year && Comp1.month == Comp2.month) {
        self.datePicker.hidden = NO;
        return;
    }
    
    self.lastSelectedDate = currentDate;
    
    [self.datePicker removeFromSuperview];
    int weekRow = [DateUtils rowNumber:currentDate];//日历该有多少行
    CGFloat datePickerHeight = cellWidth * (weekRow+1) + (76 + 178)/2 + 10;//76：两个btn高度，178：顶部年月高度
    DatePicker * picker = [[DatePicker alloc]initWithFrame:CGRectMake(0, 64, datePickerWidth, datePickerHeight) date:currentDate firstDateOfTerm:self.firstDateOfTerm];
    CGPoint center =  picker.center;
    center.x = self.view.frame.size.width/2;
    center.y = self.view.frame.size.height/2;
    picker.center = center;
    _datePicker = picker;
    [_coverLayer addSubview:_datePicker];
    _datePicker.delegate = self;
}

#pragma mark SectionSelectDelegate
//取消操作
- (void)SectionSelectCancelAction:(SectionSelect *)sectionSelector{
    [_coverLayer removeFromSuperview];//移除遮罩
}

//确认操作
- (void)SectionSelectComfirmAction:(SectionSelect *)sectionSelector sectionArr:(NSMutableArray *)sectionArray {
    [_coverLayer removeFromSuperview];
    NSInteger count = sectionArray.count;
    if (count != 0) {
        [Utils sortArrayFromMinToMax:sectionArray];
        //拼接字符串
        NSString *str = [Utils appendSectionStringWithArray:sectionArray];
        [self.eventTimeView.button2 setTitle:[NSString stringWithFormat:@"第%@节",str] forState:UIControlStateNormal];
        [self.eventTimeView.button2 setTitleColor:[Utils colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        self.sectionArray = [sectionArray mutableCopy];
        
        //分割连续段
//        [self.sections removeAllObjects];
//        self.sections = [[Utils subSectionArraysFromArray:sectionArray] mutableCopy];
    }else{
        self.sectionArray = [sectionArray mutableCopy];
        [self.eventTimeView.button2 setTitle:@"选择时间" forState:UIControlStateNormal];
        [self.eventTimeView.button2 setTitleColor:[Utils colorWithHexString:@"#d9d9d9"] forState:UIControlStateNormal];
    }
    [self rightBarBtnCanBeSelect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}
#pragma mark lazy
- (NSArray *)remindItem{
    if (_remindItem == nil) {
        _remindItem = @[@"当事件发生时",@"事件开始前12小时",@"事件开始前24小时",@"事件开始前36小时",@"事件开始前48小时",@"事件开始前一周",@"事件开始前一个月"];
    }
    return _remindItem;
}
@end
