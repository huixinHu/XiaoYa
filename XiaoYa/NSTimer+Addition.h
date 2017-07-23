//
//  NSTimer+Addition.h
//  XiaoYa
//
//  Created by commet on 2017/6/8.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NSTimer (Addition)
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void(^)(NSTimer *timer))block repeats:(BOOL)repeats;
@end
