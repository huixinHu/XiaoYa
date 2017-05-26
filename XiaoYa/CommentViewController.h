//
//  CommentViewController.h
//  XiaoYa
//
//  Created by commet on 17/2/14.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CommentViewController;
@protocol CommentVCDelegate<NSObject>
//确认操作。
- (void)commentVC:(CommentViewController *)vc infomation:(NSString *)info;

@end

@interface CommentViewController : UIViewController
@property (nonatomic ,weak) id <CommentVCDelegate> delegate;

- (instancetype)initWithTextStr:(NSString *)str;
@end
