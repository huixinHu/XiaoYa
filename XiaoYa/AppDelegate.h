//
//  AppDelegate.h
//  XiaoYa
//
//  Created by commet on 16/10/11.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic ,assign) BOOL isLogin;
@property (nonatomic ,strong) NSDate *firstDateOfTerm;
@property (nonatomic ,copy) NSString *userName;
@property (nonatomic ,copy) NSString *phone;
@property (nonatomic ,copy) NSString *userid;
@property (nonatomic ,assign) BOOL isNoGroup;
@end

