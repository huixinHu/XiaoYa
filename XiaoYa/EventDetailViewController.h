//
//  EventDetailViewController.h
//  XiaoYa
//
//  Created by commet on 2017/7/31.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupInfoModel;

typedef void(^editCompBlock)(GroupInfoModel *edittedModel);
@interface EventDetailViewController : UIViewController

- (instancetype)initWithInfoModel:(GroupInfoModel *)model editCompBlock:(editCompBlock)block;
- (instancetype)init NS_UNAVAILABLE;
@end
