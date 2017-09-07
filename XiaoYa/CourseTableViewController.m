//
//  CourseTableViewController.m
//  XiaoYa
//
//  Created by commet on 16/10/11.
//  Copyright © 2016年 commet. All rights reserved.
//github有点迷

#import "CourseTableViewController.h"
#import "WeekSheet.h"
#import "CourseModel.h"
#import "BusinessModel.h"
#import "CourseButton.h"
#import "TimeViewCell.h"
#import "DayViewCell.h"
#import "Masonry.h"
#import "Utils.h"
#import "DateUtils.h"
#import "NSDate+Calendar.h"
#import "BusinessViewController.h"
#import "CourseViewController.h"
#import "BusinessCourseManage.h"
#import "CollectView.h"
#import "DbManager.h"
#import "EventKitManager.h"
#import "MBProgressHUD.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define kScreenHeight [UIApplication sharedApplication].keyWindow.bounds.size.height
@interface CourseTableViewController ()<UIScrollViewDelegate,WeekSheetDelegate,BusinessCourseManageDelegate,BusinessViewControllerDelegate,CourseViewControllerDelegate,CollectViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic ,weak) UIButton* navItemTitle;
@property (nonatomic ,weak) WeekSheet* weeksheet;//标题按钮下拉列表
@property (nonatomic ,weak) UIScrollView* timeView;//纵向表示时间段的scrollview
@property (nonatomic ,weak) UIScrollView* daysView;//横向表示日期周几的scrollview
@property (nonatomic ,weak) UIScrollView* classView;;//课程格子scrollview
@property (nonatomic ,weak) UIView *topLeftView;//左上角
@property (nonatomic ,weak) UIView *stripeView;//日期底部会滑动的横条
@property (nonatomic ,weak) UIView *coverLayer;//半透明遮罩
@property (nonatomic ,weak) UIButton *classTableAddBtn;//课程表上点击才出现的+按钮

@property (nonatomic ,strong)NSMutableArray *classSubViewArray;//classview上七个列上的子view，用来控制某列所有课程格子的宽度
@property (nonatomic ,strong)NSMutableArray *allCourses;//存储一周所有课程数据模型的数组
@property (nonatomic ,strong)NSMutableArray *allBusiness;//存储一周所有事务数据模型的数组
@property (nonatomic ,strong)NSDate *firstDateOfTerm;
@property (nonatomic ,assign)NSInteger curWeek;//当前周，从0开始
@property (nonatomic ,strong)EventKitManager *eventManager;
@property (nonatomic ,strong)DbManager *dbManager;
@property (nonatomic ,copy)NSMutableString *courseBtnName;//课程格子名称、或事物描述
@property (nonatomic ,copy)NSMutableString *courseBtnPlace;//课程格子地点
@end

static BOOL flag = false ;
@implementation CourseTableViewController
{
    CGFloat topLeftViewWidth;//左上角view的宽
    CGFloat topLeftViewHeight;//左上角view的高
    CGFloat timeViewCellHeight;//时间段scrollview上的子view高
    CGFloat dayViewCellWidth;//日期scrollview上的子view宽
    NSInteger currentWeekDay;//当前是周几,0表示周一
    NSInteger currentDayIndex;//当前选中的是哪列
    NSInteger lastDayIndex;//上次选中的是哪列
    int countX;//点击课程表上出现+按钮的 第x格
    int countY;//点击课程表上出现+按钮的 第y格
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self calendarAuthority];
    //测试用，清掉所有日历数据
//    NSMutableArray *dateString = [Utils dateStringArrayFromDate:[NSDate date] yearDuration:3 repeatIndex:0];
//    [self.eventManager removeEventNotifyWithCurrentDateString:dateString startSection:@"0" endSection:@"14" isDeleteFuture:NO];
    //-------
    NSDate *currentDate = [NSDate date];//当前日期。
    int weekday = [currentDate dayOfWeek];//周几，1表示周日，2表示周一
    if (weekday == 1){//转换，0表示周一，1表示周二......6表示周日
        currentWeekDay = 6;
    }else{
        currentWeekDay = weekday - 2;
    }
    currentDayIndex = currentWeekDay;
    
    //-------设置右上角加号
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"addItem"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(pushAddViewController)];
    //-------去掉导航栏下面那条黑线
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBg"] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    //-------导航栏title设置
    self.edgesForExtendedLayout=UIRectEdgeNone;
    UIButton *navItemTitle = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
    _navItemTitle = navItemTitle;
    _navItemTitle.titleLabel.font = [UIFont systemFontOfSize:17.0];
    NSInteger curDateDistance = [DateUtils dateDistanceFromDate:currentDate toDate:self.firstDateOfTerm];//当前日期距离学期第一天的天数
    self.curWeek = curDateDistance / 7;//当前周
    [_navItemTitle setTitle:[NSString stringWithFormat:@"第%@周",[NSNumber numberWithInteger:self.curWeek+1]] forState:UIControlStateNormal];
    [_navItemTitle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_navItemTitle addTarget:self action:@selector(popWeekSheet) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = _navItemTitle;
    
    //-------一些用到的距离
    topLeftViewWidth = 90.0 / 750.0 * kScreenWidth; //750是iphone6屏幕宽。乘除运算要带小数点，不然整数和整数相除结果也是整数
    topLeftViewHeight = 110.0 / 1334.0 * kScreenHeight;
    timeViewCellHeight = (kScreenHeight - 64 - 49 - topLeftViewHeight) / 10.0;
    dayViewCellWidth = (kScreenWidth - topLeftViewWidth)/6.0;//放大列为正常列两倍,相当于一屏有六列
    
    //-------
    [self dataBase];
    [self topLeftViewSetting];
    [self timeScrollViewSetting];
    [self dayAndClassRefresh:currentDate];
    [self bottomLineSetting];
    [self weekSheetInit];//最后加，加在最上一层

    [self loadLoacalData:self.curWeek];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViews:) name:@"dataTaskNotification" object:nil];
}

- (void)calendarAuthority{
    EKAuthorizationStatus eventStatus = [EKEventStore  authorizationStatusForEntityType:EKEntityTypeEvent];
    if(eventStatus ==EKAuthorizationStatusNotDetermined){
        //提示用户授权
        [[[EKEventStore alloc]init] requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
            if(granted){
                NSLog(@"允许");
            }else{
                NSLog(@"拒绝授权");
            }
        }];
    }else if (eventStatus == EKAuthorizationStatusDenied){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"当前日历服务不可用" message:@"您还没有授权本应用使用日历,请到 设置 > 隐私 > 日历 中授权" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)dataBase{
    //-------数据库
    [self.dbManager openDb:@"eventData.sqlite"];
//    [self.dbManager executeNonQuery:@"drop table if exists course_table"];
    NSString *sql2 = [NSString stringWithFormat:@"create table IF NOT EXISTS course_table(id integer primary key autoincrement,courseName text not null,                                                                                                                                        weeks text not null,                                                                                                                                                            weekday text not null,                                                                                                                                                              time text not null,                                                                                                                                                               place text not null);"];
    [self.dbManager executeNonQuery:sql2];
}

- (void)popWeekSheet{
    if(!flag){
        self.weeksheet.hidden = NO;
        flag = true;
    }
    else
    {
        self.weeksheet.hidden = YES;
        flag = false;
    }
}

- (void)pushAddViewController{
    NSMutableArray *controllersArray = [NSMutableArray array];
    BusinessViewController *businessManage = [[BusinessViewController alloc]initWithfirstDateOfTerm:self.firstDateOfTerm businessModel:nil];
    businessManage.delegate = self;
    [controllersArray addObject:businessManage];
    CourseViewController *courseManage = [[CourseViewController alloc]initWithCourseModel:nil];
    courseManage.delegate = self;
    [controllersArray addObject:courseManage];

    BusinessCourseManage *management = [[BusinessCourseManage alloc]initWithControllersArray:controllersArray firstDateOfTerm:self.firstDateOfTerm];
    management.delegate = self;
    management.hidesBottomBarWhenPushed = YES;//从下级vc开始，tabbar都隐藏掉
    [self.navigationController pushViewController:management animated:YES];
}

//自动导入成功后刷新界面
- (void)updateViews:(NSNotification *)notification {
    [self loadLoacalData:self.curWeek];
    [self textHUDNotify:@"保存成功"];
}

//加载数据,参数week,周数从0开始
- (void)loadLoacalData:(NSInteger )week{
    //刷新表格//清除原有数据
    for(UIView *columview in self.classSubViewArray){
        for(CourseButton *coursebtn in [columview subviews]){
            [coursebtn removeFromSuperview];
        }
    }
    //事务
    NSDate *weekMonday = [DateUtils dateOfWeekMonday:week firstDateOfTrem:self.firstDateOfTerm];
    NSArray *data = [DateUtils getDatesOfCurrence:weekMonday];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSDateComponents *compt = [[NSDateComponents alloc] init];
    for (int m = 0; m < 7; m++) {//按天添加格子
        [compt setYear:[data[m][0] integerValue]];
        [compt setMonth:[data[m][1] integerValue]];
        [compt setDay:[data[m][2] integerValue]];
        NSDate * tempDate = [gregorian dateFromComponents:compt];
        NSString *tempDateString = [dateFormatter stringFromDate:tempDate];
        //以天为单位搜索数据
        NSArray *eventArray = [self.eventManager checkEventWithDateString:@[tempDateString] startSection:@"0" endSection:@"14"];
        NSString *courseSql = [NSString stringWithFormat:@"SELECT * FROM course_table WHERE weeks like '%%,%@,%%' and weekday = '%d';",[NSNumber numberWithInteger:week],m];
        NSArray *courseDataQuery = [self.dbManager executeQuery:courseSql];
        
        if (eventArray.count > 0 && courseDataQuery.count > 0){//课程事务都有
            [self.allBusiness removeAllObjects];
            [self.allCourses removeAllObjects];
            for (int i = 0 ; i < eventArray.count; i ++) {
                BusinessModel *model = [[BusinessModel alloc]initWithEKevent:eventArray[i]];
                [self.allBusiness addObject:model];
            }
            for (int i = 0; i < courseDataQuery.count; i++) {
                CourseModel *courseModel = [[CourseModel alloc]initWithDict:courseDataQuery[i]];
                [self.allCourses addObject:courseModel];
            }
            //如果当前天相对今天是过去的时间
            if ([DateUtils dateDistanceFromDate:[NSDate date] toDate:tempDate] > 0) {
                //课程优先显示，先添加课程格子，再添加事务格子，事务格子是被覆盖的要剔除被覆盖的部分
                for (int i = 0; i < self.allCourses.count; i ++) {
                    CourseModel * courseMDL = self.allCourses[i];
                    NSMutableSet *courseTimeSet = [NSMutableSet setWithArray:courseMDL.timeArray];
                    NSMutableArray *courseBusArray = [NSMutableArray array];
                    for (int j = 0; j < self.allBusiness.count; j++) {
                        BusinessModel *businessMDL = self.allBusiness[j];
                        NSMutableSet *businessTimeSet = [NSMutableSet setWithArray:businessMDL.timeArray];
                        if ([courseTimeSet intersectsSet:businessTimeSet]) {//是否有交集
                            [courseBusArray addObject:businessMDL];
                            businessMDL.intersects = YES;
                            courseMDL.intersects = YES;
                        }
                    }
                    [self addCourseBtn:courseMDL businessArray:courseBusArray tempTimeArray:courseMDL.timeArray];
                }
                //接下来添加事务格子
                NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
                for (int i = 0; i < self.allBusiness.count; i++) {
                    BusinessModel *businessMDL = self.allBusiness[i];
                    if (businessMDL.intersects) {//和课程有交集
                        NSMutableSet *businessTimeSet = [NSMutableSet setWithArray:businessMDL.timeArray];
                        for (int j = 0; j < self.allCourses.count; j++) {
                            CourseModel *courseMDL = self.allCourses[j];
                            NSMutableSet *courseTimeSet = [NSMutableSet setWithArray:courseMDL.timeArray];
                            if ([businessTimeSet intersectsSet:courseTimeSet]) {
                                [businessTimeSet minusSet:courseTimeSet];
                            }
                        }
                        if (businessTimeSet.count != 0) {
                            NSArray *minusBusTime = [businessTimeSet sortedArrayUsingDescriptors:sortDesc];//剔除重复时间后的事务时间,升序排列
                            NSMutableArray *minusTimeSections = [Utils subSectionArraysFromArray:[minusBusTime mutableCopy]];
                            for (int k = 0; k < minusTimeSections.count; k++) {
                                [self addBussinessBtn:businessMDL courseArray:nil tempTimeArray:minusTimeSections[k]];
                            }
                        }
                    }else{
                        [self addBussinessBtn:businessMDL courseArray:nil tempTimeArray:businessMDL.timeArray];
                    }
                }
            }
            //如果当前天相对今天是未来的时间
            else{
                //事务优先显示，先添加事务格子，再添加课程格子，课程格子是被覆盖的要剔除被覆盖的部分
                for (int i = 0; i < self.allBusiness.count; i ++) {
                    BusinessModel *busMDL = self.allBusiness[i];
                    NSMutableSet *businessTimeSet = [NSMutableSet setWithArray:busMDL.timeArray];
                    NSMutableArray *busCourseArray = [NSMutableArray array];
                    for (int j = 0; j < self.allCourses.count; j++) {
                        CourseModel *courseMDL = self.allCourses[j];
                        NSMutableSet *courseTimeSet = [NSMutableSet setWithArray:courseMDL.timeArray];
                        if ([businessTimeSet intersectsSet:courseTimeSet]) {
                            [busCourseArray addObject:courseMDL];
                            busMDL.intersects = YES;
                            courseMDL.intersects = YES;
                        }
                    }
                    [self addBussinessBtn:busMDL courseArray:busCourseArray tempTimeArray:busMDL.timeArray];
                }
                //接下来添加课程格子
                NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
                for (int i = 0; i < self.allCourses.count; i++) {
                    CourseModel *courseMDL = self.allCourses[i];
                    if (courseMDL.intersects) {
                        NSMutableSet *courseTimeSet = [NSMutableSet setWithArray:courseMDL.timeArray];
                        for (int j = 0; j < self.allBusiness.count; j++) {
                            BusinessModel *busMDL = self.allBusiness[j];
                            NSMutableSet *businessTimeSet = [NSMutableSet setWithArray:busMDL.timeArray];
                            if ([courseTimeSet intersectsSet:businessTimeSet]) {
                                [courseTimeSet minusSet:businessTimeSet];
                            }
                        }
                        if (courseTimeSet.count != 0) {
                            NSArray *minusCourseTime = [courseTimeSet sortedArrayUsingDescriptors:sortDesc];
                            NSMutableArray *minusTimeSections = [Utils subSectionArraysFromArray:[minusCourseTime mutableCopy]];
                            for (int k = 0; k < minusTimeSections.count; k++) {
                                [self addCourseBtn:courseMDL businessArray:nil tempTimeArray:minusTimeSections[k]];
                            }
                        }
                    }else{
                        [self addCourseBtn:courseMDL businessArray:nil tempTimeArray:courseMDL.timeArray];
                    }
                }
            }
        }
        else if (eventArray.count > 0 && courseDataQuery.count == 0){//只有事务
            [self.allBusiness removeAllObjects];
            [self.allCourses removeAllObjects];
            for (int i = 0 ; i < eventArray.count; i ++) {
                BusinessModel *model = [[BusinessModel alloc] initWithEKevent:eventArray[i]];
                [self addBussinessBtn:model courseArray:nil tempTimeArray:model.timeArray];
            }
        }
        else if ((eventArray.count == 0 || eventArray == nil )&& courseDataQuery.count > 0){//只有课
            [self.allBusiness removeAllObjects];
            [self.allCourses removeAllObjects];
            for (int i = 0 ; i < courseDataQuery.count; i++) {
                CourseModel *model = [[CourseModel alloc] initWithDict:courseDataQuery[i]];
                [self addCourseBtn:model businessArray:nil tempTimeArray:model.timeArray];
            }
        }
    }
}

//添加单个事务格子
- (void)addBussinessBtn:(BusinessModel *)busModel courseArray:(NSMutableArray*)courseArray tempTimeArray:(NSMutableArray *)tempTimearray{
    int rowNum = [tempTimearray.firstObject intValue];//开始时第几节
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSDate *curDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@",busModel.date]];
    int colNum = [curDate dayOfWeek];//周几，1表示周日，2表示周一
    if (colNum == 1) {
        colNum = 6;
    }else{
        colNum = colNum - 2;
    }
    NSInteger lessonsNum = tempTimearray.count;//持续多少节
    
//    NSArray *businessArr = [[NSArray alloc]initWithObjects:busModel, nil];
//    CourseButton *courseBtn = [[CourseButton alloc]initWithCourseArray:courseArray businessArray:businessArr btntype:0];
    CourseButton *courseBtn = [[CourseButton alloc]init];   //课程格子btn
    courseBtn.businessArray = [[NSMutableArray alloc]initWithObjects:busModel, nil];
    courseBtn.courseArray = courseArray;
    courseBtn.type = 0;
    
    self.courseBtnName = [self insertLineFeedPerThreeChar:[[NSMutableString alloc]initWithString:busModel.desc]];
    self.courseBtnPlace = [[NSMutableString alloc]initWithString:@""];
//    courseBtn.event.text = busModel.desc;
    if (courseArray.count > 0) {//courseArray也有可能为Nil,可能初始化了但没有元素赋值（count=0）。
        courseBtn.isOverlap = YES;
    }
    if (currentDayIndex == colNum) {
//        courseBtn.event.font = [UIFont systemFontOfSize:13];
//        courseBtn.place.font = [UIFont systemFontOfSize:13];
        courseBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        self.courseBtnName = [self insertLineFeedPerSixChar:[[NSMutableString alloc]initWithString:busModel.desc]];
    }
    [courseBtn setTitle:[[NSString alloc]initWithFormat:@"%@",self.courseBtnName] forState:UIControlStateNormal];
    if (busModel.intersects) {//如果有重复
        UIImage *curUnderlap = [[UIImage imageNamed:@"business_1"]resizableImageWithCapInsets:UIEdgeInsetsMake(15, 10, 0, 15) resizingMode:UIImageResizingModeStretch];
        [courseBtn setBackgroundImage:curUnderlap forState:UIControlStateNormal];
    }else{
        UIImage *curUnderlap = [[UIImage imageNamed:@"business"]resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 2) resizingMode:UIImageResizingModeStretch];
        [courseBtn setBackgroundImage:curUnderlap forState:UIControlStateNormal];
    }
    UIView *btnSuperView = self.classSubViewArray[colNum];  //课程格子btn的父view
    [courseBtn addTarget:self action:@selector(courseClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnSuperView addSubview:courseBtn];
    [courseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(btnSuperView.mas_left);
        make.width.equalTo(btnSuperView.mas_width);
        make.height.mas_equalTo(timeViewCellHeight * lessonsNum-1);
        make.top.mas_equalTo(rowNum * timeViewCellHeight+1);
    }];
}

//添加单个课程格子
- (void)addCourseBtn:(CourseModel *)courseModel businessArray:(NSMutableArray *)busArray tempTimeArray:(NSMutableArray*)tempTimearray{
    int rowNum = [tempTimearray.firstObject intValue];//开始时第几节
    int colNum = courseModel.weekday.intValue;
    NSInteger lessonsNum = tempTimearray.count;//持续多少节
    
//    NSArray *courseArr = [[NSArray alloc]initWithObjects:courseModel, nil];
//    CourseButton *courseBtn = [[CourseButton alloc]initWithCourseArray:courseArr businessArray:busArray btntype:1];
    CourseButton *courseBtn = [[CourseButton alloc]init];   //课程格子btn
    courseBtn.courseArray = [[NSMutableArray alloc]initWithObjects:courseModel, nil];
    courseBtn.businessArray = busArray;
    courseBtn.type = 1;
    
    self.courseBtnName = [self insertLineFeedPerThreeChar:[[NSMutableString alloc]initWithString:courseModel.courseName]];
    self.courseBtnPlace = [self insertLineFeedPerThreeChar:[[NSMutableString alloc]initWithFormat:@"@%@",courseModel.place]];
//    courseBtn.event.text = courseModel.courseName;
//    courseBtn.place.text = [NSString stringWithFormat:@"@%@",courseModel.place];
    if (busArray.count > 0) {//busArray也有可能为Nil,可能初始化了但没有元素赋值（count=0）。
        courseBtn.isOverlap = YES;
    }
    if (currentDayIndex == colNum) {
//        courseBtn.event.font = [UIFont systemFontOfSize:13];
//        courseBtn.place.font = [UIFont systemFontOfSize:13];
        courseBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        self.courseBtnName = [self insertLineFeedPerSixChar:[[NSMutableString alloc]initWithString:courseModel.courseName]];
        self.courseBtnPlace = [self insertLineFeedPerSixChar:[[NSMutableString alloc]initWithFormat:@"@%@",courseModel.place]];
    }
    [courseBtn setTitle:[[NSString alloc]initWithFormat:@"%@\n%@",self.courseBtnName,self.courseBtnPlace] forState:UIControlStateNormal];
    if (courseModel.intersects) {//如果有重复
        UIImage *curUnderlap = [[UIImage imageNamed:@"course_1"]resizableImageWithCapInsets:UIEdgeInsetsMake(15, 10, 0, 15) resizingMode:UIImageResizingModeStretch];
        [courseBtn setBackgroundImage:curUnderlap forState:UIControlStateNormal];
    }else{
        UIImage *curUnderlap = [[UIImage imageNamed:@"course"]resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch];
        [courseBtn setBackgroundImage:curUnderlap forState:UIControlStateNormal];
    }
    UIView *btnSuperView = self.classSubViewArray[colNum];  //课程格子btn的父view
    [courseBtn addTarget:self action:@selector(courseClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnSuperView addSubview:courseBtn];
    [courseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(btnSuperView.mas_left);
        make.width.equalTo(btnSuperView.mas_width);
        make.height.mas_equalTo(timeViewCellHeight * lessonsNum-1);
        make.top.mas_equalTo(rowNum * timeViewCellHeight+1);
    }];
}
//每三个字符插入一个换行符
- (NSMutableString *)insertLineFeedPerThreeChar:(NSMutableString*)str{
    int strLength = (int)str.length;
    int modNum = strLength%3;
    if (modNum == 0) {
        modNum = 3;
    }
    for (int i = strLength - modNum; i > 0; i -=3) {
        [str insertString:@"\n" atIndex:i];
    }
    return str;
}
//每六个字符插入换行符
- (NSMutableString *)insertLineFeedPerSixChar:(NSMutableString*)str{
    int strLength = (int)str.length;
    int modNum = strLength%6;
    if (modNum == 0) {
        modNum = 6;
    }
    for (int i = strLength - modNum; i > 0; i -=6) {
        [str insertString:@"\n" atIndex:i];
    }
    return str;
}

- (void)courseClick:(id)sender{
    CourseButton *courseBtn = (CourseButton *)sender;
    if (courseBtn.isOverlap) {
        UIView *coverLayer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        coverLayer.backgroundColor = [UIColor colorWithRed:88/255.0 green:88/255.0  blue:88/255.0  alpha:0.5];
        _coverLayer = coverLayer;
        //添加手势
        _coverLayer.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverFingerTapped:)];
        singleTap.delegate = self;
//        singleTap.cancelsTouchesInView = NO;
        [_coverLayer addGestureRecognizer:singleTap];
        UIWindow *theWindow = [[UIApplication sharedApplication] delegate].window;
        [theWindow addSubview:_coverLayer];
               
        NSArray *combineArray = [courseBtn.businessArray arrayByAddingObjectsFromArray:courseBtn.courseArray];
        CollectView *collectView;
        if (combineArray.count<3) {
            collectView = [[CollectView alloc]initWithFrame:CGRectMake((kScreenWidth-210)/2, (kScreenHeight-100)/2, 210, 100) modelArray:combineArray];
        }else{
            collectView = [[CollectView alloc]initWithFrame:CGRectMake((kScreenWidth-210)/2, (kScreenHeight-245)/2, 210, 245) modelArray:combineArray];
        }
        [_coverLayer addSubview:collectView];
        collectView.delegate = self;
        
    }else if (courseBtn.courseArray == nil || courseBtn.courseArray.count==0){//如果只有事务
        [self pushToBusinessDetailPageWithModel:courseBtn.businessArray.firstObject];
    }else if (courseBtn.businessArray == nil || courseBtn.businessArray.count == 0){//只有课程
        [self pushToCourseDetailPageWithModel:courseBtn.courseArray.firstObject];
    }
}

-(void)coverFingerTapped:(UITapGestureRecognizer *)gestureRecognizer{
    [_coverLayer removeFromSuperview];
}

- (void)textHUDNotify:(NSString *)text{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = text;
    [hud hideAnimated:YES afterDelay:1.0];
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
//    NSLog(@"%d",[touch.view isKindOfClass:[UIButton class]]);
    if ([touch.view.superview isKindOfClass:[UICollectionViewCell class]]) {//如果点击的是UICollectionViewCell，touch.view是collectionViewCell的contentView，contentView的父view才是collectionCell
        return NO;
    }else if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

- (void)pushToCourseDetailPageWithModel:(CourseModel*)model{
    NSString *courseName = model.courseName;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM course_table WHERE courseName = '%@';",courseName];
    NSArray *courseDataQuery = [self.dbManager executeQuery:sql];
    NSMutableArray *courseModelArr = [NSMutableArray array];
    for (int i  = 0; i < courseDataQuery.count; i++) {
        CourseModel *courseModel = [[CourseModel alloc]initWithDict:courseDataQuery[i]];
        [courseModelArr addObject:courseModel];
    }
    CourseViewController *courseVC = [[CourseViewController alloc]initWithCourseModel:courseModelArr];
    courseVC.delegate = self;
    courseVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:courseVC animated:YES];
}

- (void)pushToBusinessDetailPageWithModel:(BusinessModel*)model{
    BusinessViewController *businessManage = [[BusinessViewController alloc]initWithfirstDateOfTerm:self.firstDateOfTerm businessModel:model];
    businessManage.delegate = self;
    businessManage.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:businessManage animated:YES];
}

#pragma mark CollectViewDelegate
- (void)pushToDetailPage:(CollectView*)collectionView cellModel:(id)model{
    [_coverLayer removeFromSuperview];
    if ([model isKindOfClass:[BusinessModel class]]) {
        [self pushToBusinessDetailPageWithModel:model];
    }else if([model isKindOfClass:[CourseModel class]]){
        [self pushToCourseDetailPageWithModel:model];
    }
}

#pragma mark BusinessCourseMangerDelegate
- (void)BusinessCourseManage:(BusinessCourseManage *)viewController week:(NSInteger )selectedWeek{
    [_navItemTitle setTitle:[NSString stringWithFormat:@"第%@周",[NSNumber numberWithInteger:selectedWeek+1]] forState:UIControlStateNormal];
    NSDate *weekMonday = [DateUtils dateOfWeekMonday:selectedWeek firstDateOfTrem:self.firstDateOfTerm];
    [self dayAndClassRefresh:weekMonday];
    self.curWeek = selectedWeek;
    [self loadLoacalData:selectedWeek];
    [self.view bringSubviewToFront:_weeksheet];
}

#pragma mark BusinessViewControllerDelegate
- (void)BusinessViewController:(BusinessViewController *)viewController week:(NSInteger)selectedWeek{
    [_navItemTitle setTitle:[NSString stringWithFormat:@"第%@周",[NSNumber numberWithInteger:selectedWeek + 1]] forState:UIControlStateNormal];
    NSDate *weekMonday = [DateUtils dateOfWeekMonday:selectedWeek firstDateOfTrem:self.firstDateOfTerm];
    [self dayAndClassRefresh:weekMonday];
    self.curWeek = selectedWeek;
    [self loadLoacalData:selectedWeek];
    [self.view bringSubviewToFront:_weeksheet];
    [self textHUDNotify:@"保存成功"];
}

- (void)deleteBusiness:(BusinessViewController *)viewController{
    [self loadLoacalData:self.curWeek];
    [self textHUDNotify:@"删除成功"];
}

#pragma mark CourseViewControllerDelegate
- (void)CourseViewControllerConfirm:(CourseViewController*)viewController{
    [self loadLoacalData:self.curWeek];
    [self textHUDNotify:@"保存成功"];
}

- (void)CourseViewControllerDelete:(CourseViewController *)viewController{
    [self loadLoacalData:self.curWeek];
    [self textHUDNotify:@"删除成功"];
}

#pragma mark weekSheetDelegate
- (void)refreshNavItemTitle:(WeekSheet *)weeksheet content:(NSInteger)weekSheetRow{
    [_navItemTitle setTitle:[NSString stringWithFormat:@"第%@周",[NSNumber numberWithInteger:weekSheetRow + 1]] forState:UIControlStateNormal];
    //加载新数据
    self.weeksheet.hidden = YES;
    NSDate *weekMonday = [DateUtils dateOfWeekMonday:weekSheetRow firstDateOfTrem:self.firstDateOfTerm];
    [self dayAndClassRefresh:weekMonday];
    self.curWeek = weekSheetRow;
    [self loadLoacalData:weekSheetRow];
    [self.view bringSubviewToFront:_weeksheet];
    flag = false;
}

#pragma mark scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _classView) {
        [self.daysView setContentOffset:CGPointMake(self.classView.contentOffset.x, 0) animated:NO];
        [self.timeView setContentOffset:CGPointMake(0, self.classView.contentOffset.y) animated:NO];
    }
}

#pragma mark subviewsInit
- (void)weekSheetInit{
    WeekSheet *weeksheet = [[WeekSheet alloc]init];
    _weeksheet = weeksheet;
    _weeksheet.delegate = self;
    [self.view addSubview:_weeksheet];
    
    __weak typeof(self) weakself = self;
    [_weeksheet mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(162);
        make.height.mas_equalTo(178);
        make.centerX.equalTo(weakself.view.mas_centerX);
        make.top.equalTo(weakself.view.mas_top);
    }];
    _weeksheet.hidden = YES;
}

//设置左上角的一个方块
- (void)topLeftViewSetting{
    UIView *topLeftView = [[UIView alloc]init];
    _topLeftView = topLeftView;
    self.topLeftView.backgroundColor = [Utils colorWithHexString:@"#f0f0f6"];
    [self.view addSubview:_topLeftView];
    __weak typeof(self) weakself = self;
    [_topLeftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(weakself.view);
        make.width.mas_equalTo(topLeftViewWidth);
        make.height.mas_equalTo(topLeftViewHeight);
    }];
    
    UIImageView *calendar = [[UIImageView alloc]init];
    calendar.image = [UIImage imageNamed:@"calendar"];
    [_topLeftView addSubview:calendar];
    [calendar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_topLeftView.mas_right).offset(-10);
        make.centerY.equalTo(_topLeftView.mas_centerY);
    }];
}

//设置节数信息scrollview
-(void)timeScrollViewSetting{
    UIScrollView *timeScrollView = [[UIScrollView alloc]init];
    _timeView = timeScrollView;
    _timeView.backgroundColor = [UIColor whiteColor];
    _timeView.bounces = NO;
    _timeView.scrollEnabled = NO;
    _timeView.contentSize = CGSizeMake(0, timeViewCellHeight * 15);//横向不能滚动
    [self.view addSubview:_timeView];
    __weak typeof(self) weakself = self;
    [_timeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.view);
        make.top.equalTo(_topLeftView.mas_bottom);
        make.width.equalTo(_topLeftView.mas_width);
        make.height.mas_equalTo(kScreenHeight - 64 - 49 - topLeftViewHeight);
    }];
    
    NSArray *timeData = @[@[@"早间"],@[@"8:00",@"1"],@[@"8:55",@"2"],@[@"10:00",@"3"],@[@"10:55",@"4"],@[@"午间"],@[@"14:30",@"5"],@[@"15:25",@"6"],@[@"16:20",@"7"],@[@"17:15",@"8"],@[@"18:10",@"9"],@[@"19:00",@"10"],@[@"19:55",@"11"],@[@"20:50",@"12"],@[@"晚间"]];
    NSInteger index = 0;
    for (NSArray *dataArray in timeData) {
        
        UIView *bottomline = [[UIView alloc]init];
        [_timeView addSubview:bottomline];
        bottomline.backgroundColor = [Utils colorWithHexString:@"#d9d9d9"];
        [bottomline mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(weakself.view);
            make.width.equalTo(_timeView.mas_width);
            make.top.mas_equalTo(timeViewCellHeight*(index+1));
            make.height.mas_equalTo(1);
        }];
        
        
        if (dataArray.count == 1) {
            UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, index * timeViewCellHeight, topLeftViewWidth, timeViewCellHeight)];
            lab.text = [dataArray firstObject];
            lab.font = [UIFont systemFontOfSize:10];
            lab.textAlignment = NSTextAlignmentCenter;
            lab.textColor = [Utils colorWithHexString:@"#4c4c4c"];
            lab.opaque = NO;
//            lab.backgroundColor = [UIColor whiteColor];
            [_timeView addSubview:lab];
        }
        else{
            TimeViewCell *timeCell = [[TimeViewCell alloc]initWithFrame:CGRectMake(0, index * timeViewCellHeight, topLeftViewWidth, timeViewCellHeight)];
            timeCell.time.text = [dataArray firstObject];
            timeCell.number.text = [dataArray lastObject];
            timeCell.opaque = NO;
            [_timeView addSubview:timeCell];
        }
        index ++;
    }
}

//设置日期信息scrollview
-(void)daysViewSetting:(NSDate *)date{
    [_daysView removeFromSuperview];
    
    UIScrollView *dayScrollView = [[UIScrollView alloc] init];
    _daysView = dayScrollView;
    _daysView.backgroundColor = [Utils colorWithHexString:@"#f0f0f6"];
    _daysView.bounces = NO;
    _daysView.scrollEnabled = NO;
    _daysView.delegate = self;
    _daysView.contentSize = CGSizeMake(8 * dayViewCellWidth, 0);//7+1放大列
    [self.view addSubview:_daysView];
    __weak typeof(self) weakself = self;
    [_daysView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_topLeftView.mas_right);
        make.top.equalTo(weakself.view);
        make.width.mas_equalTo(kScreenWidth - topLeftViewWidth);
        make.height.mas_equalTo(topLeftViewHeight);
    }];
    //添加数据
    NSArray *data = [DateUtils getDatesOfCurrence:date];
    NSMutableArray * dateArray = [NSMutableArray arrayWithCapacity:7];
    for (int i = 0; i < 7; i ++) {
        [dateArray addObject:[NSString stringWithFormat:@"%@.%@",data[i][1],data[i][2]]];
    }
    NSArray *weekArray = @[@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日"];
    NSMutableArray *viewArray = [NSMutableArray arrayWithCapacity:weekArray.count];//存放日期子view的数组
    //子view内容设置
    for (int i = 0; i < weekArray.count ; i ++) {
        DayViewCell *dayCell = [[DayViewCell alloc]init];
        dayCell.weekday.text = weekArray[i];
        dayCell.date.text = dateArray[i];
        dayCell.tag = 100 + i;//tag从100开始
        [viewArray addObject:dayCell];
        [_daysView addSubview:dayCell];
        
        [dayCell addTarget:self action:@selector(dayCellClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //子view布局
    DayViewCell *lastView;
    for (int i = 0; i < viewArray.count; i ++) {
        DayViewCell *subview = viewArray[i];
        [subview mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i == 0) {
                make.left.equalTo(_daysView.mas_left);
            }else{
                make.left.equalTo(lastView.mas_right);
            }
            make.top.equalTo(_daysView.mas_top);
            make.height.mas_equalTo(topLeftViewHeight);
            if(i == currentWeekDay){
                make.width.mas_equalTo(dayViewCellWidth * 2);
            }else{
                make.width.mas_equalTo(dayViewCellWidth);
            }
        }];
        
        lastView = subview;
        
        //竖分割线
        UIView *sepratorLine = [[UIView alloc]init];
        sepratorLine.backgroundColor = [Utils colorWithHexString:@"#d9d9d9"];
        [subview addSubview:sepratorLine];
        [sepratorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(subview.mas_left);
            make.centerY.equalTo(subview.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(1, 30));//宽度1像素，所以应该是0.5，但0.5会不会太细？
        }];
    }
    
    lastDayIndex = currentWeekDay;
    //马上更新视图约束
    [self.view updateConstraintsIfNeeded];
    [self.view layoutIfNeeded];
    //底部滑动的indicator
    UIView *stripeView = [[UIView alloc]initWithFrame:CGRectMake(currentWeekDay * dayViewCellWidth, self.daysView.frame.size.height - 2, dayViewCellWidth *2, 2)];
    stripeView.backgroundColor = [Utils colorWithHexString:@"#00a7fa"];
    _stripeView = stripeView;
    [self.daysView addSubview:_stripeView];
    
    currentDayIndex = currentWeekDay;
//    int weekday = [date dayOfWeek];//这里先这样处理吧，暂时不清楚切换周数时界面要如何调整
    int weekday = [[NSDate date] dayOfWeek];
    if (weekday >= 6 || weekday <= 1) {//是星期五、六、日,显示周三到周日
        [self.daysView setContentOffset:CGPointMake(dayViewCellWidth * 2, 0) animated:NO];
        [self.classView setContentOffset:CGPointMake(dayViewCellWidth * 2, 0) animated:NO];
    }else{
        [self.daysView setContentOffset:CGPointMake(0, 0) animated:NO];
        [self.classView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
}

//设置课程信息scrollview
-(void)classViewSetting{
    [_classView removeFromSuperview];
    UIScrollView *classView = [[UIScrollView alloc]init];
    _classView = classView;
    _classView.backgroundColor = [UIColor whiteColor];
    _classView.bounces = NO;
    _classView.delegate = self;
    _classView.showsVerticalScrollIndicator = NO;
    _classView.showsHorizontalScrollIndicator = NO;
    _classView.contentSize = CGSizeMake(8 * dayViewCellWidth, timeViewCellHeight * 15);
    //手势
    _classView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(classSubViewFingerTap:)];
    singleTap.delegate = self;
//    singleTap.cancelsTouchesInView = NO;
    [_classView addGestureRecognizer:singleTap];
    
    [self.view addSubview:_classView];
    __weak typeof(self) weakself = self;
    [_classView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_timeView.mas_right);
        make.top.equalTo(_topLeftView.mas_bottom);
        make.width.mas_equalTo(kScreenWidth - topLeftViewWidth);
        make.bottom.equalTo(weakself.view.mas_bottom);
    }];
    for(int i=0;i<15;i++){
        UIView *bottomline = [[UIView alloc]init];
        [_classView addSubview:bottomline];
        bottomline.backgroundColor = [Utils colorWithHexString:@"#d9d9d9"];
        [bottomline mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_classView.mas_left);
            make.width.mas_equalTo(_classView.contentSize.width);
            make.top.mas_equalTo(timeViewCellHeight*(i+1));
            make.height.mas_equalTo(1);
        }];
    }
    //classview上七个列向上的子view
    self.classSubViewArray = [NSMutableArray arrayWithCapacity:7];
    for (int i = 0 ; i < 7 ; i++) {
        UIView *classSubView = [[UIView alloc]init];
        classSubView.tag = 200 +i;
        classSubView.opaque = NO;
        [self.classSubViewArray addObject:classSubView];
        [_classView addSubview:classSubView];
    }
    UIView *lastView;
    for (int i = 0; i < self.classSubViewArray.count; i ++) {
        UIView *subview = self.classSubViewArray[i];
        //约束，左上高宽
        [subview mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i == 0) {
                make.left.equalTo(_classView.mas_left);
            }else{
                make.left.equalTo(lastView.mas_right);
            }
            make.top.equalTo(_classView.mas_top);
            make.height.mas_equalTo(timeViewCellHeight * 15);
            if(i == currentWeekDay){
                make.width.mas_equalTo(dayViewCellWidth * 2);
            }else{
                make.width.mas_equalTo(dayViewCellWidth);
            }
        }];
        lastView = subview;
    }
}

//点击课程表出现+按钮
- (void)classSubViewFingerTap:(UITapGestureRecognizer *)gestureRecognizer{
    [self.classTableAddBtn removeFromSuperview];
    CGPoint location = [gestureRecognizer locationInView:_classView];
    CGFloat locationX = location.x;
    CGFloat locationY = location.y;
    CGFloat addBtnCenterY;

    countY = 0;
    while (locationY - timeViewCellHeight > 0) {
        locationY -= timeViewCellHeight;
        countY ++;
    }
    addBtnCenterY = countY * timeViewCellHeight +0.5*timeViewCellHeight;
    
    countX = 0;
    if (currentDayIndex*dayViewCellWidth+2*dayViewCellWidth < locationX) {
        CGFloat templocationX = locationX - (currentDayIndex*dayViewCellWidth+2*dayViewCellWidth);
        CGFloat tempCountX = 0;
        while (templocationX - dayViewCellWidth > 0) {
            templocationX -= dayViewCellWidth;
            tempCountX ++;
        }
        countX = currentDayIndex + tempCountX + 1;
    }else{
        if(locationX - currentDayIndex*dayViewCellWidth > 0){
            countX = (int)currentDayIndex;
        }else{
            while (locationX - dayViewCellWidth > 0) {
                locationX -= dayViewCellWidth;
                countX++;
            }
        }
    }
    
    UIView *colSubView = self.classSubViewArray[countX];
    UIButton *addBtn = [[UIButton alloc]init];
    [addBtn setImage:[UIImage imageNamed:@"添加"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addItemFromClassTable:) forControlEvents:UIControlEventTouchUpInside];
    [colSubView addSubview:addBtn];
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.centerY.equalTo(colSubView.mas_top).offset(addBtnCenterY);
        make.centerX.equalTo(colSubView.mas_centerX);
    }];
    self.classTableAddBtn = addBtn;
}

- (void)addItemFromClassTable:(id)sender{    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSTimeInterval oneDay = 24*60*60*1;  //1天的长度
    NSDate* theDate = [self.firstDateOfTerm dateByAddingTimeInterval:oneDay*(7*self.curWeek+countX)];//第几周周几的日期
    NSString *currentDateStr = [dateFormatter stringFromDate:theDate];
    
    NSMutableDictionary *busModelDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"",@"description",@"",@"comment",currentDateStr,@"date",[NSString stringWithFormat:@",%d,",countY],@"time",@"6",@"repeat",[NSMutableArray arrayWithObject:@"6"],@"remind",nil];
    BusinessModel *busMdl = [[BusinessModel alloc]initWithDict:busModelDict];
    BusinessViewController *businessManage = [[BusinessViewController alloc]initWithfirstDateOfTerm:self.firstDateOfTerm businessModel:busMdl];
    businessManage.delegate = self;
    
    NSMutableDictionary *courseModelDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@",%d,",countY],@"time",@",0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,",@"weeks",[NSString stringWithFormat:@"%d",countX],@"weekday",@"",@"courseName",@"",@"place",nil];
    CourseModel *courseModel = [[CourseModel alloc]initWithDict:courseModelDict];
    CourseViewController *courseManage = [[CourseViewController alloc]initWithCourseModel:[NSMutableArray arrayWithObjects:courseModel, nil]];
    courseManage.delegate = self;
    NSMutableArray *controllersArray = [NSMutableArray array];
    
    [controllersArray addObject:businessManage];
    [controllersArray addObject:courseManage];
    BusinessCourseManage *management = [[BusinessCourseManage alloc]initWithControllersArray:controllersArray firstDateOfTerm:self.firstDateOfTerm];
    management.delegate = self;
    management.hidesBottomBarWhenPushed = YES;//从下级vc开始，tabbar都隐藏掉
    [self.navigationController pushViewController:management animated:YES];
}

//点击日期信息一栏宽度会改变
- (void)dayCellClicked:(id)sender{
    DayViewCell *currentDayBtn = (DayViewCell *)sender;
    currentDayIndex = currentDayBtn.tag - 100;
    //如果这一次和上一次点击的是同一个，不做任何操作
    if(currentDayIndex == lastDayIndex)
        return;
    //更新日期一栏的视图约束
    [currentDayBtn mas_updateConstraints:^(MASConstraintMaker *make) {//当前
        make.width.mas_equalTo(dayViewCellWidth * 2);
    }];
    DayViewCell *lastDayBtn = [self.view viewWithTag:lastDayIndex + 100];//上一个
    [lastDayBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(dayViewCellWidth);
    }];
    //更新课程信息板块的视图约束
    UIView *curClassColumn = self.classSubViewArray[currentDayIndex];//当前列
    [curClassColumn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(dayViewCellWidth * 2);
    }];
    for (UIView *colView in [curClassColumn subviews]) {//获得按钮
        if ([colView isKindOfClass:[UIButton class]]) {
            CourseButton *subBtn = (CourseButton *)colView;
            subBtn.titleLabel.font = [UIFont systemFontOfSize:13];
            if (subBtn.type == 0) {//事务格子
                self.courseBtnName = [self insertLineFeedPerSixChar:[[NSMutableString alloc]initWithString:[subBtn.businessArray.firstObject desc]]];
                [subBtn setTitle:[[NSString alloc]initWithFormat:@"%@",self.courseBtnName] forState:UIControlStateNormal];
            }else if(subBtn.type == 1){//课程格子
                self.courseBtnName = [self insertLineFeedPerSixChar:[[NSMutableString alloc]initWithString:[subBtn.courseArray.firstObject courseName]]];
                self.courseBtnPlace = [self insertLineFeedPerSixChar:[[NSMutableString alloc]initWithFormat:@"@%@",[subBtn.courseArray.firstObject place]]];
                [subBtn setTitle:[[NSString alloc]initWithFormat:@"%@\n%@",self.courseBtnName,self.courseBtnPlace] forState:UIControlStateNormal];
            }
        }
//        for (UIView *view in [colView subviews]) {//获得按钮上的label
//            if ([view isKindOfClass:[UILabel class]]) {
//                UILabel *subview = (UILabel*) view;
//                subview.font = [UIFont systemFontOfSize:13];
//            }
//        }
    }
    UIView *lastClassColumn = self.classSubViewArray[lastDayIndex];//上一列
    [lastClassColumn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(dayViewCellWidth);
    }];
    for (UIView *colView in [lastClassColumn subviews]) {
        if ([colView isKindOfClass:[UIButton class]]) {
            CourseButton *subBtn = (CourseButton *)colView;
            subBtn.titleLabel.font = [UIFont systemFontOfSize:11];
            if (subBtn.type == 0) {//事务格子
                self.courseBtnName = [self insertLineFeedPerThreeChar:[[NSMutableString alloc]initWithString:[subBtn.businessArray.firstObject desc]]];
                [subBtn setTitle:[[NSString alloc]initWithFormat:@"%@",self.courseBtnName] forState:UIControlStateNormal];
            }else if (subBtn.type == 1){//课程格子
                self.courseBtnName = [self insertLineFeedPerThreeChar:[[NSMutableString alloc]initWithString:[subBtn.courseArray.firstObject courseName]]];
                self.courseBtnPlace = [self insertLineFeedPerThreeChar:[[NSMutableString alloc]initWithFormat:@"@%@",[subBtn.courseArray.firstObject place]]];
                [subBtn setTitle:[[NSString alloc]initWithFormat:@"%@\n%@",self.courseBtnName,self.courseBtnPlace] forState:UIControlStateNormal];
            }
        }
//        for (UIView *view in [colView subviews]) {
//            if ([view isKindOfClass:[UILabel class]]) {
//                UILabel *subview = (UILabel*) view;
//                subview.font = [UIFont systemFontOfSize:11];
//            }
//        }
    }
    
    lastDayIndex = currentDayIndex;    
    //更新底部indicator位置
    [UIView animateWithDuration:0.2 animations:^{
        [self.stripeView setFrame:CGRectMake(currentDayIndex *dayViewCellWidth , self.daysView.frame.size.height - 2, dayViewCellWidth *2, 2)];
    }];
}

- (void)dayAndClassRefresh:(NSDate *)date{
    [self classViewSetting];
    [self daysViewSetting:date];
}

- (void)bottomLineSetting{
    //底部灰线
    __weak typeof(self) weakself = self;
    UIView *bottomLine = [[UIView alloc]init];
    bottomLine.backgroundColor = [Utils colorWithHexString:@"#d9d9d9"];
    [self.view addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.view);
        make.bottom.equalTo(_topLeftView.mas_bottom);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(1);//或0.5
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (EventKitManager *)eventManager {
    if (_eventManager == nil) {
        _eventManager = [EventKitManager shareInstance];
    }
    return _eventManager;
}
- (DbManager *)dbManager {
    if (_dbManager == nil) {
        _dbManager = [DbManager shareInstance];
    }
    return _dbManager;
}

- (NSMutableArray *)allCourses{
    if (_allCourses == nil) {
        _allCourses = [NSMutableArray array];
    }
    return _allCourses;
}

- (NSMutableArray *)allBusiness{
    if (_allBusiness == nil) {
        _allBusiness = [NSMutableArray array];
    }
    return _allBusiness;
}

- (NSDate *)firstDateOfTerm{
    if (_firstDateOfTerm == nil) {
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        _firstDateOfTerm = [dateFormatter dateFromString:@"20170904"];
    }
    return _firstDateOfTerm;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
