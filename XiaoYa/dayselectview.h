//
//  dayselectview.h
//  XiaoYa
//
//  Created by 曾凌峰 on 2016/11/30.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class dayselectview;
@protocol dayselsctViewDelegate <NSObject>
//确认操作。
- (void)daySelectComfirmAction:(dayselectview *)sectionSelector selectedIndex:(NSInteger)index inSection:(NSInteger)section;
//取消
- (void)daySelectCancelAction:(dayselectview *)sectionSelector;
@end


@interface dayselectview : UIView
@property (nonatomic,weak) id<dayselsctViewDelegate> delegate;
-(instancetype)initWithFrame:(CGRect)frame andDayString:(NSString *)dayString indexSection:(NSInteger)section;
@end
