//
//  GroupInfoModel.h
//  XiaoYa
//
//  Created by commet on 2017/9/6.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupInfoModel : NSObject
@property (nonatomic ,strong) NSDate *publishTime;//发布时间
@property (nonatomic ,copy) NSString *publisher;//发布者
@property (nonatomic ,copy) NSString *event;//事件
@property (nonatomic ,copy) NSString *eventTime;//事件时间
@property (nonatomic ,strong) NSMutableArray *eventSection;//时间节数
@property (nonatomic ,copy) NSString *comment;//备注
@property (nonatomic ,copy) NSString *deadlineTime;//截止回复时间

+ (instancetype)groupInfoWithDict:(NSDictionary *)dict;
+ (instancetype)defaultModel;
@end
