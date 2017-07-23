//
//  GroupListModel.h
//  XiaoYa
//
//  Created by commet on 2017/7/11.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupListModel : NSObject
@property (nonatomic ,copy)NSString *groupName;
@property (nonatomic ,copy)NSString *groupMessage;
@property (nonatomic ,copy)NSString *time;

+ (instancetype)groupWithDict:(NSDictionary *)dict;
@end
