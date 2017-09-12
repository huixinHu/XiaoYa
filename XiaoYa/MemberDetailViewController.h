//
//  MemberDetailViewController.h
//  XiaoYa
//
//  Created by commet on 2017/9/9.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupMemberModel;

@interface MemberDetailViewController : UIViewController
- (instancetype)initWithMemberModel:(GroupMemberModel *)model;
@end
