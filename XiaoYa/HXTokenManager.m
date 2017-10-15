//
//  HXTokenManager.m
//  XiaoYa
//
//  Created by commet on 2017/9/27.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "HXTokenManager.h"

@implementation HXTokenManager

static HXTokenManager *manager = nil;
+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

@end
