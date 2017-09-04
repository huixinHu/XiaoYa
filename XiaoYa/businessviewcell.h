//
//  businessviewcell.h
//  XiaoYa
//
//  Created by 曾凌峰 on 2016/11/7.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BgView.h"

@interface businessviewcell : BgView

@property (nonatomic,weak) UIButton *button1;
@property (nonatomic,weak) UIButton *button2;

-(instancetype)initWithFrame:(CGRect)frame andNSArray:(NSArray *)array;

@end
