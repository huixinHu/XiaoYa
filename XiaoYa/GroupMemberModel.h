//
//  GroupMemberModel.h
//  XiaoYa
//
//  Created by commet on 2017/7/12.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupMemberModel : NSObject
@property(nonatomic ,copy) NSString *memberName;
@property(nonatomic ,copy) NSString *memberAvatar;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)memberModelWithDict:(NSDictionary *)dict;
@end
