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

/**
 自定义倒计时按钮

 @param frame frame
 @param count 倒计时次数
 @param interval 倒计时间隔
 @param networkBlock 网络回调，再次发送获得验证码的请求
 @return 倒计时按钮
 */
- (instancetype)initWithFrame:(CGRect)frame timerCount:(int)count timerInerval:(CGFloat)interval networkRequest:(networkBlock)networkBlock;

@end
