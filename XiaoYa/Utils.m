//
//  Utils.m
//  XiaoYa
//
//  Created by commet on 16/10/16.
//  Copyright © 2016年 commet. All rights reserved.
//

#import "Utils.h"
#import "NSDate+Calendar.h"
#import "AppDelegate.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define kScreenHeight [UIApplication sharedApplication].keyWindow.bounds.size.height
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
    [self sortArrayFromMinToMax:sectionArray];
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

//字符串的字符长度
+ (int)indexOfCharacter:(NSString *)strtemp{//限制文本框输入最长20个字符
    int strlength = 0;
    for (int i=0; i< [strtemp length]; i++) {
        int a = [strtemp characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fa5) { //判断是否为中文
            strlength += 2;
        }else{
            strlength += 1;
        }
        if (strlength > 20) {
            return i;
        }
    }
    return -1;
}

//把数组中每一个选项依次拼接成一个字符串，用“、”分割
+ (NSString *)appendRemindStringWithArray:(NSMutableArray *)selectArray itemsArray:(NSArray *)items{
    [self sortArrayFromMinToMax:selectArray];
    if (selectArray.count == 0) {
        return nil;
    }
    NSMutableString *str = [NSMutableString stringWithFormat:@"%@",items[[selectArray[0] intValue]]];
    for (int i = 1; i < selectArray.count; i++) {
        [str appendFormat:@"、%@",items[[selectArray[i] intValue]]];
    }
    return str;
}

//拼接节数字符串，参数是代表节数的数组，先将早午晚的特殊节数做转换，再把数组中每一个选项依次拼接成一个字符串，用“、”分割
+ (NSString *)appendSectionStringWithArray:(NSMutableArray<NSString*>*)sectionArray{
    [self sortArrayFromMinToMax:sectionArray];
    NSMutableArray *tempArray = [sectionArray mutableCopy];
    for (int i = 0; i < tempArray.count ; i ++) {
        if ([tempArray[i] intValue] == 0) {
            tempArray[i] = @"早间";
        }else if ([tempArray[i] intValue] == 5){
            tempArray[i] = @"午间";
        }else if([tempArray[i] intValue] > 5 && [tempArray[i] intValue] < 14){
            tempArray[i] = [NSString stringWithFormat:@"%d",[tempArray[i] intValue] - 1];
        }
        else if ([tempArray[i] intValue] == 14){
            tempArray[i] = @"晚间";
        }
    }
    NSMutableString *str = [NSMutableString stringWithFormat:@"%@",tempArray[0]];
    if (sectionArray.count != 1) {
        for (int i = 1; i < sectionArray.count; i++) {
            [str appendFormat:@"、%@",tempArray[i]];
        }
    }
    return str;
}

//对数组中的每一元素从小到大排序，数组元素为数字字符串。直接对原数组的元素排序，而不是对数组的备份进行操作
+ (void)sortArrayFromMinToMax:(NSMutableArray *)arr{
    [arr sortUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2){
        //此处的规则含义为：若前一元素比后一元素小，则返回降序（即后一元素在前，为从大到小排列）
        if ([obj1 integerValue] < [obj2 integerValue]){
            return NSOrderedAscending;//将第一个元素放在第二个元素之前
        }else{
            return NSOrderedDescending;//将第一个元素放在第二个元素之后
        }
    }];
}

//生成屏幕遮罩
+ (UIView *)coverLayerAddToWindow{
    UIView *coverLayer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];//生成遮罩层
    coverLayer.backgroundColor = [UIColor colorWithRed:88/255.0 green:88/255.0  blue:88/255.0  alpha:0.5];
    AppDelegate *app = (AppDelegate *)[[UIApplication  sharedApplication] delegate];
    [app.window addSubview:coverLayer];//全屏遮罩要加到window上
    return coverLayer;
}

//把viewd定位到屏幕正中央,然后view原样返回
+ (UIView *)putViewOnCenter:(UIView *)subview superView:(UIView *)supView{
    CGPoint center =  subview.center;
    center.x = supView.frame.size.width/2;
    center.y = supView.frame.size.height/2;
    subview.center = center;
    return subview;
}

//
+ (NSString *)sectionArrToFormatStr:(NSMutableArray *)sectionsArr{
    [self sortArrayFromMinToMax:sectionsArr];
    
    NSMutableString *formatStr = [NSMutableString string];
    NSMutableArray *sections = [self subSectionArraysFromArray:sectionsArr];
    [sections enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *subArr = (NSMutableArray *)obj;
        subArr[0] = [self sectionStrConvert:subArr[0]];
        if (subArr.count == 1) {
            [formatStr appendString:[NSString stringWithFormat:@"%@、", subArr[0]]];
        } else{
            subArr[subArr.count-1] = [self sectionStrConvert:[subArr lastObject]];
            [formatStr appendString:[NSString stringWithFormat:@"%@-%@、", [subArr firstObject], [subArr lastObject]]];
        }
    }];
    return [formatStr substringToIndex:formatStr.length-1];//截去最后一个"、"
}

//sectionStr节数
+ (NSString *)sectionStrConvert:(NSString *)sectionStr{
    NSString *tempStr = sectionStr;
    if ([sectionStr intValue] == 0) {
        tempStr = @"早间";
    }else if ([sectionStr intValue] == 5){
        tempStr = @"午间";
    }else if([sectionStr intValue] > 5 && [sectionStr intValue] < 14){
        tempStr = [NSString stringWithFormat:@"%d",[sectionStr intValue] - 1];
    }
    else if ([sectionStr intValue] == 14){
        tempStr = @"晚间";
    }
    return tempStr;
}
@end
