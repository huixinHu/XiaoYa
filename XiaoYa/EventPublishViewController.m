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
#import "HXNotifyConfig.h"
#import "DateUtils.h"
#import "NSDate+Calendar.h"
#import "UIAlertController+Appearance.h"
#import "DatePicker.h"
#import "MonthPicker.h"
#import "SectionSelect.h"
#import "HXTextField.h"
#import "businessviewcell.h"
#import "SingleChoiceView.h"
#import "BgView.h"
#import "GroupInfoModel.h"
#import "HXSocketBusinessManager.h"
#import "HXDBManager.h"
#import "MBProgressHUD.h"

#define scaleToWidth [UIApplication sharedApplication].keyWindow.bounds.size.width/750.0
#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define kScreenHeight [UIApplication sharedApplication].keyWindow.bounds.size.height

@interface EventPublishViewController () <UITextFieldDelegate ,MonthPickerDelegate ,SectionSelectDelegate>
@property (nonatomic ,weak) HXTextField *eventDescription;
@property (nonatomic ,weak) businessviewcell *eventTimeView;
@property (nonatomic ,weak) UIView *coverLayer;
@property (nonatomic ,weak) DatePicker *datePicker;
@property (nonatomic ,weak) SectionSelect *selectSection;
@property (nonatomic ,weak) UIButton *replyDL;
@property (nonatomic ,weak) HXTextField *commentfield;
@property (nonatomic ,weak) SingleChoiceView *dlRemindView;
@property (nonatomic ,weak) MBProgressHUD *hud;

@property (nonatomic , strong) NSDate *currentDate;//当前日期
@property (nonatomic , strong) NSDate *lastSelectedDate;//上一次选择的日期
@property (nonatomic , strong) NSDate *firstDateOfTerm;//传入本学期第一天的日期
@property (nonatomic , strong) NSMutableArray *sectionArray;//选择节数数组
@property (nonatomic , strong) NSDate *originDate;//记录一点进来时初始的日期
@property (nonatomic , strong) NSMutableArray *originArr;//初始节数数组
@property (nonatomic , copy) NSString *commentInfo;
@property (nonatomic , strong) NSArray *dlItem;//截止回复时间内容项
@property (nonatomic , assign) NSInteger dlIndex;//截止回复时间 所选项
@property (nonatomic , strong) GroupInfoModel *infoModel;
@property (nonatomic , strong) publishCompBlock compBlock;
@property (nonatomic , copy) NSString *groupid;
@property (nonatomic , strong) HXDBManager *hxdb;
@end

@implementation EventPublishViewController
{
    CGFloat weekWidth;//“第几周”label宽度
    CGFloat cellWidth;//“日期”btn高度、宽度
    CGFloat datePickerWidth;//日期选择器宽度
}

- (instancetype)initWithInfoModel:(GroupInfoModel *)model publishCompBlock:(publishCompBlock)block{
    if (self = [super init]) {
        self.infoModel = [model copy];
        self.compBlock = block;
        self.groupid = model.groupId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        //事件时间
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"yyyyMMdd"];
        self.currentDate =  [df dateFromString:self.infoModel.eventDate];
        //学期第一天
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.firstDateOfTerm = appDelegate.firstDateOfTerm;
        //节数数组
        self.sectionArray = [self.infoModel.eventSection mutableCopy];
        self.originDate = self.currentDate;
        self.originArr = [self.sectionArray mutableCopy];
        self.commentInfo = [self.infoModel.comment copy];
        self.dlIndex = self.infoModel.deadlineIndex;
    }
    [self viewsSetting];
}

- (void)cancel{
    [self.view endEditing:YES];
    __weak typeof(self) weakself = self;
    void (^otherBlock)(UIAlertAction *action) = ^(UIAlertAction *action){
        [weakself.navigationController popViewControllerAnimated:YES];
    };
    NSArray *otherBlocks = @[otherBlock];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认退出？" message:@"一旦退出，编辑将不会保存" preferredStyle:UIAlertControllerStyleAlert cancelTitle:@"取消" cancelBlock:nil otherTitles:@[@"确定"] otherBlocks:otherBlocks];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)confirm{
    [self.view endEditing:YES];
    __weak typeof(self) ws = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __strong typeof(ws) ss = ws;
        NSDateFormatter *dfm = [[NSDateFormatter alloc]init];
        
        NSInteger dateDistance = [DateUtils dateDistanceFromDate:ss.currentDate toDate:ss.firstDateOfTerm];
        NSString *week = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:dateDistance / 7]];//这里从0开始算第一周。但超过24周要怎么算呢？
        NSString *dayOfWeek = [NSString stringWithFormat:@"%d",([ss.currentDate dayOfWeek] - 2) % 7];//从0开始算周一
        [dfm setDateFormat:@"yyyy-MM-dd"];
        NSString *eventDate = [dfm stringFromDate:ss.currentDate];
        [Utils sortArrayFromMinToMax:ss.sectionArray];
        NSMutableString *sectionStr = [NSMutableString string];
        [ss.sectionArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx != ss.sectionArray.count - 1) {
                [sectionStr appendFormat:@"%@,",obj];
            } else{
                [sectionStr appendFormat:@"%@",obj];
            }
        }];
        NSDictionary *bodyDict = @{@"description":ss.eventDescription.text,@"comment":ss.commentfield.text,@"week":week,@"day_of_week":dayOfWeek,@"date":eventDate,@"time":sectionStr,@"repeat":@"-1",@"alarm":@"1000000"};
        if ([NSJSONSerialization isValidJSONObject:bodyDict]) {
            NSError *jsonErr;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict options:0 error:&jsonErr];
            if (jsonErr) {
                NSLog(@"json 编译错误: --- error %@", jsonErr);
                return;
            }
            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [dfm setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            ProtoMessage* s1 = [[ProtoMessage alloc]init];
            s1.type = ProtoMessage_Type_Chat;
            s1.from = [NSString stringWithFormat:@"%@(%@)",apd.userName,apd.userid];
            s1.to = ss.groupid;
            s1.time = [dfm stringFromDate:[NSDate date]];//yyyy-MM-dd HH:mm:ss 应该以服务器时间为准
            s1.body = jsonStr;
            
            [[HXSocketBusinessManager shareInstance] writeDataWithCmdtype:HXCmdType_Chat requestBody:[s1 data] block:^(NSError *error, ProtoMessage *data) {
                if (error) {
                    NSLog(@"%@",error);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        ss.hud = [MBProgressHUD showHUDAddedTo:ss.view animated:YES];
                        ss.hud.mode = MBProgressHUDModeText;
                        ss.hud.label.text = @"发送失败";
                        [ss.hud hideAnimated:YES afterDelay:1.5];
                    });
                } else{
                    //如果发布成功，就添加到群组消息页
                    [dfm setDateFormat:@"yyyyMMdd"];
                    NSString *eventTime = [dfm stringFromDate:ss.currentDate];

                    [dfm setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    NSDate *tempPublishDate = [dfm dateFromString:data.time];
                    [dfm setDateFormat:@"yyyyMMddHHmmss"];
                    NSString *publishTime = [dfm stringFromDate:tempPublishDate];
                    NSString *ramdomStr = [NSString stringWithFormat:@"%d" ,(arc4random() % 10000)+10000];
                    publishTime = [publishTime stringByAppendingString:[ramdomStr substringFromIndex:1]];
                    
                    NSString *publisher = [NSString stringWithFormat:@"%@(%@)",apd.userName,apd.userid];
                    NSString *eventSection = [ss appendStringWithArray:ss.sectionArray];
                    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:publishTime,@"publishTime",publisher,@"publisher",ss.eventDescription.text,@"event",eventTime,@"eventDate",eventSection,@"eventSection",ss.commentfield.text,@"comment",[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:ss.dlIndex]],@"deadlineIndex",ss.groupid,@"groupId",nil];
                    GroupInfoModel *newEvent = [GroupInfoModel groupInfoWithDict:dict];
                    //更新缓存，通知首页
                    ss.compBlock(newEvent);
                    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:newEvent, HXNewGroupInfo, nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:HXPublishGroupInfoNotification object:nil userInfo:dataDict];
                    //更新数据库
                    [ss.hxdb insertTable:groupInfoTable param:dict callback:^(NSError *error) {
                        if (error) NSLog(@"%@",error.userInfo[NSLocalizedDescriptionKey]);
                    }];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        for (UIViewController *tempVC in ss.navigationController.viewControllers) {
                            if ([tempVC isKindOfClass:NSClassFromString(@"GroupInfoViewController")]) {
                                [ss.navigationController popToViewController:tempVC animated:YES];
                            }
                        }
                    });
                }
            }];
        }
        else{
            NSLog(@"数据有误，不能转为Json");
            void (^otherBlock)(UIAlertAction *action) = ^(UIAlertAction *action){};
            NSArray *otherBlocks = @[otherBlock];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"出错!" message:@"数据有误，不能转为Json" preferredStyle:UIAlertControllerStyleAlert cancelTitle:nil cancelBlock:nil otherTitles:@[@"确定"] otherBlocks:otherBlocks];
            dispatch_async(dispatch_get_main_queue(), ^{
                [ss presentViewController:alert animated:YES completion:nil];
            });
        }
    });
}

- (NSString *)appendStringWithArray:(NSMutableArray *)array{
    NSMutableString *str = [[NSMutableString alloc] initWithCapacity:2];
    [str appendString:@","];
    for (int i = 0; i < array.count; i++) {
        [str appendFormat:@"%@,",array[i]];
    }
    return str;
}

//导航栏右按钮能否点击
- (void)rightBarBtnCanBeSelect{
    if (_eventDescription.text.length > 0 && self.sectionArray.count > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
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
//---------------------------------日期选择
- (void)dateSelected{
    [self.view endEditing:YES];    
    self.coverLayer = [Utils coverLayerAddToWindow];
    
    //生成自定义日期选择器
    weekWidth = 50;
    cellWidth = 38;
    datePickerWidth = weekWidth +cellWidth *7 +5;//5边界预留
    
    [self datePickerCreate:self.currentDate];
    self.lastSelectedDate = self.currentDate;
}

- (void)datePickerCreate:(NSDate *)curDate {
    int weekRow = [DateUtils rowNumber:curDate];//日历该有多少行
    CGFloat datePickerHeight = cellWidth * (weekRow+1) + (76 + 178)/2 + 10;//+1:显示周几的一行，76：两个btn高度，178：顶部年月高度 10:确认取消上的预留位
    __weak typeof(self) ws = self;
    DatePicker *picker =
    [[DatePicker alloc] initWithFrame:CGRectMake(0, 64, datePickerWidth, datePickerHeight)
                                 date:curDate
                      firstDateOfTerm:self.firstDateOfTerm
                         confirmBlock:^(NSDate *selectedDate) {
                             ws.currentDate = selectedDate;//下次就会默认选中上次的日期
                             [ws bsTVBtnSetting:selectedDate];
                             [ws.coverLayer removeFromSuperview];
                         }
                          cancelBlock:^{
                              [ws.coverLayer removeFromSuperview];
                          }
                 monPickerCreateBlock:^(NSDate *currentDate) {
                     __strong typeof(ws) ss = ws;
                     MonthPicker *monthPicker = [[MonthPicker alloc]initWithFrame:CGRectMake(0, 0, 265, 322) date:currentDate];
                     [ss.coverLayer addSubview:monthPicker];
                     [Utils putViewOnCenter:monthPicker superView:ss.view];
                     monthPicker.delegate = ss;
                 }];
    _datePicker = (DatePicker *)[Utils putViewOnCenter:picker superView:self.view];
    [_coverLayer addSubview:_datePicker];
}

//-----------------------------时间段（节）选择
- (void)sectionSelected{
    [self.view endEditing:YES];
    self.coverLayer = [Utils coverLayerAddToWindow];
    
    CGFloat width = 650 / 750.0 * kScreenWidth;
    CGFloat height = (178 + 76)/2 + 245;
    SectionSelect *selectSection = [[SectionSelect alloc]initWithFrame:CGRectMake(0, 0, width, height) sectionArr:self.sectionArray selectedDate:self.currentDate originIndexs:self.originArr originDate:self.originDate termFirstDate:self.firstDateOfTerm];
    _selectSection = (SectionSelect *)[Utils putViewOnCenter:selectSection superView:self.view];
    [_coverLayer addSubview:_selectSection];
    _selectSection.delegate = self;
}

//-----------------------------截止日期回复
- (void)remainSetting{
    [self.view endEditing:YES];
    self.coverLayer = [Utils coverLayerAddToWindow];
    
    __weak typeof(self) ws = self;
    SingleChoiceView *dlRemindView =
    [[SingleChoiceView alloc] initWithItems:self.dlItem
                              selectedIndex:self.dlIndex
                                  viewWidth:265
                                 cellHeight:40
                     confirmCancelBtnHeight:40
                               confirmBlock:^(NSInteger selectedIndex) {
                         ws.dlIndex = selectedIndex;
                         [ws.replyDL setTitle:ws.dlItem[selectedIndex] forState:UIControlStateNormal];
                         [ws.coverLayer removeFromSuperview];
                     }
                                cancelBlock:^{
                                    [ws.coverLayer removeFromSuperview];
                                }];
    _dlRemindView = (SingleChoiceView *)[Utils putViewOnCenter:dlRemindView superView:self.view];
    [_coverLayer addSubview:_dlRemindView];
}

#pragma mark viewsSetting
- (void)viewsSetting{
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[Utils colorWithHexString:@"#333333"],NSFontAttributeName:[UIFont systemFontOfSize:17]};
    self.navigationItem.title = @"发布信息";
    UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightBtn setImage:[UIImage imageNamed:@"confirm"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
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
    _eventDescription.text = self.infoModel.event;
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
    [_replyDL setTitle:self.dlItem[self.dlIndex] forState:UIControlStateNormal];
    [_replyDL setTitleColor:[Utils colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    [_replyDL addTarget:self action:@selector(remainSetting) forControlEvents:UIControlEventTouchUpInside];
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
    _commentfield.text = self.commentInfo;
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
    [self datePickerCreate:currentDate];
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
        //拼接字符串
        NSString *str = [Utils appendSectionStringWithArray:sectionArray];
        [self.eventTimeView.button2 setTitle:[NSString stringWithFormat:@"第%@节",str] forState:UIControlStateNormal];
        [self.eventTimeView.button2 setTitleColor:[Utils colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    }else{
        [self.eventTimeView.button2 setTitle:@"选择时间" forState:UIControlStateNormal];
        [self.eventTimeView.button2 setTitleColor:[Utils colorWithHexString:@"#d9d9d9"] forState:UIControlStateNormal];
    }
    self.sectionArray = [sectionArray mutableCopy];

    [self rightBarBtnCanBeSelect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}
#pragma mark lazy
- (NSArray *)dlItem{
    if (_dlItem == nil) {
        _dlItem = @[@"当事件发生时",@"事件开始前12小时",@"事件开始前24小时",@"事件开始前36小时",@"事件开始前48小时",@"事件开始前一周",@"事件开始前一个月"];
    }
    return _dlItem;
}

- (HXDBManager *)hxdb{
    if (_hxdb == nil) {
        _hxdb = [HXDBManager shareDB];
    }
    return _hxdb;
}

- (void)dealloc{
}
@end
