//
//  HXDBManager.m
//  XiaoYa
//
//  Created by commet on 2017/9/25.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "HXDBManager.h"
#import "FMDB.h"

@interface HXDBManager ()<NSCopying,NSMutableCopying>
@property (nonatomic ,strong) FMDatabaseQueue *dbQueue;
@property (nonatomic ,strong) NSString *dbPath;
@end

@implementation HXDBManager
{
    dispatch_queue_t _queue;
}

static HXDBManager *sharedManager=nil;
+ (HXDBManager *)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[HXDBManager alloc]init];
    });
    return sharedManager;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [HXDBManager shareInstance] ;
}

- (id)copyWithZone:(NSZone *)zone{
    return [HXDBManager shareInstance] ;//return _instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    return [HXDBManager shareInstance] ;
}

- (instancetype)init{
    if (self = [super init]) {
        NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
        NSString *filePath = [directory stringByAppendingPathComponent:@"XiaoYaDB"];//这里应该根据用户信息md5建一个路径
        
        NSFileManager *fmManager = [NSFileManager defaultManager];
        BOOL isDir;
        BOOL exit = [fmManager fileExistsAtPath:filePath isDirectory:&isDir];//指示一个文件或者一个路径是否存在于特定的路径之下
        if (!exit || !isDir) {
            [fmManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        self.dbPath = [filePath stringByAppendingPathComponent:@"XiaoYa.sqlite"];
        
        self.dbQueue  = [FMDatabaseQueue databaseQueueWithPath:self.dbPath];
        __weak typeof(self) ws = self;
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            __strong typeof(self) ss = ws;
            [ss update:@"PRAGMA foreign_keys=ON;" actionTypr:HXDBELSE callback:^(BOOL ret, NSError *error, NSString *data) {
                if (!ret) {
                    NSLog(@"外键开启失败");
                }
            }];
        }];
        _queue = dispatch_queue_create("DataBaseConcurrent", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

//表是否存在
- (BOOL)isExistTable:(FMDatabase *)db table:(NSString *)tableName{
    return [db tableExists:tableName];
}

//创建表
- (BOOL)tableCreate:(NSString *)sql table:(NSString *)tableName{
    if (sql.length == 0) {
        return NO;
    }
    
    __block BOOL result;
    __weak typeof(self) ws = self;
    dispatch_async(_queue, ^{//异步并行
        __strong typeof(ws) ss = ws;
        [ss.dbQueue inDatabase:^(FMDatabase *db) {
            if ([db open]){//检查数据库是否打开
                if ([ss isExistTable:db table:tableName]){//检查表是否已经存在
                    result = YES;
                } else{
                    result = [db executeUpdate:sql];//创建表
                }
            } else{
                result = NO;
            }
            [db close];
        }];
    });
//    __block BOOL result;
//    [self.dbQueue inDatabase:^(FMDatabase *db) {
//        if (![db tableExists:tableName]){
//            return;
//        }
//        
//        result = [db executeUpdate:sql];
//    }];
    if (result) {
        NSLog(@"创建表成功");
        return YES;
    } else{
        NSLog(@"创建表失败");
        return NO;
    }
}

- (void)update:(NSString *)sql actionTypr:(HXDBActionType)type callback:(void(^)(BOOL ret ,NSError *error ,NSString *data))block{
    if (sql.length == 0 || !sql) {
        block(NO ,nil ,@"sql为空");
        return;
    }

    __weak typeof(self) ws = self;
    dispatch_async(_queue, ^{
        __strong typeof(ws) ss = ws;
        [ss.dbQueue inDatabase:^(FMDatabase *db) {
            if ([db open]) {
                BOOL result = [db executeUpdate:sql];
                if (!result) {
                    if (type == HXDBINSERT) {
                        block(result ,nil ,@"添加数据失败");
                    } else if (type == HXDBDELETE){
                        block(result ,nil ,@"删除数据失败");
                    } else if (type == HXDBUPDATE){
                        block(result ,nil ,@"更新数据失败");
                    } else {
                        block(result ,nil ,@"操作失败");
                    }
                }
                if ([db hadError]) {
                    block(NO,[db lastError],[db lastErrorMessage]);
                    NSLog(@"executeSQL error %d:  %@",[db lastErrorCode],[db lastErrorMessage]);
                }else{
                    block(result,nil,@"操作成功");
                }
            }
            [db close];
        }];
    });
    
}

- (void)updateInTransaction:(NSArray <NSString *> *)sqlArr actionTypr:(HXDBActionType)type callback:(void(^)(BOOL ret ,NSError *error ,NSString *data))block{
    if (sqlArr.count == 0 || !sqlArr) {
        block(NO ,nil ,@"sql为空");
        return;
    }

    __weak typeof(self) ws = self;
    dispatch_async(_queue, ^{
        __strong typeof(ws) ss = ws;
        [ss.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            if ([db open]) {
                [sqlArr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    BOOL result = [db executeUpdate:obj];
                    if (!result) {
                        if (type == HXDBINSERT) {
                            block(result ,nil ,@"添加数据失败");
                        } else if (type == HXDBDELETE){
                            block(result ,nil ,@"删除数据失败");
                        } else if (type == HXDBUPDATE){
                            block(result ,nil ,@"更新数据失败");
                        } else {
                            block(result ,nil ,@"操作失败");
                        }
                        *rollback = YES;
                        *stop = YES;
                        return;
                    }
                    if ([db hadError]) {
                        block(NO,[db lastError],[db lastErrorMessage]);
                        NSLog(@"executeSQL error %d:  %@",[db lastErrorCode],[db lastErrorMessage]);
                        *stop = YES;
                        return;
                    }
                    if (idx == sqlArr.count - 1) {
                        block(YES,nil,@"操作成功");
                    }
                }];
            }
            [db close];
        }];
    });
}

- (void)query:(NSString *)sql callback:(void(^)(BOOL ret ,NSError *error ,NSString *data))block{
    if (sql.length == 0 || !sql) {
        block(NO ,nil ,@"sql为空");
        return;
    }
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            
        }
    }];
}

- (void)queryInTransaction{
    
}

- (void)queryAll:(NSString *)tableName{
    if (tableName.length == 0 || !tableName) {
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            NSString *sql = [NSString stringWithFormat:@"SELETE * FROM %@",tableName];
            FMResultSet *rs = [db executeQuery:sql];
            while ([rs next]) {
                
            }
        }];
    }
}

//清空表
- (void)cleraTable:(NSString *)tableName{
    if (tableName.length == 0 || !tableName) {
        __weak typeof(self) ws = self;
        dispatch_async(_queue, ^{
            __strong typeof(ws) ss = ws;
            [ss.dbQueue inDatabase:^(FMDatabase *db) {
                if ([db open]) {
                    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
                    BOOL result = [db executeUpdate:sql];
                    if (!result) {
                        NSLog(@"清空表失败");
                    }
                }
                [db close];
            }];
        });
    }
}
@end
