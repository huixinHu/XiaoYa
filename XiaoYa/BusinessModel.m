//
//  BusinessModel.m
//  XiaoYa
//
//  Created by commet on 17/2/9.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "BusinessModel.h"
@interface BusinessModel()
@property (nonatomic ,strong)NSDateFormatter *dateFormatter;
@property (nonatomic ,strong)NSArray *timeSrartArray;
@property (nonatomic ,strong)NSArray *timeEndArray;
@end

@implementation BusinessModel

- (id)initWithDict:(NSDictionary *)dic
{
    if (self = [super init]) {
        if (dic != nil) {
            self.desc = [dic objectForKey:@"description"];
            self.comment = [dic objectForKey:@"comment"];
            self.date = [dic objectForKey:@"date"];
            self.time = [dic objectForKey:@"time"];
            self.repeat = [dic objectForKey:@"repeat"];
            
            self.intersects = NO;
            self.timeArray = [NSMutableArray array];
            if (self.time.length != 0) {
                NSString *subTimeStr = [self.time substringWithRange:NSMakeRange(1, self.time.length - 2)];//截去头尾“,”
                NSArray * tempArray = [subTimeStr componentsSeparatedByString:@","];//以“,”切割
                self.timeArray = [tempArray mutableCopy];
            }
            self.remindArray = [dic objectForKey:@"remind"];
        }
    }
    return self;
}

- (instancetype)initWithEKevent:(EKEvent *)event{
    if (self = [super init]) {
        //1.描述
        self.desc = event.title;
        //2.备注
        self.comment = event.notes;
        //3.日期和节数
        NSString *startDate = [self.dateFormatter stringFromDate:event.startDate];
        NSString *endDate = [self.dateFormatter stringFromDate:event.endDate];
        //日期
        self.date = [startDate substringWithRange:NSMakeRange(0, 8)];//截取前8位yyyymmdd，事件发生的日期
        NSString *startTime = [startDate substringWithRange:NSMakeRange(startDate.length - 4, 4)];//截取后四位，就是事件发生的时分字符串
        NSString *endTime = [endDate substringWithRange:NSMakeRange(endDate.length - 4, 4)];
        NSUInteger startSection = [self.timeSrartArray indexOfObject:startTime];
        NSUInteger endSection = [self.timeEndArray indexOfObject:endTime];
        self.timeArray = [NSMutableArray array];
        [self.timeArray addObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithUnsignedInteger:startSection]]];
        if (startSection < endSection) {
            for (; startSection < endSection; startSection++) {
                [self.timeArray addObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithUnsignedInteger:startSection + 1]]];
            }
        }
        //4.重复规则
        if (event.recurrenceRules.count > 0) {
            EKRecurrenceRule *rule = event.recurrenceRules[0];
            switch (rule.frequency) {
                case EKRecurrenceFrequencyDaily:
                    if (rule.interval == 1) {
                        if (rule.daysOfTheWeek == nil) {
                            self.repeat = [NSString stringWithFormat:@"%@",@0];
                        }else{
                            self.repeat = [NSString stringWithFormat:@"%@",@5];
                        }
                    }else if (rule.interval == 2){
                        self.repeat = [NSString stringWithFormat:@"%@",@1];
                    }
                    break;
                case EKRecurrenceFrequencyWeekly:
                    self.repeat = [NSString stringWithFormat:@"%@",@2];
                    break;
                case EKRecurrenceFrequencyMonthly:
                    self.repeat = [NSString stringWithFormat:@"%@",@3];
                    break;
                case EKRecurrenceFrequencyYearly:
                    self.repeat = [NSString stringWithFormat:@"%@",@4];
                    break;
                default:
                    self.repeat = [NSString stringWithFormat:@"%@",@6];
                    break;
            }
        }else{
            self.repeat = [NSString stringWithFormat:@"%@",@6];
        }
        
        //5.提醒
        self.remindArray = [NSMutableArray array];
        if (event.alarms.count > 0) {
            for (int i = 0; i < event.alarms.count; i++) {
                double relativeOffest = event.alarms[i].relativeOffset;
                if (fabs(relativeOffest + 0) < exp(-6)) {
                    [self.remindArray addObject:@"0"];
                }else if (fabs(relativeOffest + 300) < exp(-6)){
                    [self.remindArray addObject:@"1"];
                }else if (fabs(relativeOffest + 900) < exp(-6)){
                    [self.remindArray addObject:@"2"];
                }else if (fabs(relativeOffest + 1800) < exp(-6)){
                    [self.remindArray addObject:@"3"];
                }else if (fabs(relativeOffest + 3600) < exp(-6)){
                    [self.remindArray addObject:@"4"];
                }else if (fabs(relativeOffest + 60*60*24) < exp(-6)){
                    [self.remindArray addObject:@"5"];
                }
            }
        }else{
            [self.remindArray addObject:@"6"];
        }
        [self.remindArray sortUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2){
            if ([obj1 integerValue] < [obj2 integerValue]){
                return NSOrderedAscending;
            }else{
                return NSOrderedDescending;
            }
        }];
        //交集
        self.intersects = NO;
    }
    return self;
}

+ (instancetype)defaultModel{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    NSMutableArray *remindArray = [NSMutableArray arrayWithObject:@"6"];    
    NSMutableDictionary *modelDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"",@"description",@"",@"comment",currentDateStr,@"date",@"",@"time",@"6",@"repeat",remindArray,@"remind",nil];
    BusinessModel *defaultModel = [[BusinessModel alloc]initWithDict:modelDict];
    return defaultModel;
}

- (NSDateFormatter*)dateFormatter{
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc]init];
        [_dateFormatter setDateFormat:@"yyyyMMddHHmm"];
    }
    return _dateFormatter;
}

- (NSArray *)timeSrartArray{
    if (_timeSrartArray == nil) {
        _timeSrartArray = @[@"0600",@"0800",@"0855",@"1000",@"1055",@"1140",@"1430",@"1525",@"1620",@"1715",@"1810",@"1900",@"1955",@"2050",@"2200"];
    }
    return _timeSrartArray;
}

- (NSArray *)timeEndArray{
    if (_timeEndArray == nil) {
        _timeEndArray = @[@"0759",@"0854",@"0959",@"1054",@"1139",@"1429",@"1524",@"1619",@"1714",@"1809",@"1854",@"1954",@"2049",@"2144",@"2359"];
    }
    return _timeEndArray;
}
@end
