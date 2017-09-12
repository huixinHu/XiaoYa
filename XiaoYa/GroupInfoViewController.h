//
//  GroupInfoViewController.h
//  XiaoYa
//
//  Created by commet on 2017/7/31.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupListModel;

@interface GroupInfoViewController : UIViewController
- (instancetype)initWithGroupName:(NSString *)groupName;
- (instancetype)initWithGroupName:(NSString *)groupName groupDetail:(GroupListModel *)model;
- (instancetype)init NS_UNAVAILABLE;
@end
