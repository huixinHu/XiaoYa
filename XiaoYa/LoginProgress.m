//
//  LoginProgress.m
//  XiaoYa
//
//  Created by commet on 2017/10/6.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "LoginProgress.h"
#import "NSTimer+Addition.h"
#import "MBProgressHUD.h"
@interface LoginProgress()
@property (nonatomic ,strong) NSTimer *timer;
@property (nonatomic ,strong) dispatch_queue_t concurrentQ;
@property (nonatomic ,strong) MBProgressHUD *hub;

@end

@implementation LoginProgress
{
    CFRunLoopRef runlp;
}

- (void)showProgress:(BOOL)show onView:(UIView *)view{
    dispatch_async(self.concurrentQ, ^{
        if (show) {
            [self showLoginProgressGUI:YES onParent:view];
            [self stopTimer];
            __weak typeof(self) ws = self;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:5 block:^(NSTimer *timer) {
                NSLog(@"____");
                if (ws.loginTimeoutBlock && ws.timer) {
                    ws.loginTimeoutBlock();
                }
            } repeats:NO];
            runlp = CFRunLoopGetCurrent();
            [[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        else{
            [self showLoginProgressGUI:NO onParent:view];
            [self stopTimer];
            CFRunLoopStop(runlp);
        }
    });
}

- (void)stopTimer{
    if(self.timer != nil)
    {
        if([self.timer isValid])
            [self.timer invalidate];
        
        self.timer = nil;
    }
}

- (BOOL)timerIsActive{
    if ([self.timer isValid]) {
        return YES;
    } else{ //timer可能=nil
        return NO;
    }
}

- (void)showLoginProgressGUI:(BOOL)show onParent:(UIView *)view{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (show) {
            if (self.hub == nil) {
                self.hub = [[MBProgressHUD alloc]initWithView:view];
                [view addSubview:self.hub];
                self.hub.label.text = @"登录中...";
            }
            [self.hub showAnimated:YES];
        } else{
            if (self.hub) {
                [self.hub hideAnimated:YES];
            }
        }
    });
}

- (dispatch_queue_t)concurrentQ{
    if (_concurrentQ == nil) {
        _concurrentQ = dispatch_queue_create("com.commet.LoginProgress", DISPATCH_QUEUE_CONCURRENT);
    }
    return _concurrentQ;
}
@end
