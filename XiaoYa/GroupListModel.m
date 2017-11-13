//
//  GroupListModel.m
//  XiaoYa
//
//  Created by commet on 2017/7/11.
//  Copyright © 2017年 commet. All rights reserved.
// （群首页）群数据模型

#import "GroupListModel.h"
#import "GroupMemberModel.h"
#import <objc/runtime.h>
@implementation GroupListModel

- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.groupName = dict[@"groupName"];
        self.groupId = dict[@"groupId"];
        self.groupAvatarId = dict[@"groupAvatarId"];
        self.groupMembers = dict[@"groupMembers"];
        self.numberOfMember = [dict[@"numberOfMember"] integerValue];
        self.groupManagerId = dict[@"groupManagerId"];
        self.deleteFlag = [dict[@"deleteFlag"] integerValue];
    }
    return self;
}

+ (instancetype)groupWithDict:(NSDictionary *)dict{
    return [[self alloc]initWithDict:dict];
}

- (id)copyWithZone:(NSZone *)zone{
    GroupListModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
    return model;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i++) {
        const char *propertyName = property_getName(properties[i]);
        NSString *name = [NSString stringWithUTF8String:propertyName];
        id value = [self valueForKey:name];
        [aCoder encodeObject:value forKey:name];
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        unsigned int count = 0;
        objc_property_t *properties = class_copyPropertyList([self class], &count);
        for (int i = 0; i < count; i++) {
            const char *propertyName = property_getName(properties[i]);
            NSString *name = [NSString stringWithUTF8String:propertyName];
            id value = [aDecoder decodeObjectForKey:name];
            [self setValue:value forKey:name];
        }
    }
    return self;
    
}

@end
