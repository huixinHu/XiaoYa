//
//  CalendarView.h
//  rsaTest
//
//  Created by commet on 16/11/16.
//  Copyright © 2016年 commet. All rights reserved.
//日历
//

#import <UIKit/UIKit.h>

@interface CalendarView : UIView
//btn tag
@property (nonatomic ,assign)NSInteger btnClickedTag;

//初始化。参数1：frame 参数2：当前日期 参数3:本学期第一天的日期
- (instancetype)initWithFrame:(CGRect)frame date:(NSDate*)currentDate firstDateOfTerm:(NSDate *)firstDateOfTerm;
//核心视图创建。参数类型待定,左侧“第几周”未实现
-(void)creatViewWithData:(NSDate*)currentDate;
@end
