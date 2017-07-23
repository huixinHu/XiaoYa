//
//  Utils.m
//  XiaoYa
//
//  Created by commet on 16/10/16.
//  Copyright © 2016年 commet. All rights reserved.
//

#import "Utils.h"
#import "NSDate+Calendar.h"
@implementation Utils
#pragma mark - 颜色转换 IOS中十六进制的颜色转换为UIColor
+ (UIColor *)colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

//事务节数分割连续段，连续的分为一组
+ (NSMutableArray*)subSectionArraysFromArray:(NSMutableArray *)sectionArray{
    if (sectionArray.count == 0) {
        return [NSMutableArray array];
    }
    NSMutableArray *sections = [NSMutableArray array];
    NSInteger count = sectionArray.count;
    int sectionCount = 1;
    if (count != 1){
        int i = 1;
        for (; i < count; i++) {
            NSString *num1 = (NSString*)sectionArray[i-1];
            NSString *num2 = (NSString*)sectionArray[i];
            if ([num1 intValue] != [num2 intValue] - 1) {
                sectionCount ++;
            }
        }
    }
    if (sectionCount == 1) {
        [sections addObject:sectionArray];
    }else{
        int i = 0;
        for (int k = 0; k < sectionCount; k ++) {
            NSMutableArray *temp = [NSMutableArray array];
            for (; i < count-1; i++) {
                NSString *num1 = (NSString*)sectionArray[i];
                NSString *num2 = (NSString*)sectionArray[i+1];
                if ([num1 intValue] == [num2 intValue] - 1) {
                    [temp addObject:num1];
                }
                else{
                    [temp addObject:num1];
                    [sections addObject:temp];
                    i++;
                    break;
                }
            }
            if (k == sectionCount - 1) {
                [temp addObject:sectionArray[count-1]];
                [sections addObject:temp];
            }
        }
    }
    return sections;
}

//返回日期数组，元素储存格式yyyymmdd。参数1：起始日期；参数2：持续时间，以年为单位;参数3：重复项。
+ (NSMutableArray *)dateStringArrayFromDate:(NSDate *)currentDate yearDuration:(int)yearDuration repeatIndex:(NSInteger)repeat{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:currentDate];
    NSString *currentDateStr = [dateFormatter stringFromDate:currentDate];
    
    NSMutableArray *dateString = [NSMutableArray arrayWithCapacity:5];
    switch (repeat) {
        case 0://每天
            [dateString addObject:currentDateStr];
            for (int i = 1; i < yearDuration * 365; i ++) {
                components.day += 1;
                NSDate *tempDate = [gregorian dateFromComponents:components];
                [dateString addObject:[dateFormatter stringFromDate:tempDate]];
            }
            break;
        case 1://每两天
            [dateString addObject:currentDateStr];
            for (int i = 1; i < yearDuration * 365 / 2; i ++) {
                components.day += 2;
                NSDate *tempDate = [gregorian dateFromComponents:components];
                [dateString addObject:[dateFormatter stringFromDate:tempDate]];
            }
            break;
        case 2://每周
            [dateString addObject:currentDateStr];
            for (int i = 1; i < yearDuration * 52; i ++) {
                components.day += 7;
                NSDate *tempDate = [gregorian dateFromComponents:components];
                [dateString addObject:[dateFormatter stringFromDate:tempDate]];
            }
            break;
        case 3://每月
            [dateString addObject:currentDateStr];
            for (int i = 1; i < yearDuration * 12; i ++) {
                components.month += 1;
                NSDate *tempDate = [gregorian dateFromComponents:components];
                NSDateComponents *components1 = [gregorian components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:tempDate];
                if(components1.day != components.day){
                    continue;
                }else{
                    [dateString addObject:[dateFormatter stringFromDate:tempDate]];
                }
            }
            break;
        case 4://每年
            [dateString addObject:currentDateStr];
            if (components.month == 2 && components.day == 29) {//保存的这一天是闰日
                components.year += 4;//判断四年后还是不是闰年
                NSDate * tempDate = [gregorian dateFromComponents:components];//加一年后的日期,如果刚好是闰年，就会变成2016.2.29 -》2017.2.29=2017.3.1
                NSDateComponents *components1 = [gregorian components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:tempDate];
                if(components1.month == components.month){//如果四年后还是闰年
                    [dateString addObject:[dateFormatter stringFromDate:tempDate]];
                }
            }else{//2月29以外的任何日期
                for (int i = 1; i < yearDuration; i ++) {
                    components.year += 1;
                    NSDate * tempDate = [gregorian dateFromComponents:components];
                    [dateString addObject:[dateFormatter stringFromDate:tempDate]];
                }
            }
            break;
        case 5://工作日
            [dateString addObject:currentDateStr];
            for (int i = 1; i < yearDuration * 365; i ++) {
                components.day += 1;
                NSDate *tempDate = [gregorian dateFromComponents:components];
                int weekday = [tempDate dayOfWeek];//1表示周日，2表示周一
                if (weekday > 1 && weekday < 7) {
                    [dateString addObject:[dateFormatter stringFromDate:tempDate]];
                }
            }
            break;
        case 6://不重复
            [dateString addObject:currentDateStr];
            break;
        default:
            break;
    }
    return dateString;
}

//判断手机号码格式是否正确
+ (BOOL)validMobile:(NSString *)mobile
{
    mobile = [mobile stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (mobile.length != 11)
    {
        return NO;
    }else{
        /**
         * 移动号段正则表达式
         */
        NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
        /**
         * 联通号段正则表达式
         */
        NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
        /**
         * 电信号段正则表达式
         */
        NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
        BOOL isMatch1 = [pred1 evaluateWithObject:mobile];
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
        BOOL isMatch2 = [pred2 evaluateWithObject:mobile];
        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
        BOOL isMatch3 = [pred3 evaluateWithObject:mobile];
        
        if (isMatch1 || isMatch2 || isMatch3) {
            return YES;
        }else{
            return NO;
        }
    }
}

//判断登录注册 密码格式是否正确
+ (BOOL)validPwd:(NSString *)textString
{
    NSString* number=@"^[A-Za-z0-9]+$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    return [numberPre evaluateWithObject:textString];
}
@end
