//
//  MemberListViewController.h
//  XiaoYa
//
//  Created by commet on 2017/9/10.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupMemberModel;

@interface MemberListViewController : UIViewController

- (instancetype)initWithAllMembersModel:(NSArray <GroupMemberModel *>*)members totalMember:(NSInteger)memberCount;
@end
