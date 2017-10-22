//
//  GroupMemberModel.m
//  XiaoYa
//
//  Created by commet on 2017/7/12.
//  Copyright © 2017年 commet. All rights reserved.
// 成员模型

#import "GroupMemberModel.h"
#import "TxAvatar.h"
#import <objc/runtime.h>
@implementation GroupMemberModel

- (instancetype)initWithMemberSearchDict:(NSDictionary *)dict {
    if (self = [super init]) {
        NSString *infoStr = [dict objectForKey:@"identity"];
        NSArray *infoArr = [infoStr componentsSeparatedByString:@","];
        self.memberId = [infoArr[0] copy];
        self.memberName = [infoArr[1] copy];
        self.memberPhone = [infoArr[2] copy];
        
        NSString *avaText = [NSString string];
        if (self.memberName.length > 2) {
            avaText = [self.memberName substringWithRange:NSMakeRange(self.memberName.length - 2, 2)];
        }else{
            avaText = self.memberName;
        }
        CGFloat avaFontSize = 0;
        if (avaText.length == 2) {
            avaFontSize = 18;
        }else{
            avaFontSize = 24.0;
        }
        self.memberAvatar = [TxAvatar avatarWithText:avaText fontSize:avaFontSize longside:50];
    }
    return self;
}

//根据手机号搜索某个群成员，结果转模型
+ (instancetype)memberModelWithMemberSearchDict:(NSDictionary *)dict {
    return [[self alloc] initWithMemberSearchDict:dict];
}

- (instancetype)initOrdinaryModelWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.memberId = [dict objectForKey:@"memberId"];
        self.memberName = [dict objectForKey:@"memberName"];
        self.memberPhone = [dict objectForKey:@"memberPhone"];
        if ([dict objectForKey:@"memberAvatar"]) {
            self.memberAvatar = [UIImage imageNamed:[dict objectForKey:@"memberAvatar"]];
        } else{
            NSString *avaText = [NSString string];
            if (self.memberName.length > 2) {
                avaText = [self.memberName substringWithRange:NSMakeRange(self.memberName.length - 2, 2)];
            }else{
                avaText = self.memberName;
            }
            CGFloat avaFontSize = 0;
            if (avaText.length == 2) {
                avaFontSize = 18;
            }else{
                avaFontSize = 24.0;
            }
            self.memberAvatar = [TxAvatar avatarWithText:avaText fontSize:avaFontSize longside:50];
        }
    }
    return self;
}

//从数据库查找数据，转模型
//或者某些空模型
+ (instancetype)ordinaryModelWithDict:(NSDictionary *)dict{
    return [[self alloc] initOrdinaryModelWithDict:dict];
}

//- (instancetype)initWithArr:(NSArray *)arr{
//    if (self = [super init]) {
//        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSDictionary *userDict = (NSDictionary *)obj;
//            self.memberId = userDict[@"id"];
//        }];
//    }
//    return  self;
//}
//
////根据群组id查询群组中所有用户信息，结果转模型
//+ (instancetype)memberModelWithAllUsersArr:(NSArray *)arr{
//    return [[self alloc]initWithArr:arr];
//}

//根据群组id查询群组中所有用户信息，结果(用户信息字典)转模型
- (instancetype)initWithOneOfAllUserDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.memberId = [NSString stringWithFormat:@"%@",dict[@"id"]];//要显式转成nsstring，dict[@"id"]得到的是long
        self.memberName = dict[@"userName"];
        self.memberPhone = dict[@"mobile"];
        
        NSString *avaText = [NSString string];
        if (self.memberName.length > 2) {
            avaText = [self.memberName substringWithRange:NSMakeRange(self.memberName.length - 2, 2)];
        }else{
            avaText = self.memberName;
        }
        CGFloat avaFontSize = 0;
        if (avaText.length == 2) {
            avaFontSize = 18;
        }else{
            avaFontSize = 24.0;
        }
        self.memberAvatar = [TxAvatar avatarWithText:avaText fontSize:avaFontSize longside:50];
    }
    return self;
}

+ (instancetype)memberModelWithOneOfAllUserDict:(NSDictionary *)dict{
    return [[self alloc]initWithOneOfAllUserDict:dict];
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

- (id)copyWithZone:(NSZone *)zone{
    GroupMemberModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
    return model;
}
@end
