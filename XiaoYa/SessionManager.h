//
//  SessionManager.h
//  XiaoYa
//
//  Created by commet on 17/4/13.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SessionManager : NSObject
@property (nonatomic ,strong)NSURLSession *session;

+ (instancetype)shareSession;
@end
