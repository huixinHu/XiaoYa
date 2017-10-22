//
//  HXErrorManager.h
//  XiaoYa
//
//  Created by commet on 2017/8/24.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HX_LOGIN_ERROR @"登录失败"
#define HX_DISCONNECT @"socket未连接"
@interface HXErrorManager : NSObject

+ (NSError *)errorWithErrorCode:(NSInteger)errorCode;
@end
