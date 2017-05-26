//
//  CourseViewController.h
//  XiaoYa
//
//  Created by commet on 16/11/27.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CourseViewController;
@protocol CourseViewControllerDelegate <NSObject>
//刷新主界面
- (void)CourseViewControllerConfirm:(CourseViewController*)viewController;
- (void)CourseViewControllerDelete:(CourseViewController*)viewController;
@end

@interface CourseViewController : UIViewController
@property (nonatomic,weak) id <CourseViewControllerDelegate> delegate;

- (instancetype)initWithCourseModel:(NSMutableArray *)modelArray;
- (void)dataStore;
- (void)rightBarBtnCanBeSelected;
@end
