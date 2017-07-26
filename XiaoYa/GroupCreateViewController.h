//
//  GroupCreateViewController.h
//  XiaoYa
//
//  Created by commet on 2017/7/11.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupMemberModel;

@interface GroupCreateViewController : UIViewController
- (instancetype)initWithGroupManager:(GroupMemberModel *)model;

@end
