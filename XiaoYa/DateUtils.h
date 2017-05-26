//
//  DateUtils.h
//  Course
//
//  Created by MacOS on 14-12-17.
//  Copyright (c) 2014年 Joker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtils : NSObject

//获取传入日期的周日期数组
+ (NSArray *)getDatesOfCurrence:(NSDate *)currentDate;

//获取距本周多少个周的日期数组,参数为1就代表下周，参数为2就是下下周，参数为-1就是上周
+ (NSArray *)getDatesSinceCurence:(int)weeks;

//utc转北京时间
+ (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate;

//日历有多少行
+ (int)rowNumber:(NSDate*)currentDate;

//“第x周”有几行
+ (int)rowOfWeek:(NSDate* )currentDate;

//获取两个日期之间间隔的天数。参数1：较近的日期 参数2：较远的日期
+ (NSInteger)dateDistanceFromDate:(NSDate *)startDate toDate:(NSDate *)endDate;

//第n周周一是几号 参数1：第几周 参数2：本学期第一天是几号
+ (NSDate *)dateOfWeekMonday:(NSInteger)week firstDateOfTrem:(NSDate*)termFirstDate;
@end
