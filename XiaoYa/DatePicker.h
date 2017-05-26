//
//  DatePicker.h
//  rsaTest
//
//  Created by commet on 16/11/17.
//  Copyright © 2016年 commet. All rights reserved.
//日期选择
//

#import <UIKit/UIKit.h>
@class DatePicker;
@protocol DatePickerDelegate<NSObject>

//让控制器创建月份选择器
- (void)datePicker:(DatePicker *)datePicker createMonthPickerWithDate:(NSDate *)currentDate;
//确认操作。传递选中日期到控制器
- (void)datePicker:(DatePicker *)datePicker selectedDate:(NSDate *)selectedDate;
//取消
- (void)datePickerCancelAction:(DatePicker *)datePicker;
@end

@interface DatePicker : UIView
@property (nonatomic ,weak) id <DatePickerDelegate> delegate;

//初始化。参数1：frame 参数2：当前日期 参数3：本学期第一天的日期
- (instancetype)initWithFrame:(CGRect)frame date:(NSDate*)currentDate firstDateOfTerm:(NSDate *)firstDateOfTerm;
@end
