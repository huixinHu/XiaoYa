//
//  UIAlertController+Appearance.h
//  XiaoYa
//
//  Created by commet on 17/2/14.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Appearance)
//提示框按钮样式设置
- (void)addActionTarget:(UIAlertAction*)action hexColor:(NSString *)color;

//提示框title样式设置
- (void)alertTitleAppearance_title:(NSString *)title hexColor:(NSString *)color;
//提示框Message样式设置
- (void)alertMessageAppearance_message:(NSString *)message hexColor:(NSString *)color;

/**
 *
 *  @param title                标题
 *  @param message              详细信息
 *  @param preferredStyle
 *  @param cancelTitle          取消按钮标题
 *  @param cancelHandler        用于执行取消方法的回调block
 *  @param otherTitles          其他按钮标题（不是cancel也不是destruct）
 *  @param otherBlocks          用于执行其他按钮方法的回调blocks
 
 */
+ (UIAlertController *)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle cancelTitle:(NSString *)cancelTitle cancelBlock:(void (^)(UIAlertAction *action))cancelHandler otherTitles:(NSArray *)otherTitles otherBlocks:(NSArray *)otherBlocks;
@end
