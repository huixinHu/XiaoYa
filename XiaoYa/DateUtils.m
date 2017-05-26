//
//  DateUtils.m
//  Course
//
//  Created by MacOS on 14-12-17.
//  Copyright (c) 2014年 Joker. All rights reserved.
//

#import "DateUtils.h"
#import "NSDate+Calendar.h"
@implementation DateUtils

//获取传入日期的周日期数组
+ (NSArray *)getDatesOfCurrence:(NSDate *)currentDate
{
//    NSDate *now = [NSDate date];//当前日期
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2]; //1代表周日，2代表周一
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:currentDate];
    NSInteger curWeekDay = [components weekday];//当前周几
    NSInteger curDay = [components day];//当前几号
    NSInteger curMonth = [components month];//当前月份
    NSInteger curYear = [components year];//当前年份
    NSInteger dayNumofCurMonth = [currentDate numberOfDaysInCurrentMonth];//获得当前月有多少天
    
    // 计算当前日期和这周的星期一差的天数
    NSInteger monDelta;
    if (curWeekDay == 1) {//当前是周日
        monDelta = 1-7;
    }else{
        monDelta = [calendar firstWeekday] - curWeekDay;
    }
    // 计算当前日期和这周的星期天差的天数
    NSInteger sunDelta;
    if (curWeekDay == 1) {//当前是周日
        sunDelta = 0;
    }else{
        sunDelta = 6 + monDelta;
    }
    
    NSInteger monday = curDay + monDelta;//这周周一几号
    NSInteger sunday = curDay + sunDelta;//这周周日几号
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:7];//二维数组，第二维存放年月日数组
    NSString *curYearStr = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:curYear]];
    NSString *curMonthStr = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:curMonth]];
    //如果这周周日的日期超过本月天数
    if (sunday > dayNumofCurMonth)
    {
        NSString *nextYearStr;
        NSString *nextMonthStr;
        if (curMonth + 1 > 12) {
            nextMonthStr = @"1";
            nextYearStr = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:curYear+1]];
        }else{
            nextMonthStr = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:curMonth+1]];
            nextYearStr = curYearStr;
        }
        int i;
        for (i = 0; i < 7; i++) {//本月
            if (monday + i <= dayNumofCurMonth) {
                [array addObject:@[curYearStr,curMonthStr,[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:monday + i]]]];
            }else{
                break;
            }
        }
        int a = i;//上一个for break时候的i值
        for (; i < 7; i++) {//下个月
            [array addObject:@[nextYearStr,nextMonthStr,[NSString stringWithFormat:@"%d",i-a+1]]];
        }
    }
    //如果这周周一的日期为负值，代表在上一个月
    if (monday <= 0) {
        NSDate *preMonthDate = [self getPreviousfromDate:currentDate];//获得上月一号的日期
        NSInteger dayNumOfPreMonth = [preMonthDate numberOfDaysInCurrentMonth];//获得上月有多少天
        int firstDateWeekday = [[currentDate firstDayOfCurrentMonth] dayOfWeek];//本月第一天是周几
        NSInteger curMonday = dayNumOfPreMonth - firstDateWeekday + 2;//本周周一是几号
        NSString *preYearStr;
        NSString *preMonthStr;
        if (curMonth - 1 <= 0) {
            preMonthStr = @"12";
            preYearStr = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:curYear-1]];
        }else{
            preMonthStr = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:curMonth-1]];
            preYearStr = curYearStr;
        }
        int i;
        for (i = 0; i < 7; i++) {//上月
            if (curMonday + i <= dayNumOfPreMonth) {
                [array addObject:@[preYearStr,preMonthStr,[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:monday + i]]]];
            }else{
                break;
            }
        }
        int a = i;//上一个for break时候的i值
        for (; i < 7; i++) {//本月
            [array addObject:@[curYearStr,curMonthStr,[NSString stringWithFormat:@"%d",i-a+1]]];
        }
    }
    if(monday > 0 && sunday <= dayNumofCurMonth){
        for (int i = 0; i < 7; i++) {
            [array addObject:@[curYearStr,curMonthStr,[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:monday + i]]]];
        }
    }
    return array;
}

//获取距离当前多少周的日期数组
+ (NSArray *)getDatesSinceCurence:(int)weeks
{
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:weeks*7*24*60*60];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2]; //1代表周日，2代表周一
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:now];
    NSInteger weekDay = [components weekday];
    // 得到几号
    NSInteger day = [components day];
    
    // 计算当前日期和这周的星期一和星期天差的天数
    long firstDiff,lastDiff;
    if (weekDay == 1) {
        firstDiff = 1;
        lastDiff = 7;
    }else{
        firstDiff = [calendar firstWeekday] - weekDay;
        lastDiff = 8 - weekDay;
    }
    
    // 在当前日期(去掉了时分秒)基础上加上差的天数
    NSDateComponents *firstDayComp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    [firstDayComp setDay:day + firstDiff];
    
    NSString *month = [NSString stringWithFormat:@"%@月",[NSNumber numberWithInteger:[firstDayComp month]]];
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:8];
    [array addObject:month];
    for (int i = 0; i< 7; i++) {
        [components setDay:[firstDayComp day] + i];
        NSDate *everyDate = [calendar dateFromComponents:components];
        NSDateComponents *everCom = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:everyDate];
        [array addObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:[everCom day]]]];
    }
    
    return array;
}

//utc转北京时间。时区修正(如果不是需要精确到时分秒的时间就不需要调用这个方法)
+ (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
}

//日历有多少行
+ (int)rowNumber:(NSDate*)currentDate{
    //获取当前月有多少天
    int dayNumOfCurMonth = (int)[currentDate numberOfDaysInCurrentMonth];
    //获取当前月第一天的日期
    NSDate * firstDate = [currentDate firstDayOfCurrentMonth];
//    NSDate *firstDate = [DateUtils getNowDateFromatAnDate:[currentDate firstDayOfCurrentMonth]];
    //确定这一天是周几
    int weekday = [firstDate dayOfWeek];
    //确定创建多少行
    int calendarRow = 0;
    int tmp = dayNumOfCurMonth;
    if (weekday != 1) {//不是周日
        calendarRow ++;
        tmp = dayNumOfCurMonth - ( 7 - (weekday - 1));
    }
    calendarRow += tmp / 7;
    calendarRow += ( tmp % 7 ) ? 1 : 0;
    return calendarRow;
}

//“第x周”有几行
+ (int)rowOfWeek:(NSDate* )currentDate{
    //获取当前月有多少天
    int dayNumOfCurMonth = (int)[currentDate numberOfDaysInCurrentMonth];
    //获取当前月第一天的日期
    NSDate * firstDate = [currentDate firstDayOfCurrentMonth];
    //确定这一天是周几
    int weekday = [firstDate dayOfWeek];
    //确定创建多少行
    int weekRow = 0;
    int tmp = dayNumOfCurMonth;
    if (weekday != 1) {//不是周日
        weekRow ++;
        tmp = dayNumOfCurMonth - ( 7 - (weekday - 1));
    }
    weekRow += tmp / 7;
    weekRow += ( tmp % 7 > 1) ? 1 : 0;//如果余两天以上，即日历最后一行的周一在这个月而不是下个月
    return weekRow;
}

//上个月一号的日期
+ (NSDate *)getPreviousfromDate:(NSDate *)date{
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    components.day = 1;
    components.month --;
    if (components.month <= 0) {
        components.month = 12;
        components.year --;
    }
    NSDate * previousMonthDate = [gregorian dateFromComponents:components];
    return previousMonthDate;
}

//获取两个日期之间间隔的天数。参数1：较近的日期 参数2：较远的日期
+ (NSInteger)dateDistanceFromDate:(NSDate *)startDate toDate:(NSDate *)endDate{
    int timediff = [startDate timeIntervalSince1970]-[endDate timeIntervalSince1970];
    int day = timediff / (24 * 3600);
    return day;
}

//第n周周一是几号 参数1：第几周,从0开始  参数2：本学期第一天是几号
+ (NSDate *)dateOfWeekMonday:(NSInteger)week firstDateOfTrem:(NSDate*)termFirstDate{
    NSDate* theDate;
    NSTimeInterval oneDay = 24*60*60*1;  //1天的长度
    theDate = [termFirstDate dateByAddingTimeInterval:oneDay * 7 * week ];//initWithTimeIntervalSinceNow是从现在往前后推的秒数
    return theDate;
}
@end
