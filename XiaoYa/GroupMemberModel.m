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

- (instancetype)initWithDict:(NSDictionary *)dict {
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

+ (instancetype)memberModelWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

- (instancetype)initOrdinaryModelWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.memberId = [dict objectForKey:@"memberId"];
        self.memberName = [dict objectForKey:@"memberName"];
        self.memberPhone = [dict objectForKey:@"memberPhone"];
        self.memberAvatar = [UIImage imageNamed:[dict objectForKey:@"memberAvatar"]];
    }
    return self;
}

+ (instancetype)ordinaryModelWithDict:(NSDictionary *)dict{
    return [[self alloc] initOrdinaryModelWithDict:dict];
}

- (instancetype)initWithArray:(NSArray *)arr{
    if (self = [super init]) {
        self.memberId = arr[0];
        self.memberName = arr[1];
        self.memberPhone = arr[2];
    }
    return  self;
}

+ (instancetype)memberModelWithArray:(NSArray *)arr{
    return [[self alloc]initWithArray:arr];
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
