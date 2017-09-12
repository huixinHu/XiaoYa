//
//  AppDelegate.m
//  XiaoYa
//
//  Created by commet on 16/10/11.
//  Copyright © 2016年 commet. All rights reserved.
//

#import "AppDelegate.h"
#import "CourseTableViewController.h"
#import "LoginViewController.h"
#import "GroupHomePageViewController.h"
#import "GroupDetailViewController.h"
#import "Utils.h"
#import "LoginManager.h"
@interface AppDelegate ()<UITabBarControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    UITabBarController *tabbar = [[UITabBarController alloc]init];
    self.window.rootViewController = tabbar;
    tabbar.delegate = self;
    
    CourseTableViewController *courseTable = [[CourseTableViewController alloc]init];
    UINavigationController *courseNavVC = [[UINavigationController alloc]initWithRootViewController:courseTable];
    [self setTabBarItem:courseTable.tabBarItem image:@"schedule" selectedImage:@"日程" title:@"日程" tag:0];
    GroupHomePageViewController *group = [[GroupHomePageViewController alloc]init];
    UINavigationController *groupNavVC = [[UINavigationController alloc]initWithRootViewController:group];
    [self setTabBarItem:group.tabBarItem image:@"群组未选中" selectedImage:@"群组" title:@"群组" tag:1];
    GroupDetailViewController *user = [[GroupDetailViewController alloc]init];
    UINavigationController *userNavVC = [[UINavigationController alloc]initWithRootViewController:user];
    [self setTabBarItem:user.tabBarItem image:@"我的未选中" selectedImage:@"我的" title:@"我的" tag:2];
    //总体字体样式设置
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[Utils colorWithHexString:@"#333333"],NSForegroundColorAttributeName, [UIFont systemFontOfSize:10.0],NSFontAttributeName,nil] forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[Utils colorWithHexString:@"#39b9f8"],NSForegroundColorAttributeName, [UIFont systemFontOfSize:10.0],NSFontAttributeName,nil] forState:UIControlStateSelected];
    
    tabbar.viewControllers = @[courseNavVC,groupNavVC,userNavVC];
    
    [self.window makeKeyAndVisible];
    self.isLogin = NO;//赋初值，未登录
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    self.firstDateOfTerm = [dateFormatter dateFromString:@"20170904"];
    self.user = @"user(0)";
    self.phone = @"";
    return YES;
}

- (void)setTabBarItem:(UITabBarItem *)item image:(NSString *)image selectedImage:(NSString *)selected title:(NSString *)title tag:(NSInteger)tag{
    item.image = [[UIImage imageNamed:image]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.selectedImage = [[UIImage imageNamed:selected]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item.title = title;
    item.tag = tag;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if (viewController.tabBarItem.tag == 1 ) {
        return [LoginManager checkLoginWithTopPresentingViewControllre:tabBarController isCheckLogin:YES loginedBlock:^{
            tabBarController.selectedIndex = 1;
        }];
    }else{
        return YES;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
