//
//  AppDelegate.m
//  XiaoYa
//
//  Created by commet on 16/10/11.
//  Copyright © 2016年 commet. All rights reserved.
//

#import "AppDelegate.h"
#import "CourseTableViewController.h"
#import "Utils.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    UITabBarController *tabbar = [[UITabBarController alloc]init];
    self.window.rootViewController = tabbar;
    
    
    CourseTableViewController *courseTable = [[CourseTableViewController alloc]init];
    UINavigationController *courseNavVC = [[UINavigationController alloc]initWithRootViewController:courseTable];
//    courseTable.view.backgroundColor = [UIColor whiteColor];
    courseTable.tabBarItem.title = @"日程";
    courseTable.tabBarItem.image = [[UIImage imageNamed:@"schedule"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    courseTable.tabBarItem.selectedImage = [[UIImage imageNamed:@"schedule_selected"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    UIViewController *group = [[UIViewController alloc]init];
    UINavigationController *groupNavVC = [[UINavigationController alloc]initWithRootViewController:group];
    group.tabBarItem.title = @"群组";
    group.tabBarItem.image = [[UIImage imageNamed:@"user-group"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    group.tabBarItem.selectedImage = [[UIImage imageNamed:@"user-group"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    UIViewController *user = [[UIViewController alloc]init];
    UINavigationController *userNavVC = [[UINavigationController alloc]initWithRootViewController:user];
    user.tabBarItem.title = @"我的";
    user.tabBarItem.image = [[UIImage imageNamed:@"user-alt"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    user.tabBarItem.selectedImage = [[UIImage imageNamed:@"user-alt"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[Utils colorWithHexString:@"#333333"],NSForegroundColorAttributeName, [UIFont systemFontOfSize:10.0],NSFontAttributeName,nil] forState:UIControlStateNormal];
    
//    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[Utils colorWithHexString:@"#333333"],NSForegroundColorAttributeName, [UIFont systemFontOfSize:10.0],NSFontAttributeName,nil] forState:UIControlStateSelected];
    
    tabbar.viewControllers = @[courseNavVC,groupNavVC,userNavVC];
    
//    self.window.rootViewController = naviVC;
    [self.window makeKeyAndVisible];
    return YES;
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
