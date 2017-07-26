//
//  GroupSearchModel.h
//  XiaoYa
//
//  Created by commet on 2017/7/25.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupSearchModel : NSObject
@property (nonatomic ,copy)NSString *groupId;
@property (nonatomic ,copy)NSString *groupName;
@property (nonatomic ,copy)NSString *managerId;
@property (nonatomic ,copy)NSString *managerName;

+ (instancetype)groupModelWithDict:(NSDictionary *)dict;
@end
