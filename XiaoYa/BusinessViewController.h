//
//  BusinessViewController.h
//  XiaoYa
//
//  Created by commet on 16/11/25.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusinessModel.h"
@class BusinessViewController;
@protocol BusinessViewControllerDelegate <NSObject>
//传回添加的那一周，刷新主界面
- (void)BusinessViewController:(BusinessViewController*)viewController week:(NSInteger )selectedWeek;
//刷新主界面
- (void)deleteBusiness:(BusinessViewController *)viewController;
@end

@interface BusinessViewController : UIViewController
@property (nonatomic,weak) UITextField *busDescription;//事件描述textfield，描述+时间均有内容才允许保存事件
@property (nonatomic , strong) NSMutableArray *sectionArray;//选择节数数组
@property (nonatomic , weak) id <BusinessViewControllerDelegate> delegate;

- (instancetype)initWithfirstDateOfTerm:(NSDate *)firstDateOfTerm businessModel:(BusinessModel *)busModel;
- (void)dataStore;
- (void)rightBarBtnCanBeSelect;
@end
