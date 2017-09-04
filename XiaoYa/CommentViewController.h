//
//  CommentViewController.h
//  XiaoYa
//
//  Created by commet on 17/2/14.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^completeBlock)( NSString * _Nonnull text);

@interface CommentViewController : UIViewController

- (instancetype _Nonnull )initWithTextStr:(NSString * _Nullable)str successBlock:(nonnull completeBlock)block;
@end
