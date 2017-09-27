//
//  timeselecteview.h
//  XiaoYa
//
//  Created by 曾凌峰 on 2017/1/19.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CourseModel;
@class timeselecteview;
@protocol timeselectViewDelegate <NSObject>
- (void)timeSelectComfirm:(timeselecteview*)timeselect courseTimeArray:(NSMutableArray *)courseTimeArray inSection:(NSInteger)section;
- (void)timeSelectCancel:(timeselecteview* )timeSelectView;

@end

@interface timeselecteview : UIView
@property (nonatomic,weak) id<timeselectViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame andCellModel:(CourseModel *)cellMoedl indexSection:(NSInteger)section originIndexs:(NSMutableArray*)originIndexs originWeekday:(NSInteger)originWeekday;
@end
