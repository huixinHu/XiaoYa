//
//  TimeViewCell.m
//  XiaoYa
//
//  Created by commet on 16/10/20.
//  Copyright © 2016年 commet. All rights reserved.
//
//纵向时间段、横向周几日期 模板类

#import "TimeViewCell.h"
#import "Masonry.h"
#import "Utils.h"
@interface TimeViewCell()
//@property (nonatomic , weak)UILabel *lable1;
//@property (nonatomic , weak)UILabel *lable2;
@end

@implementation TimeViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UILabel *time = [[UILabel alloc]init];
        _time = time;
        _time.font = [UIFont systemFontOfSize:10];
        _time.textColor = [Utils colorWithHexString:@"#999999"];
        
        UILabel *number = [[UILabel alloc]init];
        _number = number;
        _number.font = [UIFont systemFontOfSize:10];
        _number.textColor = [Utils colorWithHexString:@"#4c4c4c"];
        
        [self addSubview:_time];
        [self addSubview:_number];
        
        [_time mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.bottom.equalTo(self.mas_centerY).offset(-3);
        }];
        [_number mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.mas_centerY).offset(3);
        }];
    }
    return self;
}

@end
