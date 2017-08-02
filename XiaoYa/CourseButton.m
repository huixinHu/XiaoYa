//
//  CourseButton.m
//  XiaoYa
//
//  Created by commet on 16/11/1.
//  Copyright © 2016年 commet. All rights reserved.
//
//课程格子按钮 模板类
#import "CourseButton.h"
#import "Masonry.h"
#import "BusinessModel.h"
#import "CourseModel.h"

@implementation CourseButton
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.isOverlap = NO;
        self.type = 0;
        
//        UILabel *event = [[UILabel alloc]init];
//        _event = event;
//        _event.textColor = [UIColor whiteColor];
//        _event.font = [UIFont systemFontOfSize:11];//默认11，但选中的放大列字号13
//        
//        UILabel *place = [[UILabel alloc]init];
//        _place = place;
//        _place.textColor = [UIColor whiteColor];
//        _place.font = [UIFont systemFontOfSize:11];
//        
//        [self addSubview:_event];
//        [self addSubview:_place];
//        
//        __weak typeof(self) weakself = self;
//        [_event mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(weakself.mas_centerX);
//            make.bottom.equalTo(weakself.mas_centerY).offset(-5);
//        }];
//        [_place mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(weakself.mas_centerX);
//            make.top.equalTo(weakself.mas_centerY).offset(5);
//        }];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:11];
        self.titleLabel.numberOfLines = 5;
    }
    return self;
}

- (instancetype)initWithCourseArray:(NSArray *)courseArr businessArray:(NSArray *)businessArr btntype:(int)type{
    if (self = [super initWithFrame:CGRectZero]) {
        self.isOverlap = NO;
        
        UILabel *event = [[UILabel alloc]init];
        _event = event;
        _event.textAlignment = NSTextAlignmentCenter;
        _event.lineBreakMode = 1;
        _event.numberOfLines = 3;
        _event.textColor = [UIColor whiteColor];
        _event.font = [UIFont systemFontOfSize:11];//默认11，但选中的放大列字号13
        
        UILabel *place = [[UILabel alloc]init];
        _place = place;
        _place.textAlignment = NSTextAlignmentCenter;
        _place.lineBreakMode = 1;
        _place.numberOfLines = 3;
        _place.textColor = [UIColor whiteColor];
        _place.font = [UIFont systemFontOfSize:11];
        [self addSubview:_event];
        [self addSubview:_place];
        
        [_event mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.mas_width);
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY).offset(-10);
        }];
        [_place mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.mas_width);
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY).offset(10);
        }];
        
        self.businessArray = [businessArr mutableCopy];
        self.courseArray = [courseArr mutableCopy];
        
        if (type == 0) {//0事务
            BusinessModel *busMdl = businessArr.firstObject;
            self.event.text = busMdl.desc;
            if (courseArr.count > 0) {//courseArray也有可能为Nil,可能初始化了但没有元素赋值（count=0）。
                self.isOverlap = YES;
            }
            [_event mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.mas_centerY);
            }];
        }else if(type == 1){//1课程
            CourseModel *courseMdl = courseArr.firstObject;
            self.event.text = courseMdl.courseName;
            self.place.text = [NSString stringWithFormat:@"@%@",courseMdl.place];
            if (businessArr.count > 0) {//busArray也有可能为Nil,可能初始化了但没有元素赋值（count=0）。
                self.isOverlap = YES;
            }
        }
    }
    return self;
}

@end
