//
//  LoginProgress.h
//  XiaoYa
//
//  Created by commet on 2017/10/6.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void(^loginSocketTimeout)();

@interface LoginProgress : NSObject

@property (nonatomic ,copy) loginSocketTimeout loginTimeoutBlock;
- (void)showProgress:(BOOL)show onView:(UIView *)view;
- (BOOL)timerIsActive;
@end
