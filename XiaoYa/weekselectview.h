//
//  weekselectview.h
//  XiaoYa
//
//  Created by 曾凌峰 on 2016/11/14.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class weekselectview;
@protocol weekselectViewDelegate <NSObject>
-(void)setWeekSelectResult:(NSMutableArray *)weekselected inSection:(NSInteger)section;
-(void)weekSelectCancelAction:(weekselectview*)weekSelectView;

@end

@interface weekselectview : UIView
@property (nonatomic,weak) id<weekselectViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame andWeekSelect:(NSArray *)showweek indexSection:(NSInteger)section;

@end
