//
//  HXButton.h
//  XiaoYa
//
//  Created by commet on 2017/6/7.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^networkBlock)(void);

@interface HXButton : UIButton
@property (nonatomic ,weak) NSTimer *timer;
@property (nonatomic ,assign)CFRunLoopRef runloop;

//参数1 frame ;参数2 定时器计数次数；参数3 定时器计数间隔 ;参数4 ：网络操作block
- (instancetype)initWithFrame:(CGRect)frame timerCount:(int)count timerInerval:(CGFloat)interval networkRequest:(networkBlock)networkBlock;

@end
