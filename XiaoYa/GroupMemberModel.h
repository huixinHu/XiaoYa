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

+ (instancetype)memberModelWithDict:(NSDictionary *)dict;
+ (instancetype)ordinaryModelWithDict:(NSDictionary *)dict;

+ (instancetype)memberModelWithArray:(NSArray *)arr;
@end
