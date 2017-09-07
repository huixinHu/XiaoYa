//
//  DatePicker.h
//  rsaTest
//
//  Created by commet on 16/11/17.
//  Copyright © 2016年 commet. All rights reserved.
//日期选择
//

#import <UIKit/UIKit.h>
typedef void(^dateConfirmBlock)(NSDate *selectedDate);
typedef void(^dateCancelBlock)(void);
typedef void(^monPickerCteateBlock)(NSDate *currentDate);

@interface DatePicker : UIView
@property (nonatomic ,copy) dateConfirmBlock confirmBlock;
@property (nonatomic ,copy) dateCancelBlock cancelBlock;
@property (nonatomic ,copy) monPickerCteateBlock monBlock;

//初始化。参数1：frame 参数2：当前日期 参数3：本学期第一天的日期
- (instancetype)initWithFrame:(CGRect)frame
                         date:(NSDate*)currentDate
              firstDateOfTerm:(NSDate *)firstDateOfTerm
                 confirmBlock:(dateConfirmBlock)confirm
                  cancelBlock:(dateCancelBlock)cancel
         monPickerCreateBlock:(monPickerCteateBlock)monCreate;
@end
