//
//  UIView+Extend.m
//  XiaoYa
//
//  Created by commet on 17/2/10.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "UIView+Extend.h"

@implementation UIView (Extend)
//获得某个view所在的视图控制器
- (UIViewController*)viewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}
@end
