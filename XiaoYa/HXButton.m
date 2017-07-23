//
//  HXButton.m
//  XiaoYa
//
//  Created by commet on 2017/6/7.
//  Copyright © 2017年 commet. All rights reserved.
// 倒计时按钮封装

#import "HXButton.h"
#import "NSTimer+Addition.h"
#import "Utils.h"
@interface HXButton()
@property (nonatomic ,copy) networkBlock networkBlock;
@end

@implementation HXButton
{
    int timerCount;
    int resetCount;
    CGFloat timerInterval;
}

//必须要在vc的dealloc方法中调用btn 的timer销毁方法和runloop的退出方法，保证vc pop的时候btn可以马上销毁
- (instancetype)initWithFrame:(CGRect)frame timerCount:(int)count timerInerval:(CGFloat)interval networkRequest:(networkBlock)networkBlock{
    if (self = [super initWithFrame:frame]) {
        
        timerCount = count;
        timerInterval = interval;
        self.networkBlock = [networkBlock copy];
        
        self.enabled = NO;
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        [self setTitle:@"重发验证码" forState:UIControlStateNormal];
        [self setTitleColor:[Utils colorWithHexString:@"#00a7fa"] forState:UIControlStateNormal];
        [self addTarget:self action:@selector(btnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self timerAction];
    }
    return self;
}

//点击按钮，如果有网络操作就执行网络操作，并且开启新的timer
- (void)btnClicked{
    if (self.networkBlock) {
        self.networkBlock();
    }
    [self timerAction];
}

//开启timer
- (void)timerAction{
    resetCount = timerCount;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __weak typeof (self)weakself = self;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:timerInterval block:^(NSTimer *timer) {
            __strong typeof(weakself) strongself = weakself;
            resetCount --;
            if (resetCount == 0) {
                NSLog(@"timer走完");
                [strongself.timer invalidate];
                strongself.enabled = YES;
                CFRunLoopStop(CFRunLoopGetCurrent());
            }else{
                self.enabled = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongself setTitle:[NSString stringWithFormat:@"%ds后重发",resetCount] forState:UIControlStateDisabled];
                    [strongself setTitleColor:[Utils colorWithHexString:@"#d9d9d9"] forState:UIControlStateDisabled];
                });
            }
        } repeats:YES];
        [self.timer fire];//马上执行
        self.runloop = CFRunLoopGetCurrent();
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    });
}

- (void)dealloc{
    NSLog(@"timerbtn销毁了");
}
@end
