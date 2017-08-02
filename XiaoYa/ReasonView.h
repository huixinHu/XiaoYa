//
//  ReasonView.h
//  XiaoYa
//
//  Created by commet on 2017/8/1.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ReasonView;
@protocol ReasonViewDelegate<NSObject>
//确认操作。
- (void)reasonViewConfirmAction:(ReasonView *)reasonView notParticipateReason:(NSString *)reason;
//取消
- (void)reasonViewCancelAction:(ReasonView *)reasonView;
@end

@interface ReasonView : UIView
@property (nonatomic ,weak) id<ReasonViewDelegate> delegate;

@end
