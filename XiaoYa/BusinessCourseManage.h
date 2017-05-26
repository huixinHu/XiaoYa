//
//  BusinessCourseManage.h
//  XiaoYa
//
//  Created by commet on 16/11/28.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BusinessCourseManage;
@protocol BusinessCourseManageDelegate <NSObject>
//传回添加的那一周
- (void)BusinessCourseManage:(BusinessCourseManage*)viewController week:(NSInteger )selectedWeek;

@end

@interface BusinessCourseManage : UIViewController
@property (nonatomic , weak) id <BusinessCourseManageDelegate> delegate;

/**
 *  指定初始化方法
 *  @param controllersArray         子控制器数组
 */
- (instancetype)initWithControllersArray:(NSArray *)controllersArray firstDateOfTerm:(NSDate *)firstDateOfTerm;
@end
