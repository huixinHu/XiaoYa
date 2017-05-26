//
//  UILabel+AlertActionFont.m
//  XiaoYa
//
//  Created by commet on 17/1/21.
//  Copyright © 2017年 commet. All rights reserved.
//提示框文字样式

#import "UILabel+AlertActionFont.h"

@implementation UILabel (AlertActionFont)
- (void)setAppearanceFont:(UIFont *)appearanceFont
{
    if(appearanceFont)
    {
        [self setFont:appearanceFont];
    }
}

- (UIFont *)appearanceFont
{
    return self.font;
}
@end
