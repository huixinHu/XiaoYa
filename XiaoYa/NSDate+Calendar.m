//
//  NSDate+Calendar.m
//  rsaTest
//
//  Created by commet on 16/11/16.
//  Copyright © 2016年 commet. All rights reserved.
//

#import "NSDate+Calendar.h"

@implementation NSDate (Calendar)
-(NSUInteger)numberOfDaysInCurrentMonth{
    //ios8以前写的是NSDayCalendarUnit
    return [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self].length;
}

- (NSDate *)firstDayOfCurrentMonth
{
    NSDate *startDate = nil;
    BOOL ok = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitMonth startDate:&startDate interval:NULL forDate:self];
    NSAssert1(ok, @"Failed to calculate the first day of the month based on %@", self);
    return startDate;
}

//周几，1表示周日，2表示周一
- (int)dayOfWeek{
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday) fromDate:self];
    int weekday = (int)[weekdayComponents weekday];
//    转本地时区
//    NSDate *date = [gregorian dateFromComponents:weekdayComponents];
//    NSTimeZone *zone = [NSTimeZone systemTimeZone];
//    NSInteger interval = [zone secondsFromGMTForDate:date];
//    NSDate *localeDate = [date dateByAddingTimeInterval:interval];
//    NSLog(@"%@",localeDate);

    return weekday;
}

//某天是星期几，中文的形式
- (NSString *)dayOfCHNWeek{
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday) fromDate:self];
    int weekday = (int)[weekdayComponents weekday];
    
    NSString * dayStr;
    switch (weekday) {
        case 1:
            dayStr = @"日";
            break;
        case 2:
            dayStr = @"一";
            break;
        case 3:
            dayStr = @"二";
            break;
        case 4:
            dayStr = @"三";
            break;
        case 5:
            dayStr = @"四";
            break;
        case 6:
            dayStr = @"五";
            break;
        case 7:
            dayStr = @"六";
            break;
        default:
            break;
    }
    return dayStr;
}

@end
