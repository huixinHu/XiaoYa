//
//  ReasonView.h
//  XiaoYa
//
//  Created by commet on 2017/8/1.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ReasonView : UIView
- (nonnull instancetype)initWithCancelBlock:(void (^_Nullable)(void))cancelBlock confirmBlock:(void (^_Nullable)(NSString * _Nonnull reason))confirmBlock;

@end
