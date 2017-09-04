//
//  BgView.m
//  XiaoYa
//
//  Created by commet on 2017/9/4.
//  Copyright © 2017年 commet. All rights reserved.
//用作背景的view,只有顶部底部两条灰线

#import "BgView.h"
#import "Utils.h"
#import "Masonry.h"
@implementation BgView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    //顶部底部两条灰线
    UIView *line1 = [[UIView alloc]init];
    line1.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [self addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.top.equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
    UIView *line2 = [[UIView alloc]init];
    line2.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [self addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.bottom.equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
}
@end
