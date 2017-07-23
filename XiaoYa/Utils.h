//
//  Utils.h
//  XiaoYa
//
//  Created by commet on 16/10/16.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Utils : NSObject
+ (UIColor *)colorWithHexString: (NSString *)color;

//事务节数分割连续段
+ (NSMutableArray*)subSectionArraysFromArray:(NSMutableArray *)sectionArray;

//返回事务日期数组，元素储存格式yyyymmdd。参数1：起始日期；参数2：持续时间，以年为单位;参数3：重复项。
+ (NSMutableArray *)dateStringArrayFromDate:(NSDate *)currentDate yearDuration:(int)yearDuration repeatIndex:(NSInteger)repeat;

//判断手机号码格式是否正确
+ (BOOL)validMobile:(NSString *)mobile;

//判断登录注册 密码格式是否正确
+ (BOOL)validPwd:(NSString *)textString;
@end
