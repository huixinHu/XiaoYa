//
//  GroupListModel.h
//  XiaoYa
//
//  Created by commet on 2017/7/11.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GroupMemberModel;
@interface GroupListModel : NSObject
@property (nonatomic ,copy) NSString *groupName;
@property (nonatomic ,copy) NSString *groupId;
@property (nonatomic ,copy) NSString *groupMessage;
@property (nonatomic ,copy) NSString *time;
@property (nonatomic ,assign) NSInteger groupAvatarId;
@property (nonatomic ,strong) NSArray<GroupMemberModel *> *groupMembers;

+ (instancetype)groupWithDict:(NSDictionary *)dict;
@end
