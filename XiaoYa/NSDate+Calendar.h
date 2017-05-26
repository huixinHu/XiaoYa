//
//  NSDate+Calendar.h
//  rsaTest
//
//  Created by commet on 16/11/16.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Calendar)
/**
 *获取当前月的天数
 */
- (NSUInteger)numberOfDaysInCurrentMonth;
/**
 *获取本月第一天
 */
- (NSDate *)firstDayOfCurrentMonth;

/**
 *确定某天是周几.1是周日，2是周一
 */
- (int)dayOfWeek;

//某天是星期几，中文的形式
- (NSString *)dayOfCHNWeek;
@end
