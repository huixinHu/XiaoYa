//
//  LoginManager.m
//  XiaoYa
//
//  Created by commet on 2017/7/20.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "LoginManager.h"
#import "AppDelegate.h"
#import "HXNotifyConfig.h"
#import "NeedLoginViewController.h"

@interface LoginManager()
@property (nonatomic ,strong)UIViewController *topPresentingViewController;
@property (nonatomic ,copy)loginedBlock loginedBlock;
@end

@implementation LoginManager
static LoginManager *_instance;

+ (instancetype)shareLoginManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance;
}

+ (BOOL)checkLoginWithTopPresentingViewControllre:(UIViewController *)viewcontroller isCheckLogin:(BOOL)check loginedBlock:(loginedBlock)loginedBlock{
    LoginManager *manager = [LoginManager shareLoginManager];
    return [manager checkLoginWithTopPresentingViewControllre:viewcontroller isCheckLogin:check loginedBlock:loginedBlock];
}

- (BOOL)checkLoginWithTopPresentingViewControllre:(UIViewController *)viewcontroller isCheckLogin:(BOOL)check loginedBlock:(loginedBlock)loginedBlock{
    self.topPresentingViewController = viewcontroller;
    self.loginedBlock = [loginedBlock copy];
    //要检查是否已经登录
    if (check) {
        //isLogin这个全局变量放在appDelegate会不会不好？放在LoginManager里？
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        //已登录
        if (appDelegate.isLogin) {
            if (self.loginedBlock) {
                self.loginedBlock();
            }
            return YES;
        }
        //未登录
        else{
            [self presentLoginPage];
            return NO;
        }
    }
    //不检查登录
    else{
        if (self.loginedBlock) {
            self.loginedBlock();
        }
        return YES;
    }
}

- (void)presentLoginPage{
    //通知添加。先移除再添加.否则在登录界面点取消，再触发登录检查时会再次来到这个方法，导致多次添加通知。
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXPushViewControllerNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushVC:) name:HXPushViewControllerNotification object:nil];
    //实例化loginVC 获取顶层VC，present loginVC
    NeedLoginViewController *nLoginVC = [[NeedLoginViewController alloc]init];
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:nLoginVC];
    [self.topPresentingViewController presentViewController:navi animated:YES completion:^{
    }];
}

//一般是登录成功后post HXPushViewControllerNotification
- (void)pushVC:(NSNotification *)notification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXPushViewControllerNotification object:nil];
    self.loginedBlock();
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.isLogin = YES;
}

- (void)dismissVC:(NSNotification *)notification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXDismissViewControllerNotification object:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXPushViewControllerNotification object:nil];
}
@end
