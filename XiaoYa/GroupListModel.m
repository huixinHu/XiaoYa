//
//  GroupListModel.m
//  XiaoYa
//
//  Created by commet on 2017/7/11.
//  Copyright © 2017年 commet. All rights reserved.
// 群首页群数据模型

#import "GroupListModel.h"

@implementation GroupListModel

- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.groupName = dict[@"groupName"];
        self.groupMessage = dict[@"groupMessage"];
        self.time = dict[@"time"];
//        self.jsonKey = dict[@"jsonKey"];
    }
    return self;
}

+ (instancetype)groupWithDict:(NSDictionary *)dict{
    return [[self alloc]initWithDict:dict];
}

@end
