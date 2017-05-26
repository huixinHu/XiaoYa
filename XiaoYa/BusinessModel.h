//
//  BusinessModel.h
//  XiaoYa
//
//  Created by commet on 17/2/9.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
@interface BusinessModel : NSObject
@property (nonatomic, copy)   NSString *desc;                 //描述
@property (nonatomic, copy)   NSString *comment;              //备注
@property (nonatomic, copy)   NSString *date;                 //日期yyyymmdd
@property (nonatomic ,copy)   NSString *time;                 //时间，第几节
@property (nonatomic ,copy)   NSString *repeat;               //重复的选项
@property (nonatomic ,strong) NSMutableArray *remindArray;
@property (nonatomic ,strong) NSMutableArray *timeArray;      //把time string转化成array

@property (nonatomic ,assign) BOOL intersects;//是否和课程有交集
- (id)initWithDict:(NSDictionary *)dic;
+ (instancetype)defaultModel;
- (instancetype)initWithEKevent:(EKEvent *)event;
@end
