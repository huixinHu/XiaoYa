//
//  HXErrorManager.h
//  XiaoYa
//
//  Created by commet on 2017/8/24.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HXErrorManager : NSObject

+ (NSError *)errorWithErrorCode:(NSInteger)errorCode;
@end
