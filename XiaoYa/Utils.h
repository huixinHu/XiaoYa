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

/**
 事务节数分割连续段

 @param sectionArray 事务节数数组
 @return 按连续段进行分割后的节数子数组的集合（二维数组）
 */
+ (NSMutableArray*)subSectionArraysFromArray:(NSMutableArray *)sectionArray;

/**
 返回事务日期数组，元素储存格式yyyymmdd

 @param currentDate 起始日期
 @param yearDuration 持续时间，以年为单位
 @param repeat 重复项
 @return 事务日期数组
 */
+ (NSMutableArray *)dateStringArrayFromDate:(NSDate *)currentDate yearDuration:(int)yearDuration repeatIndex:(NSInteger)repeat;

/**
 判断手机号码格式是否正确

 @param mobile 待判断字符串
 @return 判断结果
 */
+ (BOOL)validMobile:(NSString *)mobile;

/**
 判断登录注册 密码格式是否正确

 @param textString 待判断字符串
 @return 判断结果
 */
+ (BOOL)validPwd:(NSString *)textString;

/**
 字符串的总字符长度，比如一个中文算两个字符

 @param strtemp 待计算字符串
 @return 字符长度
 */
+ (int)indexOfCharacter:(NSString *)strtemp;

/**
 把数组中每一个选项一次拼接成一个字符串，用“、”分割

 @param selectArray 选中内容数组中的哪几项
 @param items 内容数组
 @return 拼接后的字符串
 */
+ (NSString *)appendRemindStringWithArray:(NSArray *)selectArray itemsArray:(NSArray *)items;

/**
 拼接节数字符串，先将早午晚的特殊节数做转换，再把数组中每一个选项依次拼接成一个字符串，用“、”分割

 @param sectionArray 节数数组
 @return 拼接后的字符串
 */
+ (NSString *)appendSectionStringWithArray:(NSMutableArray<NSString*>*)sectionArray;

/**
 对数组中的每一元素从小到大排序，数组元素为数字字符串

 @param arr 数字字符串数组
 */
+ (void)sortArrayFromMinToMax:(NSMutableArray *)arr;
@end
