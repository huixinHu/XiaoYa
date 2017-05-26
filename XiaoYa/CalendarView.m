//
//  CalendarView.m
//  rsaTest
//
//  Created by commet on 16/11/16.
//  Copyright © 2016年 commet. All rights reserved.
//日历

#import "CalendarView.h"
#import "NSDate+Calendar.h"
#import "DateUtils.h"

@interface CalendarView()
//当前日期
@property (nonatomic ,strong) NSDate *currentDate;
@property (nonatomic , strong) NSDate *firstDateOfTerm;//传入本学期第一天的日期
@end

@implementation CalendarView
{
    NSDate * today;
    CGFloat weekWidth;//“第几周”label宽度
    CGFloat cellWidth;//“日期”btn高度、宽度
}

- (instancetype)initWithFrame:(CGRect)frame date:(NSDate*)currentDate firstDateOfTerm:(NSDate *)firstDateOfTerm{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        weekWidth = 50;
        cellWidth = 38;

        _currentDate = currentDate;
        self.firstDateOfTerm = firstDateOfTerm;
//        today = [DateUtils getNowDateFromatAnDate:[NSDate date]];
        today = [NSDate date];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    NSArray * subviewArr = [self subviews];
    for (UIView * v in subviewArr) {
        [v removeFromSuperview];
    }
    
    NSArray * weekArray = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    for (int i = 0 ; i < weekArray.count ; i++) {
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(weekWidth + i * cellWidth, 0, cellWidth , cellWidth)];
        label.text = weekArray[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:17.0];
        label.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];//333333
        [self addSubview:label];
    }
    [self creatViewWithData:_currentDate];
}

//参数类型待定,左侧“第几周”未实现
-(void)creatViewWithData:(NSDate*)currentDate{
    int calendarRow = [DateUtils rowNumber:currentDate];
    int dayNumOfCurMonth = (int)[currentDate numberOfDaysInCurrentMonth];
//    NSDate *firstDate = [DateUtils getNowDateFromatAnDate:[currentDate firstDayOfCurrentMonth]];
    NSDate *firstDate = [currentDate firstDayOfCurrentMonth];
    int weekday = [firstDate dayOfWeek];
    
    //    NSArray * array = [bodyView subviews];
    //    for (UIView * v in array) {
    //        [v removeFromSuperview];
    //    }
    
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *curDateComp = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:currentDate];
    NSDateComponents *todayComp = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:today];
    
    int nextMonthDate = 1;//下个月第一天
    for (int i = 0 ; i < calendarRow ; i ++){
        for (int j = 0 ; j < 7; j++) {
            //上月剩余天
            if (weekday != 1 && (i * 7 + j) < weekday - 1) {
                NSDate *preMonthDate = [self getPreviousfromDate:currentDate];//获得上月一号的日期
//                NSDate *preMonthDate = [DateUtils getNowDateFromatAnDate:[self getPreviousfromDate:currentDate]];
                int dayNumOfPreMonth = (int)[preMonthDate numberOfDaysInCurrentMonth];//获得上月有多少天
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(weekWidth + j * cellWidth, cellWidth, cellWidth, cellWidth)];
                label.textAlignment = NSTextAlignmentCenter;
                label.text = [NSString stringWithFormat:@"%d",dayNumOfPreMonth - weekday + 2 +j];
                label.font = [UIFont systemFontOfSize:14.0];
                label.textColor = [UIColor colorWithRed:217/255.0 green:217/255.0 blue:217/255.0 alpha:1.0];//d9d9d9
                [self addSubview:label];
            }
            //本月
            else if((i * 7 + j - (weekday == 1 ? 0 : weekday -  1) + 1) <= dayNumOfCurMonth){
                UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(weekWidth + j * cellWidth, cellWidth * (i + 1), cellWidth, cellWidth)];
                btn.tag = 100 + (i*7+j-(weekday==1?0:weekday-1)+1);//从101开始
                [btn setTitle:[NSString stringWithFormat:@"%d",(i*7+j-(weekday==1?0:weekday-1)+1)] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0] forState:UIControlStateNormal];//666666
                [btn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0] forState:UIControlStateSelected];//333333
                UIImage *selectedImg = [UIImage imageNamed:@"dateSelected"];
                [btn setBackgroundImage:selectedImg forState:UIControlStateSelected];
                btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
                [self addSubview:btn];
                //标出今天
                if (curDateComp.year == todayComp.year && curDateComp.month == todayComp.month && (i*7+j-(weekday==1?0:weekday-1)+1) == todayComp.day) {
                    [btn setTitleColor:[UIColor colorWithRed:28/255.0 green:195/255.0 blue:162/255.0 alpha:1.0] forState:UIControlStateNormal];//1cc3a2
                }
                //标出默认选中
                if ((i*7+j-(weekday==1?0:weekday-1)+1) == curDateComp.day) {
                    btn.selected = YES;
                    _btnClickedTag = btn.tag;
                }
                [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
            }
            //下月直接从1，2..开始
            else{
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(weekWidth + j * cellWidth, cellWidth * (i + 1), cellWidth, cellWidth)];
                label.textAlignment = NSTextAlignmentCenter;
                label.text = [NSString stringWithFormat:@"%d",nextMonthDate++];
                label.font = [UIFont systemFontOfSize:14.0];
                label.textColor = [UIColor colorWithRed:217/255.0 green:217/255.0 blue:217/255.0 alpha:1.0];//d9d9d9
                [self addSubview:label];
            }
//            _btnClickedTag = 101;
        }
    }
    
    //计算每月1号是第几周，之后本月其余周依次递增即可
    //如果当月1号是周日，那么从当月2号开始算
    if(weekday == 1){
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorian components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:firstDate];
        components.day ++;
//        [components setDay:([components day]+1)];
        firstDate = [gregorian dateFromComponents:components];
    }
    NSInteger dateDistance = [DateUtils dateDistanceFromDate:firstDate toDate:self.firstDateOfTerm];
    NSInteger week = dateDistance / 7 + 1;
    int weekRow = [DateUtils rowOfWeek:currentDate];
    for (int i = 0; i <weekRow; i ++) {
        if (week + i < 1 || week + i > 24) {
            continue;
        }
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, cellWidth * (i + 1), weekWidth, cellWidth)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"第%@周",[NSNumber numberWithInteger:week + i]];
        label.font = [UIFont systemFontOfSize:14.0];
        label.textColor = [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:0.8];//4d4d4d
        [self addSubview:label];
    }
}

- (void)clickBtn:(id)sender{
    [self singleChoice:sender];
}

//日期单选
- (void)singleChoice:(id)sender{
    UIButton *lastBtn = (UIButton *)[self viewWithTag:_btnClickedTag];
    UIButton *selectedBtn = (UIButton *)[self viewWithTag:[sender tag]];
    if (lastBtn == selectedBtn) {
        return;
    }
    if (_btnClickedTag != 0)
    {
        lastBtn.selected = NO;
        lastBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    }
    _btnClickedTag = selectedBtn.tag;
    selectedBtn.selected = YES;
    selectedBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
}

//上个月一号的日期
- (NSDate *)getPreviousfromDate:(NSDate *)date{
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    components.day = 1;
    components.month --;
    if (components.month <= 0) {
        components.month = 12;
        components.year --;
    }
    NSDate * previousMonthDate =[gregorian dateFromComponents:components];
    return previousMonthDate;
}
@end
