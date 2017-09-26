//
//  LoginManager.h
//  XiaoYa
//
//  Created by commet on 2017/7/20.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^loginedBlock)(void);

@interface LoginManager : NSObject

//参数1：触发登录时 最顶层的视图控制器 ；参数2：是否需要检查登录 ；参数3：已经登录、不需检查登录时要执行的block
+ (BOOL)checkLoginWithTopPresentingViewControllre:(UIViewController *)viewcontroller isCheckLogin:(BOOL)check loginedBlock:(loginedBlock)loginedBlock;

@end
