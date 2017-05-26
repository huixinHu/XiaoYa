//
//  SectionSelect.h
//  XiaoYa
//
//  Created by commet on 16/11/28.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SectionSelect;
@protocol SectionSelectDelegate<NSObject>

//确认操作。传递选中节数、被覆盖的节数到控制器
- (void)SectionSelectComfirmAction:(SectionSelect *)sectionSelector sectionArr:(NSMutableArray *)sectionArray;
//取消
- (void)SectionSelectCancelAction:(SectionSelect *)sectionSelector;
@end

@interface SectionSelect : UIView
@property (nonatomic ,weak) id <SectionSelectDelegate> delegate;

//- (instancetype)initWithFrame:(CGRect)frame sectionArr:(NSMutableArray* )sectionArray selectedDate:(NSDate*)date;
- (instancetype)initWithFrame:(CGRect)frame sectionArr:(NSMutableArray* )sectionArray selectedDate:(NSDate*)date originIndexs:(NSMutableArray*)originIndexs originDate:(NSDate* )originDate termFirstDate:(NSDate*)firstDate;
@end
