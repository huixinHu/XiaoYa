//
//  GroupInfoModel.m
//  XiaoYa
//
//  Created by commet on 2017/9/6.
//  Copyright © 2017年 commet. All rights reserved.
//群消息数据模型
//其实可以和GroupListModel合并

#import "GroupInfoModel.h"
#import "Utils.h"
#import "AppDelegate.h"
#import <objc/runtime.h>
@interface GroupInfoModel()
@property (nonatomic ,strong) NSArray *timeSrartArray;
@end

@implementation GroupInfoModel
- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"yyyyMMddHHmmss"];
        self.publishTime = [dict objectForKey:@"publishTime"];
//        self.publishTime = [df dateFromString:[dict objectForKey:@"publishTime"]];
        self.publisher = [dict objectForKey:@"publisher"];
        self.event = [dict objectForKey:@"event"];
        self.eventDate = [dict objectForKey:@"eventDate"];
        self.comment = [dict objectForKey:@"comment"];
        self.deadlineIndex = [[dict objectForKey:@"deadlineIndex"] integerValue];
        
        NSString *sectionStr = [dict objectForKey:@"eventSection"];
        self.eventSection = [NSMutableArray array];
        self.deadlineTime = [NSString string];
        if (sectionStr.length != 0) {
            NSString *subTimeStr = [sectionStr substringWithRange:NSMakeRange(1, sectionStr.length - 2)];//截去头尾“,”
            NSArray * tempArray = [subTimeStr componentsSeparatedByString:@","];//以“,”切割
            self.eventSection = [tempArray mutableCopy];
            [Utils sortArrayFromMinToMax:self.eventSection];
            
            int sectionIndex = [self.eventSection[0] intValue];
            NSString *sectionStartTime = self.timeSrartArray[sectionIndex];
            NSString *exactTime = [NSString stringWithFormat:@"%@%@",self.eventDate,sectionStartTime];
            NSDate *exactDate = [df dateFromString:exactTime];
            NSTimeInterval ti = 0;
            switch (self.deadlineIndex) {
                case 0:
                    ti = 0;
                    break;
                case 1:
                    ti = -12*3600;
                    break;
                case 2:
                    ti = -24*3600;
                    break;
                case 3:
                    ti = -36*3600;
                    break;
                case 4:
                    ti = -48*3600;
                    break;
                case 5:
                    ti = -7*24*3600;
                case 6:
                    ti = -30*24*3600;
                    break;
                default:
                    break;
            }
            NSDate *dlDate = [NSDate dateWithTimeInterval:ti sinceDate:exactDate];
            self.deadlineTime = [df stringFromDate:dlDate];
        }
        self.groupId = [dict objectForKey:@"groupId"];
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
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *user = [NSString stringWithFormat:@"%@(%@)",appDelegate.userName,appDelegate.userid];
    
    NSMutableDictionary *modelDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"197112120000000000",@"publishTime",user,@"publisher",@"",@"event",currentDateStr,@"eventDate",@"",@"eventSection",@"",@"comment",@"0",@"deadlineIndex",@"0",@"groupId",nil];
    GroupInfoModel *defaultModel = [self groupInfoWithDict:modelDict];
    return defaultModel;
}

- (NSArray *)timeSrartArray{
    if (_timeSrartArray == nil) {
        _timeSrartArray = @[@"060000",@"080000",@"085500",@"100000",@"105500",@"114000",@"143000",@"152500",@"162000",@"171500",@"181000",@"190000",@"195500",@"205000",@"220000"];
    }
    return _timeSrartArray;
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

- (id)copyWithZone:(NSZone *)zone{
    GroupInfoModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
    return model;
}
@end
