//
//  HXTextField.h
//  XiaoYa
//
//  Created by commet on 2017/6/7.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXTextField : UITextField

/**
 输入框外观设置

 @param tColor 文本文字颜色
 @param tFont 文本文字
 @param phcolor 提示文字颜色
 @param phFont 提示文字字号
 @param phText 提示文本
 @param lv 占位view，用于设置输入框文字与输入框左边边距
 */
- (void)appearanceWithTextColor:(UIColor * )tColor textFontSize:(CGFloat )tFont placeHolderColor:(UIColor * )phcolor placeHolderFontSize:(CGFloat)phFont placeHolderText:(NSString *)phText leftView:(UIView *)lv;
@end
