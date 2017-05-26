//
//  EventKitManager.h
//  XiaoYa
//
//  Created by commet on 17/4/4.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@interface EventKitManager : NSObject
@property (nonatomic ,strong)EKEventStore *eventStore;

+ (instancetype)shareInstance;
- (void)commitEvent;

//事件标题、事件日期yyyymmdd、开始节数、结束节数、重复项、提醒数组、备注
- (void)addEventNotifyWithTitle:(NSString*)title dateString:(NSString*)dateString startSection:(NSString *)startSection endSection:(NSString *)endSection repeatIndex:(NSInteger)repeatindex alarmSettings:(NSArray *)remindIndexs note:(NSString*)notes;
//- (NSArray *)checkEventWithDateString:(NSString *)dateString startSection:(NSString *)startSection endSection:(NSString *)endSection;
//- (void)removeEventNotifyWithCurrentDateString:(NSString *)dateString startSection:(NSString *)startSection endSection:(NSString *)endSection isDeleteFuture:(BOOL)deleteFuture;

- (NSArray *)checkEventWithDateString:(NSArray *)dateStrArray startSection:(NSString *)startSection endSection:(NSString *)endSection;
- (void)removeEventNotifyWithCurrentDateString:(NSArray *)dateStrArray startSection:(NSString *)startSection endSection:(NSString *)endSection isDeleteFuture:(BOOL)deleteFuture;
@end
