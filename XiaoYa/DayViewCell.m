//
//  DayViewCell.m
//  XiaoYa
//
//  Created by commet on 16/11/4.
//  Copyright © 2016年 commet. All rights reserved.
//

#import "DayViewCell.h"
#import "Masonry.h"
#import "Utils.h"
@implementation DayViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UILabel *weekday = [[UILabel alloc]init];
        _weekday = weekday;
        _weekday.font = [UIFont systemFontOfSize:15];
        _weekday.textColor = [Utils colorWithHexString:@"#4c4c4c"];
        
        UILabel *date = [[UILabel alloc]init];
        _date = date;
        _date.font = [UIFont systemFontOfSize:10];
        _date.textColor = [Utils colorWithHexString:@"#4c4c4c"];
        
        [self addSubview:_weekday];
        [self addSubview:_date];
        
        __weak typeof(self) weakself = self;
        [_weekday mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(weakself.mas_centerX);
            make.bottom.equalTo(weakself.mas_centerY).offset(-5);
        }];
        [_date mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(weakself.mas_centerX);
            make.top.equalTo(weakself.mas_centerY).offset(5);
        }];
    }
    return self;
}

@end
