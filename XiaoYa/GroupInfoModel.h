//
//  GroupInfoModel.h
//  XiaoYa
//
//  Created by commet on 2017/9/6.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupInfoModel : NSObject<NSCopying ,NSCoding>
@property (nonatomic ,copy) NSString *publishTime;//发布时间           yyyyMMddHHmmss+四位随机
@property (nonatomic ,copy) NSString *publisher;//发布者               姓名(id)
@property (nonatomic ,copy) NSString *event;//事件
@property (nonatomic ,copy) NSString *eventDate;//事件时间              yyyyMMdd
@property (nonatomic ,strong) NSMutableArray *eventSection;//时间节数   ,0,1,2,....
@property (nonatomic ,copy) NSString *comment;//备注
@property (nonatomic ,assign) NSInteger deadlineIndex;//截止选项        0
@property (nonatomic ,copy) NSString *deadlineTime;//截止回复时间

@property (nonatomic ,copy) NSString *groupId;

+ (instancetype)groupInfoWithDict:(NSDictionary *)dict;
+ (instancetype)defaultModel;
@end
