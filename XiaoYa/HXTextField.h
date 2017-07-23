//
//  HXTextField.h
//  XiaoYa
//
//  Created by commet on 2017/6/7.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXTextField : UITextField
- (void)appearanceWithTextColor:( UIColor * )tColor textFontSize:(CGFloat )tFont placeHolderColor:(UIColor * )phcolor placeHolderFontSize:(CGFloat)phFont placeHolderText:(NSString *)phText leftView:(UIView *)lv;
@end
