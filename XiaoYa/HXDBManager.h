//
//  HXDBManager.h
//  XiaoYa
//
//  Created by commet on 2017/9/25.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GROUPINFO_TABLE groupinfoTable
#define MEMBER_TABLE memberTable
#define GROUPMESSAGE_TABLE messageTable
#define G_M_RELATIVE relativeTable
@class FMDatabaseQueue;

typedef NS_ENUM(NSInteger ,HXDBActionType) {
    HXDBSELECT = 0, //查询操作
    HXDBINSERT,     //插入操作
    HXDBUPDATE,     //更新操作
    HXDBDELETE,     //删除操作
    HXDBELSE,       //其他
};

static NSString * groupTable = @"groupTable";
static NSString * memberTable = @"memberTable";
static NSString * memberGroupRelation = @"memberGroupRelation";
static NSString * groupInfoTable = @"groupInfoTable";

@interface HXDBManager : NSObject
+ (HXDBManager *)shareInstance;
- (FMDatabaseQueue *)dbQueue;
- (void)changeFilePath:(NSString *)path;
- (BOOL)tableCreate:(NSString *)sql table:(NSString *)tableName;
- (BOOL)createTable:(NSString *)tableName colDict:(NSDictionary *)dict isPrimaryKey:(BOOL)isPK primaryKeyIndex:(NSInteger )pkIndex;
- (void)dropTable:(NSString *)tableName callback:(void(^)(NSError *error ))block;

- (void)insertTable:(NSString *)tableName param:(NSDictionary *)paraDict callback:(void(^)(NSError *error ))block;
- (void)insertTableInTransaction:(NSString *)tableName paramArr:(NSArray <NSDictionary *>*)paraArr callback:(void(^)(NSError *error))block;
- (void)updateTable:(NSString *)tableName param:(NSDictionary *)paraDict whereArr:(NSArray *)whereArr callback:(void(^)(NSError *error ))block;
- (void)updateTableInTransaction:(NSString *)tableName paramArr:(NSArray <NSDictionary *>*)paraArr whereArrs:(NSArray <NSArray *>*)whereArr callback:(void(^)(NSError *error))block;
- (void)deleteTable:(NSString *)tableName whereArr:(NSArray *)whereArr callback:(void(^)(NSError *error))block;
- (void)deleteTableInTransaction:(NSString *)tableName whereArrs:(NSArray <NSArray *>*)whereArrs callback:(void(^)(NSError *error))block;
- (void)updateWithSqlStat:(NSString *)sql actionTypr:(HXDBActionType)type callback:(void(^)(NSError *error ))block;
- (void)updateWithSqlStatInTransaction:(NSArray <NSString *> *)sqlArr actionTypr:(HXDBActionType)type callback:(void(^)(NSError *error))block;

- (int)itemCountForTable:(NSString *)tableName whereArr:(NSArray *)whereArr;
- (NSMutableArray *)queryTable:(NSString *)tableName columns:(NSArray *)columnArr whereArr:(NSArray *)whereArr callback:(void(^)(NSError *error))block;
- (NSMutableArray *)queryAll:(NSString *)tableName callback:(void(^)(NSError *error))block;
@end
