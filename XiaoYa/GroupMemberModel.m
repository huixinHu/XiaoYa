//
//  GroupMemberModel.m
//  XiaoYa
//
//  Created by commet on 2017/7/12.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "GroupMemberModel.h"

@implementation GroupMemberModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.memberAvatar = dict[@"memberAvatar"];
        self.memberName = dict[@"memberName"];
    }
    return self;
}

+ (instancetype)memberModelWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}
@end
