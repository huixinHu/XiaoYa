//
//  GroupListModel.h
//  XiaoYa
//
//  Created by commet on 2017/7/11.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GroupMemberModel;
@class GroupInfoModel;

@interface GroupListModel : NSObject<NSCopying ,NSCoding>
@property (nonatomic ,copy) NSString *groupName;                            //群名
@property (nonatomic ,copy) NSString *groupId;                              //群id
@property (nonatomic ,copy) NSString *groupAvatarId;                      //群头像id
@property (nonatomic ,strong) NSMutableArray<GroupMemberModel *> *groupMembers;    //群成员集
@property (nonatomic ,assign) NSInteger numberOfMember;                     //群人数

@property (nonatomic ,strong) NSMutableArray<GroupInfoModel *> *groupEvents;       //群消息集
//@property (nonatomic ,strong) NSMutableArray *groupEvents;       //群消息集

+ (instancetype)groupWithDict:(NSDictionary *)dict;
@end
