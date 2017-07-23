//
//  HXTextField.m
//  XiaoYa
//
//  Created by commet on 2017/6/7.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "HXTextField.h"
#import "Utils.h"
@implementation HXTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}


- (void)commonInit
{
    //placeholder颜色、大小
    //自定义textfield
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSForegroundColorAttributeName] = [Utils colorWithHexString:@"#d9d9d9"];
    dict[NSFontAttributeName] = [UIFont systemFontOfSize:12.0];
    NSAttributedString *attribute = [[NSAttributedString alloc] initWithString:@"placeholder" attributes:dict];
    [self setAttributedPlaceholder:attribute];
    //文本颜色、大小
    self.textColor = [Utils colorWithHexString:@"#333333"];
    self.font = [UIFont systemFontOfSize:12.0];
    //文本框内的文字距离左边框的距离
//    _busDescription.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 1)];
//    _busDescription.leftViewMode = UITextFieldViewModeAlways;
}

- (void)appearanceWithTextColor:( UIColor * )tColor textFontSize:(CGFloat )tFont placeHolderColor:(UIColor * )phcolor placeHolderFontSize:(CGFloat)phFont placeHolderText:(NSString *)phText leftView:(UIView *)lv
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSForegroundColorAttributeName] = phcolor;
    dict[NSFontAttributeName] = [UIFont systemFontOfSize:phFont];
    NSAttributedString *attribute = [[NSAttributedString alloc] initWithString:phText attributes:dict];
    [self setAttributedPlaceholder:attribute];
    self.textColor = tColor;
    self.font = [UIFont systemFontOfSize:tFont];
    
    if (lv) {
        self.leftView = lv;
        self.leftViewMode = UITextFieldViewModeAlways;
    }
}
@end
