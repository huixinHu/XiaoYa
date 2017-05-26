//
//  RepeatSetting.h
//  XiaoYa
//
//  Created by commet on 16/11/30.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RepeatSetting;
@protocol RepeatSettingDelegate<NSObject>

//确认操作。
- (void)RepeatSettingComfirmAction:(RepeatSetting *)sectionSelector selectedIndex:(NSInteger)index;
//取消
- (void)RepeatSettingCancelAction:(RepeatSetting *)sectionSelector;
@end

@interface RepeatSetting : UIView
@property (nonatomic ,weak) id <RepeatSettingDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame selectedIndex:(NSInteger)index;
@end
