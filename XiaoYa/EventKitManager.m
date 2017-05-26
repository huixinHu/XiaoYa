//
//  EventKitManager.m
//  XiaoYa
//
//  Created by commet on 17/4/4.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "EventKitManager.h"

@interface EventKitManager()<NSCopying,NSMutableCopying>
@property (nonatomic ,strong)NSDateFormatter *dateFormatter;
@property (nonatomic ,strong)NSDateComponents *components;
@property (nonatomic ,strong)NSArray *timeSrartArray;
@property (nonatomic ,strong)NSArray *timeEndArray;
@property (nonatomic ,strong)EKCalendar *cal;
@end

@implementation EventKitManager
static EventKitManager* _instance = nil;
- (void)commitEvent{
    NSError *error =nil;
    BOOL commitSuccess= [self.eventStore commit:&error];
    if(!commitSuccess) {
        NSLog(@"一次性提交事件失败，%@",error);
    }else{
        NSLog(@"成功一次性提交事件,%s",__func__);
    }
}

//dateString只有年月日没有时分秒
- (void)addEventNotifyWithTitle:(NSString*)title dateString:(NSString*)dateString startSection:(NSString *)startSection endSection:(NSString *)endSection repeatIndex:(NSInteger)repeatindex alarmSettings:(NSArray *)remindIndexs note:(NSString*)notes{
    int start = startSection.intValue;
    int end = endSection.intValue;
    if (start<0||start>14||end<0||end>14||startSection == nil||endSection == nil) {
        return;
    }
    EKEvent *event = [EKEvent eventWithEventStore:self.eventStore];
    event.title = title;//1.标题
    event.startDate = [self.dateFormatter dateFromString:[dateString stringByAppendingString:[self sectionStartTime:startSection]]];//2.开始时间
    event.endDate = [self.dateFormatter dateFromString:[dateString stringByAppendingString:[self sectionEndTime:endSection]]];//3.结束时间
    EKRecurrenceRule *rule = [self repeatRule:repeatindex currentDate:dateString];//4.重复规则
    if (rule != nil) {
        event.recurrenceRules = @[rule];
    }else{
        event.recurrenceRules = nil;
    }
    event.notes = notes;//6.备注
    [event setAllDay:NO];//设置全天
    //5.设置提醒
    for (int i = 0; i < remindIndexs.count; i++) {
        EKAlarm *alarm = [self alarmsSettingWithIndex:[remindIndexs[i] intValue]];
        if (alarm == nil) {
            event.alarms = nil;
            break;
        }
        [event addAlarm:alarm];
    }
    [event setCalendar:self.cal];//设置日历类型
    //保存事件
    NSError *err = nil;
    if([self.eventStore saveEvent:event span:EKSpanThisEvent commit:NO error:nil]){//注意这里是no，在外部调用完这个add方法之后一定要commit
        NSLog(@"创建事件到系统日历成功!,%@",title);
//        return YES;
    }else{
        NSLog(@"创建失败%@",err);
//        return NO;
    }
}

//@[@"当事件发生时",@"5分钟前",@"15分钟前",@"30分钟前",@"1小时前",@"1天前",@"不提醒"]
- (EKAlarm *)alarmsSettingWithIndex:(int )remindIndex{
    EKAlarm *alarm;
    switch (remindIndex) {
        case 0:
            alarm = [EKAlarm alarmWithRelativeOffset:0];
            break;
        case 1:
            alarm = [EKAlarm alarmWithRelativeOffset:- 60.0 * 5];
            break;
        case 2:
            alarm = [EKAlarm alarmWithRelativeOffset:- 60.0 * 15];
            break;
        case 3:
            alarm = [EKAlarm alarmWithRelativeOffset:-60.0 * 30];
            break;
        case 4:
            alarm = [EKAlarm alarmWithRelativeOffset:-60.0 * 60];
            break;
        case 5:
            alarm = [EKAlarm alarmWithRelativeOffset:-60.0 * 60 * 24];
            break;
        case 6:
            alarm = nil;
            break;
        default:
            alarm = nil;
            break;
    }
    return alarm;
}

//- (NSArray *)checkEventWithDateString:(NSString *)dateString startSection:(NSString *)startSection endSection:(NSString *)endSection{
//    NSDate *startDate = [self.dateFormatter dateFromString:[dateString stringByAppendingString:[self sectionStartTime:startSection]]];//开始时间
//    NSDate *endDate = [self.dateFormatter dateFromString:[dateString stringByAppendingString:[self sectionEndTime:endSection]]];//结束时间
//    NSPredicate*predicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
//    NSArray *eventArray = [self.eventStore eventsMatchingPredicate:predicate];
//    NSMutableArray *xiaoYaEvent = [NSMutableArray array];
//    for (int i = 0; i < eventArray.count; i++) {
//        EKEvent * event = eventArray[i];
//        NSString *startTime = [self.dateFormatter stringFromDate:event.startDate];
//        startTime = [startTime substringWithRange:NSMakeRange(startTime.length - 4, 4)];//截取后四位，就是事件发生的时分字符串
//        NSString *endTime = [self.dateFormatter stringFromDate:event.endDate];
//        endTime = [endTime substringWithRange:NSMakeRange(endTime.length - 4, 4)];
//        if ([self.timeSrartArray containsObject:startTime]&&[self.timeEndArray containsObject:endTime]) {//剔除非app添加的日历事务
//            [xiaoYaEvent addObject:event];
//        }
//    }
//    return xiaoYaEvent;//这个array有可能count=0
//}

//查询。返回所有符合条件的事件
- (NSArray *)checkEventWithDateString:(NSArray *)dateStrArray startSection:(NSString *)startSection endSection:(NSString *)endSection{
    int start = startSection.intValue;
    int end = endSection.intValue;
    if (dateStrArray == nil ||dateStrArray.count == 0 || startSection == nil || endSection == nil||start<0||start>14||end<0||end>14) {
        return nil;
    }
    NSMutableArray *xiaoYaEvent = [NSMutableArray array];
    for (int i = 0; i < dateStrArray.count; i++) {
        NSString *dateString = dateStrArray[i];
        NSDate *startDate = [self.dateFormatter dateFromString:[dateString stringByAppendingString:[self sectionStartTime:startSection]]];//开始时间
        NSDate *endDate = [self.dateFormatter dateFromString:[dateString stringByAppendingString:[self sectionEndTime:endSection]]];//结束时间
        NSPredicate*predicate = [self.eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:@[self.cal]];
        NSArray *eventArray = [self.eventStore eventsMatchingPredicate:predicate];
        for (int i = 0; i < eventArray.count; i++) {
            [xiaoYaEvent addObject:eventArray[i]];
        }
    }
    return xiaoYaEvent;//这个array有可能count=0
}

//- (void)removeEventNotifyWithCurrentDateString:(NSString *)dateString startSection:(NSString *)startSection endSection:(NSString *)endSection isDeleteFuture:(BOOL)deleteFuture{
//    if (startSection == nil || startSection == nil) {
//        return;
//    }
//    NSString *startDateStr = [dateString stringByAppendingString:[self sectionStartTime:startSection]];
//    NSString *endDateStr = [dateString stringByAppendingString:[self sectionEndTime:endSection]];
//    NSArray *eventArray = [self checkEventWithDateString:dateString startSection:startSection endSection:endSection];
//    if (eventArray.count > 0) {
//        for (int i = 0; i < eventArray.count; i++) {
//            EKEvent * event = eventArray[i];
//            NSString *queryEventStartDateStr = [self.dateFormatter stringFromDate:event.startDate];
//            NSString *queryEventEndDateStr = [self.dateFormatter stringFromDate:event.endDate];
//            if ([queryEventStartDateStr isEqualToString:startDateStr] && [queryEventEndDateStr isEqualToString:endDateStr]) {//防止误删日历中的其他事件
//                [event setCalendar:[self.eventStore defaultCalendarForNewEvents]];
//                NSError*error = nil;
//                BOOL successDelete;
//                if (deleteFuture) {
//                    successDelete = [self.eventStore removeEvent:event span:EKSpanFutureEvents commit:NO error:&error];
//                }else{
//                    successDelete = [self.eventStore removeEvent:event span:EKSpanThisEvent commit:NO error:&error];
//                }
//                //        BOOL successDelete = [self.eventStore removeEvent:event span:EKSpanFutureEvents commit:NO error:&error];
//                //    if(!successDelete) {
//                //        NSLog(@"删除本条事件失败");
//                //    }else{
//                //        NSLog(@"删除本条事件成功，%@",error);
//                //    }
//            }
//        }
//        //一次提交所有操作到事件库
//        [self commitEvent];
//        // 注意添加和删除时方法里都有一个 commit:(BOOL)commit 参数。yes:表示立即把此次操作提交到系统事件库，NO表示此时不提交。如果一次性操作的事件数比较少的话，可以每次都传YES，实时更新事件数据库。如果一次性操作的事件较多的话，可以每次传NO，最后再执行一次提交所有更改到数据库，把原来的更改全部提交到数据库，不管是添加还是删除。
//    }
//}

//删除指定条件的事件
- (void)removeEventNotifyWithCurrentDateString:(NSArray *)dateStrArray startSection:(NSString *)startSection endSection:(NSString *)endSection isDeleteFuture:(BOOL)deleteFuture{
    int start = startSection.intValue;
    int end = endSection.intValue;
    if (dateStrArray == nil ||dateStrArray.count == 0 || startSection == nil || startSection == nil||start<0||start>14||end<0||end>14) {
        return;
    }
    NSArray *eventArray = [self checkEventWithDateString:dateStrArray startSection:startSection endSection:endSection];
    if (eventArray.count > 0) {
        for (int i = 0; i < eventArray.count; i++) {
            EKEvent * event = eventArray[i];
            [event setCalendar:self.cal];
            NSError *error = nil;
            BOOL successDelete;
            if (deleteFuture) {
                successDelete = [self.eventStore removeEvent:event span:EKSpanFutureEvents commit:NO error:&error];
            }else{
                successDelete = [self.eventStore removeEvent:event span:EKSpanThisEvent commit:NO error:&error];
            }

//            if(!successDelete) {
//                NSLog(@"删除本条事件失败");
//            }else{
//                NSLog(@"删除本条事件成功，%@",error);
//            }
        }
        //一次提交所有操作到事件库
        [self commitEvent];
        // 注意添加和删除时方法里都有一个 commit:(BOOL)commit 参数。yes:表示立即把此次操作提交到系统事件库，NO表示此时不提交。如果一次性操作的事件数比较少的话，可以每次都传YES，实时更新事件数据库。如果一次性操作的事件较多的话，可以每次传NO，最后再执行一次提交所有更改到数据库，把原来的更改全部提交到数据库，不管是添加还是删除。
    }
}

- (NSString*)sectionStartTime:(NSString *)startSection{
    return self.timeSrartArray[startSection.intValue];
}

- (NSString *)sectionEndTime:(NSString *)endSection{
    return self.timeEndArray[endSection.intValue];
}

//重复规则，统一3年后止
- (EKRecurrenceRule *)repeatRule:(NSInteger)repeatIndex currentDate:(NSString*)dateString{
    NSDate *currentDate = [self.dateFormatter dateFromString:[dateString stringByAppendingString:@"0000"]];
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:currentDate];
    components.year += 1;
    NSDate *recurrenceEndDate = [gregorian dateFromComponents:components];//高频率：每天、每两天、工作日
    NSDateComponents *components2 = [gregorian components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:currentDate];
    components2.year += 3;
    NSDate *recurrenceEndDate2 = [gregorian dateFromComponents:components2];//低频率：每周、每月、每年

    EKRecurrenceRule * rule;
    switch (repeatIndex) {
        case 0://每天
            rule = [[EKRecurrenceRule alloc]initRecurrenceWithFrequency:EKRecurrenceFrequencyDaily interval:1 daysOfTheWeek:nil daysOfTheMonth:nil monthsOfTheYear:nil weeksOfTheYear:nil daysOfTheYear:nil setPositions:nil end:[EKRecurrenceEnd recurrenceEndWithEndDate:recurrenceEndDate]];
            break;
        case 1://每两天
            rule = [[EKRecurrenceRule alloc]initRecurrenceWithFrequency:EKRecurrenceFrequencyDaily interval:2 daysOfTheWeek:nil daysOfTheMonth:nil monthsOfTheYear:nil weeksOfTheYear:nil daysOfTheYear:nil setPositions:nil end:[EKRecurrenceEnd recurrenceEndWithEndDate:recurrenceEndDate]];
            break;
        case 2://每周
            rule = [[EKRecurrenceRule alloc]initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly interval:1 daysOfTheWeek:nil daysOfTheMonth:nil monthsOfTheYear:nil weeksOfTheYear:nil daysOfTheYear:nil setPositions:nil end:[EKRecurrenceEnd recurrenceEndWithEndDate:recurrenceEndDate2]];
            break;
        case 3://每月
            rule = [[EKRecurrenceRule alloc]initRecurrenceWithFrequency:EKRecurrenceFrequencyMonthly interval:1 daysOfTheWeek:nil daysOfTheMonth:nil monthsOfTheYear:nil weeksOfTheYear:nil daysOfTheYear:nil setPositions:nil end:[EKRecurrenceEnd recurrenceEndWithEndDate:recurrenceEndDate2]];
            break;
        case 4://每年
            rule = [[EKRecurrenceRule alloc]initRecurrenceWithFrequency:EKRecurrenceFrequencyYearly interval:1 daysOfTheWeek:nil daysOfTheMonth:nil monthsOfTheYear:nil weeksOfTheYear:nil daysOfTheYear:nil setPositions:nil end:[EKRecurrenceEnd recurrenceEndWithEndDate:recurrenceEndDate2]];
            break;
        case 5://工作日
            rule = [[EKRecurrenceRule alloc]initRecurrenceWithFrequency:EKRecurrenceFrequencyDaily interval:1 daysOfTheWeek:[NSArray arrayWithObjects:[EKRecurrenceDayOfWeek dayOfWeek:2],[EKRecurrenceDayOfWeek dayOfWeek:3],[EKRecurrenceDayOfWeek dayOfWeek:4],[EKRecurrenceDayOfWeek dayOfWeek:5],[EKRecurrenceDayOfWeek dayOfWeek:6],nil] daysOfTheMonth:nil monthsOfTheYear:nil weeksOfTheYear:nil daysOfTheYear:nil setPositions:nil end:[EKRecurrenceEnd recurrenceEndWithEndDate:recurrenceEndDate]];
            break;
        case 6:
            rule = nil;
            break;
        default:
            rule = nil;
            break;
    }
    return rule;
}

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    
    return _instance ;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [EventKitManager shareInstance] ;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [EventKitManager shareInstance] ;//return _instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [EventKitManager shareInstance] ;
}

- (EKEventStore *)eventStore{
    if(_eventStore == nil){
        _eventStore = [[EKEventStore alloc] init];
    }
    return _eventStore;
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

- (EKCalendar *)cal{
    if (_cal == nil) {
        BOOL shouldAdd = YES;
        EKCalendar *calendar;
        for (EKCalendar *ekcalendar in [_eventStore calendarsForEntityType:EKEntityTypeEvent]) {
            if ([ekcalendar.title isEqualToString:@"小雅"] ) {
                shouldAdd = NO;
                calendar = ekcalendar;
            }
        }
        if (shouldAdd) {
            EKSource *localSource = nil;
            for (EKSource *source in _eventStore.sources){
                if (source.sourceType == EKSourceTypeCalDAV && [source.title isEqualToString:@"iCloud"]){//获取iCloud源
                    localSource = source;
                    break;
                }
            }
            if (localSource == nil){
                for (EKSource *source in _eventStore.sources) {//获取本地Default源
                    if (source.sourceType == EKSourceTypeLocal){
                        localSource = source;
                        break;
                    }
                }
            }
            calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:_eventStore];
            calendar.source = localSource;
            calendar.title = @"小雅";//自定义日历标题
            calendar.CGColor = [UIColor greenColor].CGColor;//自定义日历颜色
            NSError* error;
            [_eventStore saveCalendar:calendar commit:YES error:&error];
        }
        _cal = calendar;
    }
    return _cal;
}

@end
