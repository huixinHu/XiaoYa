//
//  MonthPicker.h
//  rsaTest
//
//  Created by commet on 16/11/18.
//  Copyright © 2016年 commet. All rights reserved.
//月份选择
//

#import <UIKit/UIKit.h>
@class MonthPicker;
@protocol MonthPickerDelegate<NSObject>
//确认操作。让控制器新建一个日期选择器
- (void)monthPickerConfirmAction:(MonthPicker *)monthPicker date:(NSDate* )currentDate;
//取消操作。让控制器显示原来的日期选择器
- (void)monthPickerCancelAction:(MonthPicker *)monthPicker;
@end

@interface MonthPicker : UIView
@property (nonatomic ,weak) id <MonthPickerDelegate> delegate;
//初始化。参数1：frame 参数2：当前日期
- (instancetype)initWithFrame:(CGRect)frame date:(NSDate* )currentDate;
@end
