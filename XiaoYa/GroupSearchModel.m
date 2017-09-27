//
//  GroupSearchModel.m
//  XiaoYa
//
//  Created by commet on 2017/7/25.
//  Copyright © 2017年 commet. All rights reserved.
// 群搜索结果的数据模型

#import "GroupSearchModel.h"

@implementation GroupSearchModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.managerName = dict[@"managerName"];
        self.groupId = dict[@"id"];
        self.groupName = dict[@"groupName"];
        self.managerId = dict[@"managerId"];
        self.avatarId = [dict[@"picId"] integerValue];
        self.numberOfMember = [dict[@"amount"] integerValue];
    }
    return self;
}

+ (instancetype)groupModelWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

@end
