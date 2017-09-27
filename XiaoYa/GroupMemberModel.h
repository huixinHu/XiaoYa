//
//  GroupMemberModel.h
//  XiaoYa
//
//  Created by commet on 2017/7/12.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface GroupMemberModel : NSObject<NSCoding>
@property(nonatomic ,copy) NSString *memberName;
@property(nonatomic ,copy) NSString *memberId;
@property(nonatomic ,copy) NSString *memberPhone;
@property(nonatomic ,strong) UIImage *memberAvatar;

+ (instancetype)memberModelWithMemberSearchDict:(NSDictionary *)dict;
+ (instancetype)ordinaryModelWithDict:(NSDictionary *)dict;

//+ (instancetype)memberModelWithAllUsersArr:(NSArray *)arr;
//根据群组id查询群组中所有用户信息，结果(用户信息字典)转模型
+ (instancetype)memberModelWithOneOfAllUserDict:(NSDictionary *)dict;
@end
