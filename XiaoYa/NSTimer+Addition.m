//
//  NSTimer+Addition.m
//  XiaoYa
//
//  Created by commet on 2017/6/8.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "NSTimer+Addition.h"

@implementation NSTimer (Addition)
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void(^)(NSTimer *timer))block repeats:(BOOL)repeats{
    return [self scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(blockInvoke:)
                                       userInfo:[block copy]
                                        repeats:repeats];
}

+ (void)blockInvoke:(NSTimer *)timer {
    void (^block)() = timer.userInfo;
    if(block) {
        block(timer);
    }
}
@end
