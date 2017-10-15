//
//  HXTokenManager.h
//  XiaoYa
//
//  Created by commet on 2017/9/27.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HXTokenManager : NSObject
@property (nonatomic ,strong) NSDictionary *token;

+ (instancetype)shareInstance;

@end
