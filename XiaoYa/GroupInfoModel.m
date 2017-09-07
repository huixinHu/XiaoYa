//
//  GroupInfoModel.m
//  XiaoYa
//
//  Created by commet on 2017/9/6.
//  Copyright © 2017年 commet. All rights reserved.
//群消息数据模型
//其实可以和GroupListModel合并

#import "GroupInfoModel.h"

@implementation GroupInfoModel
- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"yyyyMMddHHmm"];
        
        self.publishTime = [df dateFromString:[dict objectForKey:@"publishTime"]];
        self.publisher = [dict objectForKey:@"publisher"];
        self.event = [dict objectForKey:@"event"];
        self.eventTime = [dict objectForKey:@"eventTime"];
        
        NSString *sectionStr = [dict objectForKey:@"eventSection"];
        self.eventSection = [NSMutableArray array];
        if (sectionStr.length != 0) {
            NSString *subTimeStr = [sectionStr substringWithRange:NSMakeRange(1, sectionStr.length - 2)];//截去头尾“,”
            NSArray * tempArray = [subTimeStr componentsSeparatedByString:@","];//以“,”切割
            self.eventSection = [tempArray mutableCopy];
        }

        self.comment = [dict objectForKey:@"comment"];
        self.deadlineTime = [dict objectForKey:@"deadlineTime"];
    }
    return self;
}

+ (instancetype)groupInfoWithDict:(NSDictionary *)dict{
    return [[self alloc]initWithDict:dict];
}

+ (instancetype)defaultModel{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    
//    NSMutableArray *remindArray = [NSMutableArray arrayWithObject:@"6"];
    NSMutableDictionary *modelDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"197012120000",@"publishTime",@"",@"publisher",@"",@"event",currentDateStr,@"eventTime",@"",@"eventSection",@"",@"comment",@"201709091100",@"deadlineTime",nil];
    GroupInfoModel *defaultModel = [self groupInfoWithDict:modelDict];
    return defaultModel;
}
@end
