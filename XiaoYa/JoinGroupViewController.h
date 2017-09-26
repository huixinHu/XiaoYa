//
//  JoinGroupViewController.h
//  XiaoYa
//
//  Created by commet on 2017/7/13.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupListModel;

typedef void(^gJoinSuccessBlock)(GroupListModel *model);

@interface JoinGroupViewController : UIViewController
- (instancetype)initWithJoinSuccessBlock:(gJoinSuccessBlock)block;
- (instancetype)init NS_UNAVAILABLE;
@end
