//
//  ReasonView.h
//  XiaoYa
//
//  Created by commet on 2017/8/1.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ReasonView : UIView
- (instancetype)initWithCancelBlock:(void (^)())cancelBlock confirmBlock:(void (^)(NSString *reason))confirmBlock;

@end
