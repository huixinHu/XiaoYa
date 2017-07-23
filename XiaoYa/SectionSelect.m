//
//  SectionSelect.m
//  XiaoYa
//
//  Created by commet on 16/11/28.
//  Copyright © 2016年 commet. All rights reserved.
//时间段（节）选择器

#import "SectionSelect.h"
#import "SectionSelectTableViewCell.h"
#import "NSDate+Calendar.h"
#import "DbManager.h"
#import "BusinessModel.h"
#import "CourseModel.h"
#import "DateUtils.h"
#import "Utils.h"
#import "EventKitManager.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width

@interface SectionSelect()<UITableViewDelegate,UITableViewDataSource,SectionSelectTableViewCellDelegate>
@property (nonatomic , weak) UIButton *confirm;
@property (nonatomic , weak) UIButton *cancel;
@property (nonatomic , weak) UILabel *weekdayLab;
@property (nonatomic , weak) UILabel *dateLab;
@property (nonatomic , weak) UITableView *multipleChoiceTable;
@property (nonatomic , weak) UIView *line1;//横灰线
@property (nonatomic , weak) UIView *line2;//竖灰线

@property (nonatomic ,strong) NSMutableArray *timeData;//时间数据
//timeData结构：储存可变字典，可变字典组成：key value:{time,时间}，{number,节数}，{eventDict,事件描述字典}
@property (strong, nonatomic) NSMutableArray *selectIndexs;//多选选中的行
@property (nonatomic ,strong) NSDate *selectedDate;//现在选择的日期
@property (nonatomic ,strong) NSMutableArray *originIndexs;//原选中的行
@property (nonatomic ,strong) NSDate *originDate;//原日期
@property (nonatomic ,strong) NSDate *firstDateOfTerm;//传入本学期第一天的日期
@property (nonatomic ,strong) EventKitManager *eventManager;
@end

@implementation SectionSelect
- (EventKitManager *)eventManager {
    if (_eventManager == nil) {
        _eventManager = [EventKitManager shareInstance];
    }
    return _eventManager;
}

- (instancetype)initWithFrame:(CGRect)frame sectionArr:(NSMutableArray* )sectionArray selectedDate:(NSDate*)date originIndexs:(NSMutableArray*)originIndexs originDate:(NSDate* )originDate termFirstDate:(NSDate*)firstDate
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10.0;
//        self.layer.masksToBounds = YES;

        _selectIndexs = [sectionArray mutableCopy];
        _selectedDate = date;
        _originDate = originDate;
        _originIndexs = [originIndexs mutableCopy];
        self.firstDateOfTerm = firstDate;
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
//    _confirm.backgroundColor = [UIColor whiteColor];
    [_confirm addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_confirm];
    
    UIButton *cancel = [[UIButton alloc]init];
    _cancel = cancel;
    [_cancel setTitle:@"取消" forState:UIControlStateNormal];
    [_cancel setTitleColor:[Utils colorWithHexString:@"#39b9f8"] forState:UIControlStateNormal];
    _cancel.titleLabel.font = [UIFont systemFontOfSize:13.0];
//    _cancel.backgroundColor = [UIColor whiteColor];
    [_cancel addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancel];
    
    UIView *line1 = [[UIView alloc]init];
    _line1 = line1;
    _line1.backgroundColor = [Utils colorWithHexString:@"#d9d9d9"];
    [self addSubview:_line1];
    
    UIView *line2 = [[UIView alloc]init];
    _line2 = line2;
    _line2.backgroundColor = [Utils colorWithHexString:@"#d9d9d9"];
    [self addSubview:_line2];
    
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
    UITableView *multipleChoiceTable = [[UITableView alloc]init];
    _multipleChoiceTable = multipleChoiceTable;
    _multipleChoiceTable.delegate = self;
    _multipleChoiceTable.dataSource = self;
    _multipleChoiceTable.separatorStyle = UITableViewCellSeparatorStyleNone;//去掉原生分割线
    _multipleChoiceTable.bounces = NO;
    [self addSubview:_multipleChoiceTable];
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    if ([_selectIndexs containsObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:indexPath.row]]]) {//是否是现选择的行？
        [cell.mutipleChoice setSelected:YES];
        NSMutableDictionary *dict = self.timeData[indexPath.row];
        NSMutableDictionary *eventDict = [dict objectForKey:@"eventDict"];
        if ([eventDict objectForKey:@"business"] != nil) {
            cell.conflict.hidden = NO;
        }else{
            cell.conflict.hidden = YES;
        }
        NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *comp1 = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self.selectedDate];
        NSDateComponents *comp2 = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self.originDate];
        if (comp1.year == comp2.year && comp1.month == comp2.month && comp1.day == comp2.day) {//没有更改过日期(1.直接改节，2.先改日期，再改节，再改回原来的日期)
            if ([_originIndexs containsObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:indexPath.row]]]){
                cell.conflict.hidden = YES;
            }
        }
    }else{
        [cell.mutipleChoice setSelected:NO];
        cell.conflict.hidden = YES;
    }
    return cell;
}

#pragma mark SectionSelectTableViewCellDelegate
- (void)SectionSelectTableViewCell:(SectionSelectTableViewCell *)cell selectIndex:(NSIndexPath *)indexPath{
    [self.selectIndexs addObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:indexPath.row]]];
    NSMutableDictionary *dict = self.timeData[indexPath.row];
    NSMutableDictionary *eventDict = [dict objectForKey:@"eventDict"];
    if ([eventDict objectForKey:@"business"] != nil) {
        cell.conflict.hidden = NO;
    }else{
        cell.conflict.hidden = YES;
    }
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp1 = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self.selectedDate];
    NSDateComponents *comp2 = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self.originDate];
    if (comp1.year == comp2.year && comp1.month == comp2.month && comp1.day == comp2.day) {//没有更改过日期(1.直接改节，2.先改日期，再改节，再改回原来的日期)
        if ([_originIndexs containsObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:indexPath.row]]]){
            cell.conflict.hidden = YES;
        }
    }
}

- (void)SectionSelectTableViewCell:(SectionSelectTableViewCell *)cell deSelectIndex:(NSIndexPath *)indexPath{
    [self.selectIndexs removeObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:indexPath.row]]];
}

//确定
- (void)confirmAction{
    [self removeFromSuperview];
    [self.delegate SectionSelectComfirmAction:self sectionArr:self.selectIndexs];
}

//取消,移除视图，什么也不做
- (void)cancelAction{
    [self removeFromSuperview];
    [self.delegate SectionSelectCancelAction:self];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _confirm.frame = CGRectMake(self.frame.size.width/2 , self.frame.size.height-38, self.frame.size.width/2, 38);
    _cancel.frame = CGRectMake(0, self.frame.size.height-38, self.frame.size.width/2, 38);
    _line1.frame = CGRectMake(0, self.frame.size.height-38, self.frame.size.width, 0.5);
    _line2.frame = CGRectMake(self.frame.size.width/2, self.frame.size.height-38, 0.5, 38);
    CGPoint center =  _confirm.center;
    
    _weekdayLab.frame = CGRectMake(0, 30 + 18 , 150, 30);
    center =  _weekdayLab.center;
    center.x = self.frame.size.width/2;
    _weekdayLab.center = center;
    
    _dateLab.frame = CGRectMake(0, 20, 150, 18);
    center =  _dateLab.center;
    center.x = self.frame.size.width/2;
    _dateLab.center = center;
    
    _multipleChoiceTable.frame = CGRectMake(0, 178/2, self.frame.size.width,245);
}

//- (void)drawRect:(CGRect)rect{
//    CGFloat width = self.frame.size.width;
//    CGFloat radius = 10;
//    UIBezierPath*path = [UIBezierPath bezierPath];
//    [path addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:M_PI endAngle:M_PI/2*3 clockwise:1];
//    [path moveToPoint:CGPointMake(radius, 0)];
//    [path addLineToPoint:CGPointMake(width - radius, 0)];
//    [path addArcWithCenter:CGPointMake(width - radius , radius) radius:radius startAngle:M_PI*3/2 endAngle:M_PI*2 clockwise:1];
//    [path addLineToPoint:CGPointMake(width, 178/2)];
//    [path addLineToPoint:CGPointMake(0 , 178/2)];
//    [path addLineToPoint:CGPointMake(0, radius)];
//    [path closePath];
//    UIColor *fillColor = [UIColor colorWithRed:57/255.0 green:185/255.0 blue:248/255.0 alpha:1.0];//39b9f8
//    [fillColor set];
//    [path fill];
//}
- (void)drawHeader{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(650 / 750.0 * kScreenWidth, 322), NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat width = 650 / 750.0 * kScreenWidth;;
    CGFloat radius = 10;
    UIBezierPath*path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:M_PI endAngle:M_PI/2*3 clockwise:1];
    [path moveToPoint:CGPointMake(radius, 0)];
    [path addLineToPoint:CGPointMake(width - radius, 0)];
    [path addArcWithCenter:CGPointMake(width - radius , radius) radius:radius startAngle:M_PI*3/2 endAngle:M_PI*2 clockwise:1];
    [path addLineToPoint:CGPointMake(width, 178/2)];
    [path addLineToPoint:CGPointMake(0 , 178/2)];
    [path addLineToPoint:CGPointMake(0, radius)];
    [path closePath];
    UIColor *fillColor = [UIColor colorWithRed:57/255.0 green:185/255.0 blue:248/255.0 alpha:1.0];//39b9f8
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
        for (int j = 0; j < eventArr.count ; j++) {
            BusinessModel *busModel = [[BusinessModel alloc] initWithEKevent:eventArr[j]];//转数据模型
            for (int k = 0; k < busModel.timeArray.count; k ++) {
                int index = [busModel.timeArray[k] intValue];
                NSMutableDictionary *dict = self.timeData[index];
                NSMutableDictionary *eventDict = [dict objectForKey:@"eventDict"];
                [eventDict setObject:busModel.desc forKey:@"business"];
            }
        }
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
        for (int j = 0; j < courseDataQuery.count; j++) {
            CourseModel *courseMDL = [[CourseModel alloc]initWithDict:courseDataQuery[j]];
            for (int k = 0; k < courseMDL.timeArray.count; k++) {
                int index = [courseMDL.timeArray[k] intValue];
                NSMutableDictionary *dict = self.timeData[index];
                NSMutableDictionary *courseDict = [dict objectForKey:@"eventDict"];
                [courseDict setObject:courseMDL.courseName forKey:@"course"];
            }
        }
    }

}

@end
