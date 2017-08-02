//
//  EventPublishViewController.m
//  XiaoYa
//
//  Created by commet on 2017/8/1.
//  Copyright © 2017年 commet. All rights reserved.
//事件发布

#import "EventPublishViewController.h"
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

@property (nonatomic , strong) NSDate *currentDate;//当前日期
@property (nonatomic , strong) NSDate *lastSelectedDate;//上一次选择的日期
@property (nonatomic , strong) NSDate *firstDateOfTerm;//传入本学期第一天的日期
@property (nonatomic , strong) NSMutableArray *sectionArray;//选择节数数组
@property (nonatomic , strong) NSDate *originDate;//记录一点进来时初始的日期
@property (nonatomic , strong) NSMutableArray *originArr;//初始节数数组
@end

@implementation EventPublishViewController
{
    CGFloat weekWidth;//“第几周”label宽度
    CGFloat cellWidth;//“日期”btn高度、宽度
    CGFloat datePickerWidth;//日期选择器宽度
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self viewsSetting];
}

#pragma mark textfield
//点击空白处收回键盘
-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer{
    [self.view endEditing:YES];
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
    UIView *bg = [[UIView alloc] init];
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
    //监听
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(descChange:) name:UITextFieldTextDidChangeNotification object:_eventDescription];
    
    UIImageView *pen = [[UIImageView alloc] init];
    pen.image = [UIImage imageNamed:@"pencil"];
    [bg addSubview:pen];
    [pen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bg);
        make.right.equalTo(_eventDescription.mas_left).offset(-24 * scaleToWidth);
    }];
    //顶部底部两条灰线
    UIView *line1 = [[UIView alloc]init];
    line1.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [bg addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenWidth, 0.5));
        make.top.centerX.equalTo(bg);
    }];
    UIView *line2 = [[UIView alloc]init];
    line2.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [bg addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenWidth, 0.5));
        make.bottom.centerX.equalTo(bg);
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
        NSString *subTimeStr = [self appendSectionStringWithArray:self.sectionArray];
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
    AppDelegate *app = (AppDelegate *)[[UIApplication  sharedApplication] delegate];
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
    UIView *bg = [[UIView alloc]init];
    bg.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bg];
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenWidth, 120));
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.eventTimeView.mas_bottom).offset(20);
    }];
    
    //截止时间
    UIButton *replyDL = [[UIButton alloc]init];
    _replyDL = replyDL;
    _replyDL.backgroundColor = [UIColor whiteColor];
    [bg addSubview:_replyDL];
    [_replyDL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.equalTo(bg);
        make.size.mas_equalTo(CGSizeMake(500*scaleToWidth, 40));
    }];
    UIImageView *clock = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"钟"]];
    [bg addSubview:clock];
    [clock mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_replyDL.mas_left).offset(-12);
        make.bottom.equalTo(_replyDL);
    }];
    UIView *horLine = [[UIView alloc]init];
    horLine.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [bg addSubview:horLine];
    [horLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(500*scaleToWidth ,0.5));
        make.bottom.centerX.equalTo(_replyDL);
    }];
    UIImageView *arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow"]];
    [bg addSubview:arrow];
    [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_replyDL.mas_right);
        make.bottom.equalTo(_replyDL);
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
    [bg addSubview:_commentfield];
    [_commentfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bg);
        make.top.equalTo(_replyDL.mas_bottom).offset(20);
        make.size.mas_equalTo(CGSizeMake(500 * scaleToWidth, 32));
    }];
    _commentfield.tag = 101;
    _commentfield.delegate = self;

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(descChange:) name:UITextFieldTextDidChangeNotification object:_commentfield];
    
    UIImageView *comment = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"edit"]];
    [bg addSubview:comment];
    [comment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_commentfield.mas_left).offset(-12);
        make.centerY.equalTo(_commentfield);
    }];
    
    //顶部底部两条灰线
    UIView *line1 = [[UIView alloc]init];
    line1.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [bg addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenWidth, 0.5));
        make.top.centerX.equalTo(bg);
    }];
    UIView *line2 = [[UIView alloc]init];
    line2.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [bg addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenWidth, 0.5));
        make.bottom.centerX.equalTo(bg);
    }];
}

- (UIView *)coverLayerInit{
    UIView *coverLayer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    coverLayer.backgroundColor = [UIColor colorWithRed:88/255.0 green:88/255.0  blue:88/255.0  alpha:0.5];
    return coverLayer;
}

//拼接节数字符串
- (NSString* )appendSectionStringWithArray:(NSMutableArray<NSString*>*)sectionArray{
    NSMutableArray *tempArray = [sectionArray mutableCopy];
    for (int i = 0; i < tempArray.count ; i ++) {
        if ([tempArray[i] intValue] == 0) {
            tempArray[i] = @"早间";
        }else if ([tempArray[i] intValue] == 5){
            tempArray[i] = @"午间";
        }else if([tempArray[i] intValue] > 5 && [tempArray[i] intValue] < 14){
            tempArray[i] = [NSString stringWithFormat:@"%d",[tempArray[i] intValue] - 1];
        }
        else if ([tempArray[i] intValue] == 14){
            tempArray[i] = @"晚间";
        }
    }
    NSMutableString *str = [NSMutableString stringWithFormat:@"%@",tempArray[0]];
    if (sectionArray.count != 1) {
        for (int i = 1; i < sectionArray.count; i++) {
            [str appendFormat:@"、%@",tempArray[i]];
        }
    }
    return str;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}
@end
