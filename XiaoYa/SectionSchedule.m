//
//  SectionSchedule.m
//  XiaoYa
//
//  Created by commet on 2017/9/5.
//  Copyright © 2017年 commet. All rights reserved.
//当天日程视图

#import "SectionSchedule.h"
#import "EventKitManager.h"
#import "DbManager.h"
#import "DateUtils.h"
#import "NSDate+Calendar.h"
#import "Utils.h"
#import "AppDelegate.h"
#import "SectionSelectTableViewCell.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width

@interface SectionSchedule()<UITableViewDelegate ,UITableViewDataSource>
@property (nonatomic , weak) UIButton *confirm;
@property (nonatomic , weak) UILabel *weekdayLab;
@property (nonatomic , weak) UILabel *dateLab;
@property (nonatomic , weak) UITableView *scheduleTable;
@property (nonatomic , weak) UIView *line1;//横灰线

@property (nonatomic ,strong) NSMutableArray *timeData;//时间数据
@property (nonatomic ,strong) EventKitManager *eventManager;
@property (nonatomic ,strong) NSDate *selectedDate;//现在选择的日期
@property (nonatomic ,strong) NSDate *firstDateOfTerm;
@property (nonatomic ,strong) NSArray *timeSrartArray;
@property (nonatomic ,strong) NSArray *timeEndArray;
@property (nonatomic ,copy) confirmBlock scheduleConfirm;
@end

@implementation SectionSchedule
- (EventKitManager *)eventManager {
    if (_eventManager == nil) {
        _eventManager = [EventKitManager shareInstance];
    }
    return _eventManager;
}

- (instancetype)initWithFrame:(CGRect)frame selectedDate:(NSDate*)date confirmBlock:(confirmBlock)confirm{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10.0;
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.firstDateOfTerm = appDelegate.firstDateOfTerm;
        self.selectedDate = date;
        self.scheduleConfirm = [confirm copy];
        [self timeDataInit];
        [self drawHeader];
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    UIButton *confirm = [[UIButton alloc]init];
    _confirm = confirm;
    [_confirm setTitle:@"确认" forState:UIControlStateNormal];
    [_confirm setTitleColor:[Utils colorWithHexString:@"#39b9f8"] forState:UIControlStateNormal];
    _confirm.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [_confirm addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_confirm];
    
    UIView *line1 = [[UIView alloc]init];
    _line1 = line1;
    _line1.backgroundColor = [Utils colorWithHexString:@"#d9d9d9"];
    [self addSubview:_line1];
    
    NSString *daystr = [self.selectedDate dayOfCHNWeek];
    UILabel *weekdayLab = [[UILabel alloc]init];
    _weekdayLab = weekdayLab;
    _weekdayLab.textAlignment = NSTextAlignmentCenter;
    _weekdayLab.text = [NSString stringWithFormat:@"星期%@",daystr];
    _weekdayLab.textColor = [UIColor whiteColor];
    _weekdayLab.font = [UIFont systemFontOfSize:30.0];
    [self addSubview:_weekdayLab];
    
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *curDateComp = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self.selectedDate];
    NSInteger month = curDateComp.month;
    NSInteger day = curDateComp.day;
    UILabel *dateLab = [[UILabel alloc]init];
    _dateLab = dateLab;
    _dateLab.textAlignment = NSTextAlignmentCenter;
    _dateLab.text = [NSString stringWithFormat:@"%@月%@号",[NSNumber numberWithInteger:month],[NSNumber numberWithInteger:day]];
    _dateLab.textColor = [UIColor whiteColor];
    _dateLab.font = [UIFont systemFontOfSize:18.0];
    [self addSubview:_dateLab];
    
    //单元格固定高度39；5行
    UITableView *scheduleTable = [[UITableView alloc]init];
    _scheduleTable = scheduleTable;
    _scheduleTable.delegate = self;
    _scheduleTable.dataSource = self;
    _scheduleTable.separatorStyle = UITableViewCellSeparatorStyleNone;//去掉原生分割线
    _scheduleTable.bounces = NO;
    [self addSubview:_scheduleTable];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.timeData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SectionSelectTableViewCell *cell = [SectionSelectTableViewCell SectionCellWithTableView:tableView];
    cell.model = self.timeData[indexPath.row];
    cell.mutipleChoice.hidden = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

//确定
- (void)confirmAction{
    self.scheduleConfirm();
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _confirm.frame = CGRectMake(0, self.frame.size.height-38, self.frame.size.width, 38);
    _line1.frame = CGRectMake(0, self.frame.size.height-38, self.frame.size.width, 0.5);
    CGPoint center =  _confirm.center;
    
    _weekdayLab.frame = CGRectMake(0, 30 + 18 , 150, 30);
    center =  _weekdayLab.center;
    center.x = self.frame.size.width/2;
    _weekdayLab.center = center;
    
    _dateLab.frame = CGRectMake(0, 20, 150, 18);
    center =  _dateLab.center;
    center.x = self.frame.size.width/2;
    _dateLab.center = center;
    
    _scheduleTable.frame = CGRectMake(0, 178/2, self.frame.size.width,245);
}

- (void)drawHeader{
    CGFloat width = self.frame.size.width;
    CGFloat height = 178/2;
    CGFloat radius = 10;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    UIBezierPath*path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:M_PI endAngle:M_PI/2*3 clockwise:1];
    [path moveToPoint:CGPointMake(radius, 0)];
    [path addLineToPoint:CGPointMake(width - radius, 0)];
    [path addArcWithCenter:CGPointMake(width - radius , radius) radius:radius startAngle:M_PI*3/2 endAngle:M_PI*2 clockwise:1];
    [path addLineToPoint:CGPointMake(width, height)];
    [path addLineToPoint:CGPointMake(0 , height)];
    [path addLineToPoint:CGPointMake(0, radius)];
    [path closePath];
    UIColor *fillColor = [Utils colorWithHexString:@"#39b9f8"];
    [fillColor set];
    [path fill];
    
    CGContextAddPath(ctx, path.CGPath);
    UIImage * getImage = UIGraphicsGetImageFromCurrentImageContext();
    [self addSubview:[[UIImageView alloc]initWithImage:getImage]];
    UIGraphicsEndImageContext();
}

- (void)timeDataInit{
    NSArray *timeData = @[@[@"早间",@""],@[@"8:00",@"1"],@[@"8:55",@"2"],@[@"10:00",@"3"],@[@"10:55",@"4"],@[@"午间",@""],@[@"14:30",@"5"],@[@"15:25",@"6"],@[@"16:20",@"7"],@[@"17:15",@"8"],@[@"18:10",@"9"],@[@"19:00",@"10"],@[@"19:55",@"11"],@[@"20:50",@"12"],@[@"晚间",@""]];
    self.timeData = [NSMutableArray arrayWithCapacity:15];
    for (int i =0; i < 15; i ++) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
        [dict setObject:timeData[i][0] forKey:@"time"];
        [dict setObject:timeData[i][1] forKey:@"number"];
        [dict setObject:[NSMutableDictionary dictionary] forKey:@"eventDict"];
        [self.timeData addObject:dict];
    }
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *dateString = [dateFormatter stringFromDate:_selectedDate];
    NSArray *eventArr = [self.eventManager checkEventWithDateString:@[dateString] startSection:@"0" endSection:@"14"];
    if (eventArr.count > 0) {
        [eventArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            EKEvent *eke = (EKEvent *)obj;
            NSArray *timeArr = [self convertTimeFromEKEvent:eke];
            [timeArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                int index = [obj intValue];
                NSMutableDictionary *dict = self.timeData[index];
                NSMutableDictionary *eventDict = [dict objectForKey:@"eventDict"];
                [eventDict setObject:eke.title forKey:@"business"];
            }];
        }];
    }
    
    DbManager *dbManger = [DbManager shareInstance];
    NSInteger curDateDistance = [DateUtils dateDistanceFromDate:self.selectedDate toDate:self.firstDateOfTerm];//当前日期距离学期第一天的天数
    NSInteger curWeek = curDateDistance / 7;//当前周
    int weekday = [self.selectedDate dayOfWeek];
    if (weekday == 1) {
        weekday = 6;
    }else{
        weekday = weekday - 2;
    }
    NSString *sql2 =[NSString stringWithFormat:@"SELECT * FROM course_table WHERE weeks LIKE '%%,%@,%%' and weekday = '%d';",[NSNumber numberWithInteger:curWeek],weekday];
    NSArray *courseDataQuery = [dbManger executeQuery:sql2];
    if (courseDataQuery.count > 0) {
        [courseDataQuery enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *courseDict = (NSDictionary *)obj;
            NSString *time = [courseDict objectForKey:@"time"];
            NSArray *timeArray = [NSMutableArray array];
            if (time.length != 0) {
                NSString *subTimeStr = [time substringWithRange:NSMakeRange(1, time.length - 2)];//截去头尾“,”
                NSArray * tempArray = [subTimeStr componentsSeparatedByString:@","];//以“,”切割
                timeArray = [tempArray mutableCopy];
            }
            [timeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                int index = [obj intValue];
                NSMutableDictionary *dict = self.timeData[index];
                NSMutableDictionary *eventDict = [dict objectForKey:@"eventDict"];
                [eventDict setObject:[courseDict objectForKey:@"courseName"] forKey:@"course"];
            }];
        }];
    }
}


- (NSArray *)convertTimeFromEKEvent:(EKEvent *)event{
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyyMMddHHmm"];
    
    NSString *startDate = [df stringFromDate:event.startDate];
    NSString *endDate = [df stringFromDate:event.endDate];

    NSString *startTime = [startDate substringWithRange:NSMakeRange(startDate.length - 4, 4)];//截取后四位，就是事件发生的时分字符串
    NSString *endTime = [endDate substringWithRange:NSMakeRange(endDate.length - 4, 4)];
    NSUInteger startSection = [self.timeSrartArray indexOfObject:startTime];
    NSUInteger endSection = [self.timeEndArray indexOfObject:endTime];
    NSMutableArray *timeArray = [NSMutableArray array];
    [timeArray addObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithUnsignedInteger:startSection]]];
    if (startSection < endSection) {
        for (; startSection < endSection; startSection++) {
            [timeArray addObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithUnsignedInteger:startSection + 1]]];
        }
    }
    return timeArray;
}

- (NSArray *)timeSrartArray{
    if (_timeSrartArray == nil) {
        _timeSrartArray = @[@"0600",@"0800",@"0855",@"1000",@"1055",@"1140",@"1430",@"1525",@"1620",@"1715",@"1810",@"1900",@"1955",@"2050",@"2200"];
    }
    return _timeSrartArray;
}

- (NSArray *)timeEndArray{
    if (_timeEndArray == nil) {
        _timeEndArray = @[@"0759",@"0854",@"0959",@"1054",@"1139",@"1429",@"1524",@"1619",@"1714",@"1809",@"1854",@"1954",@"2049",@"2144",@"2359"];
    }
    return _timeEndArray;
}

@end
