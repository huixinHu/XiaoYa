//
//  businessviewcell.m
//  XiaoYa
//
//  Created by 曾凌峰 on 2016/11/7.
//  Copyright © 2016年 commet. All rights reserved.
//

#import "businessviewcell.h"
#import "Utils.h"
#import "Masonry.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
@implementation businessviewcell

-(instancetype)initWithFrame:(CGRect)frame andNSArray:(NSArray *)array
{
    if(self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor whiteColor];
        
        for (int i = 0; i < 2; i ++) {
            UIView *horizonline = [[UIView alloc] init];
            horizonline.backgroundColor = [Utils colorWithHexString:@"#D9D9D9"];
            [self addSubview:horizonline];
            __weak typeof(self) weakself = self;
            [horizonline mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0.5);
                make.width.mas_equalTo(500.0 / 750.0 * kScreenWidth);
                make.centerX.equalTo(weakself.mas_centerX);
                make.top.equalTo(weakself.mas_top).offset(40*(i+1));
            }];
            
            UIImageView *arrow = [[UIImageView alloc] init];
            arrow.image = [UIImage imageNamed:@"arrow"];
            [self addSubview:arrow];
            [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(horizonline.mas_right);
                make.bottom.equalTo(horizonline.mas_bottom);
            }];
            
            if(array.count == 2)
            {
                UIImageView *iconview = [[UIImageView alloc]init];
                iconview.image = [UIImage imageNamed:array[i]];
                [self addSubview:iconview];
                [iconview mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(horizonline.mas_left).offset(-12);
                    make.bottom.equalTo(horizonline.mas_bottom);
                }];
            }
        }        
        if(array.count == 1)
        {
            UIImageView *iconview = [[UIImageView alloc]init];
            iconview.image = [UIImage imageNamed:array[0]];
            [self addSubview:iconview];
            __weak typeof(self) weakself = self;
            [iconview mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(weakself.mas_centerX).offset(-250/750.0*kScreenWidth-12);
                make.centerY.equalTo(weakself.mas_centerY);
            }];
        }
        
        UIButton *button1 = [[UIButton alloc] init];
        _button1 = button1;
        [_button1 setTitle:@"选择时间" forState:UIControlStateNormal];
        [_button1 setTitleColor:[Utils colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        _button1.titleLabel.font = [UIFont systemFontOfSize:14];
        _button1.contentVerticalAlignment =UIControlContentVerticalAlignmentBottom;
        [self addSubview:_button1];
        __weak typeof(self) weakself = self;
        [_button1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(500.0 / 750.0 * kScreenWidth);
            make.height.mas_equalTo(40);
            make.bottom.equalTo(weakself.mas_top).offset(40);
            make.centerX.equalTo(weakself.mas_centerX);
        }];
        
        
        UIButton *button2 = [[UIButton alloc] init];
        _button2 = button2;
         //title是随便设的，coursetimecell拷贝过来的代码
        [_button2 setTitle:@"第几节，选择时间" forState:UIControlStateNormal];
        [_button2 setTitleColor:[Utils colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        _button2.titleLabel.font = [UIFont systemFontOfSize:14];
        _button2.contentVerticalAlignment =UIControlContentVerticalAlignmentBottom;
        [self addSubview:_button2];
        [_button2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(500.0 / 750.0 * kScreenWidth);
            make.height.mas_equalTo(40);
            make.bottom.equalTo(weakself.mas_top).offset(80);
            make.centerX.equalTo(weakself.mas_centerX);
        }];
        
        //顶部底部两条灰线
        UIView *line1 = [[UIView alloc]init];
        line1.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
        [self addSubview:line1];
        [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.left.equalTo(weakself);
            make.height.mas_equalTo(0.5);
            make.top.equalTo(weakself.mas_top);
        }];
        UIView *line2 = [[UIView alloc]init];
        line2.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
        [self addSubview:line2];
        [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.left.equalTo(weakself);
            make.height.mas_equalTo(0.5);
            make.bottom.equalTo(weakself.mas_bottom);
        }];
    }
    return self;
}


@end
