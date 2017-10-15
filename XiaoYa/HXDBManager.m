//
//  HXDBManager.m
//  XiaoYa
//
//  Created by commet on 2017/9/25.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "HXDBManager.h"
#import "FMDB.h"
#import <CommonCrypto/CommonCrypto.h>
#import "AppDelegate.h"

#define kMaxPageCount 50

static NSString *_HXNSStringMD5(NSString *string) {
    if (!string) return nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0],  result[1],  result[2],  result[3],
            result[4],  result[5],  result[6],  result[7],
            result[8],  result[9],  result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@interface HXDBManager ()<NSCopying,NSMutableCopying>
@property (nonatomic ,strong) FMDatabaseQueue *dbQueue;
@property (nonatomic ,strong) NSString *dbPath;
@property (nonatomic ,strong) dispatch_queue_t queue;
@end

@implementation HXDBManager
static NSString *HXDBErrorDomain = @"com.comment.hxdbdomain";
static HXDBManager *sharedManager=nil;
+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[super allocWithZone:NULL] init];
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
        AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *path = _HXNSStringMD5(apd.userid);
        [self changeFilePath:path];
    }
    return self;
}

//切换用户就要切换数据库
- (void)changeFilePath:(NSString *)path{
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSString *filePath = [directory stringByAppendingPathComponent:path];//这里应该根据用户信息md5建一个路径
    
    NSFileManager *fmManager = [NSFileManager defaultManager];
    BOOL isDir;
    BOOL exit = [fmManager fileExistsAtPath:filePath isDirectory:&isDir];//指示一个文件或者一个路径是否存在于特定的路径之下
    if (!exit || !isDir) {
        [fmManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    self.dbPath = [filePath stringByAppendingPathComponent:@"XiaoYa.sqlite"];
    NSLog(@"dataBasePath:%@",filePath);
    
    self.dbQueue  = [FMDatabaseQueue databaseQueueWithPath:self.dbPath];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:@"PRAGMA foreign_keys=ON;"];
        [db setShouldCacheStatements:YES];//开启缓存
        if (!result) {
            NSLog(@"外键开启失败");
        }
    }];
}

//拼接"?,?,?,?..."格式字符串
- (NSString *)appendKeys:(NSInteger)count {
    NSMutableString *string = [NSMutableString new];
    for (int i = 0; i < count; i++) {
        [string appendString:@"?"];
        if (i + 1 != count) {
            [string appendString:@","];
        }
    }
    return string;
}

//根据where数组组合where条件语句。
//where数组每三项的放置组合：字段、条件、字段值
- (NSDictionary *)combineWhereStat:(NSArray *)whereArr{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableString *whereSQL = [NSMutableString string];
    if (!(whereArr.count % 3)){
        [whereSQL appendString:@" where "];
        for(int i = 0 ; i < whereArr.count ; i += 3){
            [whereSQL appendFormat:@"%@ %@ ?",whereArr[i],whereArr[i+1]];
            if (i != (whereArr.count - 3)) {
                [whereSQL appendString:@" and "];
            }
        }
        NSMutableArray *values = [NSMutableArray array];
        for(int i = 0; i < whereArr.count; i += 3){
            [values addObject:whereArr[i + 2]];
        }
        [dict setObject:values forKey:whereSQL];
    } else{
        NSLog(@"where条件数组错误!");
    }
    return dict;
}

//表是否存在
- (BOOL)isExistTable:(FMDatabase *)db table:(NSString *)tableName{
    return [db tableExists:tableName];
}

//根据sql语句创建表
- (BOOL)tableCreate:(NSString *)sql table:(NSString *)tableName{
    if (sql.length == 0) {
        NSLog(@"sql语句不能为空，创建表失败");
        return NO;
    }
    
    __block BOOL result = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        if ([db open]){//检查数据库是否打开
            if ([self isExistTable:db table:tableName]){//检查表是否已经存在
                result = YES;
            } else{
                result = [db executeUpdate:sql];//创建表
            }
        } else{
            result = NO;
        }
        if (!result) {
            NSLog(@"%@",[db lastError]);
        }
//        [db close];//会清除缓存prepared
    }];
    NSLog(@"%@", result ? [NSString stringWithFormat:@"创建表 %@成功",tableName] : [NSString stringWithFormat:@"创建表 %@失败",tableName]);
    return result;
}

//根据传入的参数拼接创建表sql语句，只支持设置字段名、字段类型、主键。dict：key 字段名、value 字段类型；isPK：是否设置主键，如果为NO，忽略pkIndex参数；pkIndex：主键索引。
- (BOOL)createTable:(NSString *)tableName colDict:(NSDictionary *)dict isPrimaryKey:(BOOL)isPK primaryKeyIndex:(NSInteger )pkIndex{
    NSAssert((dict != nil)&&(dict.count > 0) , @"创建表：dict 参数无效");
    NSAssert(pkIndex < dict.count, @"创建表：主键index无效");
    if (tableName == nil ||(dict == nil) || (dict.count == 0) || pkIndex > dict.count) {
        return NO;
    }
    __block BOOL result = NO;
    NSMutableString *sqlStr = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (",tableName];
    NSArray *keysArr = [dict allKeys];
    [keysArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == dict.count - 1) {
            [sqlStr appendFormat:@"%@ %@)",obj,dict[obj]];
        }else{
            [sqlStr appendFormat:@"%@ %@,",obj,dict[obj]];
        }
        if (isPK && (idx == pkIndex)) {
            [sqlStr insertString:@" PRIMARY KEY" atIndex:sqlStr.length-1];
        }
    }];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            result = [db executeUpdate:sqlStr];
        }
    }];
    NSLog(@"%@", result ? [NSString stringWithFormat:@"创建表 %@成功",tableName] : [NSString stringWithFormat:@"创建表 %@失败",tableName]);
    return result;
}


- (void)dropTable:(NSString *)tableName callback:(void(^)(NSError *error ))block{
    if (tableName == nil) {
        if (block) {
            NSError *error = [self errorWithErrorCode:2000];
            block(error);
        }
        return;
    }
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sqlstr = [NSString stringWithFormat:@"DROP TABLE %@", tableName];
        BOOL result = [db executeUpdate:sqlstr];
        if (!result) {
            if (block) {
                block([db lastError]);
            }
        }
    }];
}

#pragma mark 插入
//插入单条数据。paraDict：key 字段名、value 字段值；block：回调。有回调就不需要返回BOOL值（表示是否插入成功）
- (void)insertTable:(NSString *)tableName param:(NSDictionary *)paraDict callback:(void(^)(NSError *error ))block{
    if (tableName == nil || paraDict == nil || paraDict.count == 0) {
        if (block) {
            NSError *error = [self errorWithErrorCode:2000];
            block(error);
        }
        return;
    }
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        if (![self isExistTable:db table:tableName]) {
            if (block) {
                NSError *error = [self errorWithErrorCode:2001];
                block(error);
            }
            return;
        }
        if ([db open]){
            NSMutableArray *columns = [NSMutableArray arrayWithCapacity:0];//table中的字段名
            FMResultSet *resultSet = [db getTableSchema:tableName];
            while([resultSet next]){
                [columns addObject:[resultSet stringForColumn:@"name"]];//获得table中的字段名
            }
            [resultSet close];
            NSMutableString *sqlStr = [NSMutableString stringWithFormat:@"INSERT INTO %@ (",tableName];
            NSArray *keys = [paraDict allKeys];
            NSMutableArray *values = [NSMutableArray arrayWithCapacity:0];
            [keys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([columns containsObject:obj]) {
                    if (idx == paraDict.count - 1) {
                        [sqlStr appendFormat:@"%@ )",obj];
                    } else{
                        [sqlStr appendFormat:@"%@ ,",obj];
                    }
                    [values addObject:paraDict[obj]];
                }
            }];
            [sqlStr appendFormat:@" VALUES (%@)",[self appendKeys:values.count]];
            BOOL result = [db executeUpdate:sqlStr withArgumentsInArray:values];
            if (!result) {
                if (block) {
                    block([db lastError]);
                }
            }
            NSLog(result ? @"插入成功" : @"插入失败");
        }
//        [db close];
    }];
}

- (void)insertTableInTransaction:(NSString *)tableName paramArr:(NSArray <NSDictionary *>*)paraArr callback:(void(^)(NSError *error))block{
    if (tableName == nil || paraArr == nil || paraArr.count == 0){
        if (block) {
            NSError *error = [self errorWithErrorCode:2000];
            block(error);
        }
        return;
    }
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if (![self isExistTable:db table:tableName]) {
            if (block) {
                NSError *error = [self errorWithErrorCode:2001];
                block(error);
            }
            return;
        }
        if ([db open]) {
            [db setShouldCacheStatements:YES];//开启缓存
            NSMutableArray *columns = [NSMutableArray arrayWithCapacity:0];//table中的字段名
            FMResultSet *resultSet = [db getTableSchema:tableName];
            while([resultSet next]){
                [columns addObject:[resultSet stringForColumn:@"name"]];//获得table中的字段名
            }
            [resultSet close];
            [paraArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull paraDict, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableString *sqlStr = [NSMutableString stringWithFormat:@"INSERT INTO %@ (",tableName];
                NSArray *keys = [paraDict allKeys];
                NSMutableArray *values = [NSMutableArray arrayWithCapacity:0];
                [keys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([columns containsObject:obj]) {
                        if (idx == paraDict.count - 1) {
                            [sqlStr appendFormat:@"%@ )",obj];
                        } else{
                            [sqlStr appendFormat:@"%@ ,",obj];
                        }
                        [values addObject:paraDict[obj]];
                    }
                }];
                [sqlStr appendFormat:@" VALUES (%@)",[self appendKeys:values.count]];
                BOOL result = [db executeUpdate:sqlStr withArgumentsInArray:values];
                if (!result) {
                    if (block) {
                        block([db lastError]);
                    }
                    *rollback = YES;
                    *stop = YES;
                    return;
                }
            }];
        }
//        [db close];
    }];
}

#pragma mark 更新
//paraDict：key 字段名、value 字段值；where数组每三项的放置组合：字段、条件、字段值,如果where数组传空，就更新整个表
- (void)updateTable:(NSString *)tableName param:(NSDictionary *)paraDict whereArr:(NSArray *)whereArr callback:(void(^)(NSError *error ))block{
    if (tableName == nil || paraDict == nil || paraDict.count == 0){
        if (block) {
            NSError *error = [self errorWithErrorCode:2000];
            block(error);
        }
        return;
    }
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        if (![self isExistTable:db table:tableName]) {
            if (block) {
                NSError *error = [self errorWithErrorCode:2001];
                block(error);
            }
            return;
        }
        if ([db open]) {
            NSMutableArray *columns = [NSMutableArray arrayWithCapacity:0];//table中的字段名
            FMResultSet *resultSet = [db getTableSchema:tableName];
            while([resultSet next]){
                [columns addObject:[resultSet stringForColumn:@"name"]];//获得table中的字段名
            }
            [resultSet close];
            NSMutableString *sqlStr = [NSMutableString stringWithFormat:@"UPDATE %@ SET ",tableName];
            NSArray *keys = [paraDict allKeys];
            NSMutableArray *values = [NSMutableArray arrayWithCapacity:0];
            [keys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([columns containsObject:obj]) {
                    [sqlStr appendFormat:@"%@ = ?,",obj];
                    [values addObject:paraDict[obj]];
                }
            }];
            [sqlStr deleteCharactersInRange:NSMakeRange(sqlStr.length - 1, 1)];
            if (whereArr.count > 0) {
                NSDictionary *whereDict = [self combineWhereStat:whereArr];
                if (whereDict.count > 0) {
                    NSArray *whereSqls = [whereDict allKeys];
                    [sqlStr appendFormat:@" %@",whereSqls[0]];
                    [values addObjectsFromArray:[whereDict objectForKey:whereSqls[0]]];
                }
            }
            
            BOOL result = [db executeUpdate:sqlStr withArgumentsInArray:values];
            if (!result) {
                if (block) {
                    block([db lastError]);
                }
            }
        }
//        [db close];
    }];
}

- (void)updateTableInTransaction:(NSString *)tableName paramArr:(NSArray <NSDictionary *>*)paraArr whereArrs:(NSArray <NSArray *>*)whereArr callback:(void(^)(NSError *error))block{
    if (tableName == nil || paraArr == nil || paraArr.count == 0 || paraArr.count != whereArr.count){
        if (block) {
            NSError *error = [self errorWithErrorCode:2000];
            block(error);
        }
        return;
    }
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if (![self isExistTable:db table:tableName]) {
            if (block) {
                NSError *error = [self errorWithErrorCode:2001];
                block(error);
            }
            return;
        }
        if ([db open]) {
            NSMutableArray *columns = [NSMutableArray arrayWithCapacity:0];//table中的字段名
            FMResultSet *resultSet = [db getTableSchema:tableName];
            while([resultSet next]){
                [columns addObject:[resultSet stringForColumn:@"name"]];//获得table中的字段名
            }
            [resultSet close];
            [paraArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull paraDict, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableString *sqlStr = [NSMutableString stringWithFormat:@"UPDATE %@ SET ",tableName];
                NSArray *keys = [paraDict allKeys];
                NSMutableArray *values = [NSMutableArray arrayWithCapacity:0];
                [keys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([columns containsObject:obj]) {
                        [sqlStr appendFormat:@"%@ = ?,",obj];
                        [values addObject:paraDict[obj]];
                    }
                }];
                [sqlStr deleteCharactersInRange:NSMakeRange(sqlStr.length - 1, 1)];
                
                if (whereArr[idx].count > 0) {
                    NSDictionary *whereDict = [self combineWhereStat:whereArr[idx]];
                    if (whereDict.count > 0) {
                        NSArray *whereSqls = [whereDict allKeys];
                        [sqlStr appendFormat:@" %@",whereSqls[0]];
                        [values addObjectsFromArray:[whereDict objectForKey:whereSqls[0]]];
                        //存在where子句才执行更新。由于这个方法是对同一个表进行批量更新，如果有其中一个事务没有where子句（更新整表），那么批量更新就没意义了
                        BOOL result = [db executeUpdate:sqlStr withArgumentsInArray:values];
                        if (!result) {
                            if (block) {
                                block([db lastError]);
                            }
                            *rollback = YES;
                            *stop = YES;
                            return;
                        }
                    }
                    else {//没有where子句
                        if (block) {
                            NSError *error = [self errorWithErrorCode:2002];
                            block(error);
                        }
                        *rollback = YES;
                        *stop = YES;
                        return;
                    }
                }
            }];
        }
//        [db close];
    }];
}

#pragma mark 删除
//如果where为空，就删除整表记录
- (void)deleteTable:(NSString *)tableName whereArr:(NSArray *)whereArr callback:(void(^)(NSError *error))block{
    if (tableName == nil) {
        if (block) {
            NSError *error = [self errorWithErrorCode:2000];
            block(error);
        }
        return;
    }
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        if (![self isExistTable:db table:tableName]) {
            if (block) {
                NSError *error = [self errorWithErrorCode:2001];
                block(error);
            }
            return;
        }
        if ([db open]) {
            NSMutableString *sqlStr = [NSMutableString stringWithFormat:@"DELETE FROM %@ ",tableName];
            NSMutableArray *values = [NSMutableArray arrayWithCapacity:0];
            if (whereArr.count > 0) {
                NSDictionary *whereDict = [self combineWhereStat:whereArr];
                if (whereDict.count > 0) {
                    NSArray *whereSqls = [whereDict allKeys];
                    [sqlStr appendFormat:@"%@",whereSqls[0]];
                    [values addObjectsFromArray:[whereDict objectForKey:whereSqls[0]]];
                }
            }
            BOOL result = [db executeUpdate:sqlStr withArgumentsInArray:values];
            if (!result) {
                if (block) {
                    block([db lastError]);
                }
            }
        }
    }];
}

- (void)deleteTableInTransaction:(NSString *)tableName whereArrs:(NSArray <NSArray *>*)whereArrs callback:(void(^)(NSError *error))block{
    if (tableName == nil){
        if (block) {
            NSError *error = [self errorWithErrorCode:2000];
            block(error);
        }
        return;
    }
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if (![self isExistTable:db table:tableName]) {
            if (block) {
                NSError *error = [self errorWithErrorCode:2001];
                block(error);
            }
            return;
        }
        if ([db open]) {
            [whereArrs enumerateObjectsUsingBlock:^(NSArray * _Nonnull whereArr, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableString *sqlStr = [NSMutableString stringWithFormat:@"DELETE FROM %@ ",tableName];
                NSMutableArray *values = [NSMutableArray arrayWithCapacity:0];
                if (whereArr.count > 0) {
                    NSDictionary *whereDict = [self combineWhereStat:whereArr];
                    if (whereDict.count > 0) {
                        NSArray *whereSqls = [whereDict allKeys];
                        [sqlStr appendFormat:@" %@",whereSqls[0]];
                        [values addObjectsFromArray:[whereDict objectForKey:whereSqls[0]]];
                    }
                }
                BOOL result = [db executeUpdate:sqlStr withArgumentsInArray:values];
                if (!result) {
                    if (block) {
                        block([db lastError]);
                    }
                    *rollback = YES;
                    *stop = YES;
                    return;
                }
            }];
        }
    }];
}

#pragma mark 直接传入sql语句进行增删改
//如果是绑定语法的需要传入para
- (void)updateWithSqlStat:(NSString *)sql actionTypr:(HXDBActionType)type callback:(void(^)(NSError *error ))block{
    if (sql.length == 0 || !sql) {
        if (block) {
            NSError *error = [self errorWithErrorCode:2000];
            block(error);
        }
        return;
    }

    [self.dbQueue inDatabase:^(FMDatabase *db) {
        if ([db open]) {
            BOOL result = [db executeUpdate:sql];
            if (!result) {
                if (block) {
                    block([db lastError]);
                }
            }
        }
//        [db close];
    }];
}

- (void)updateWithSqlStatInTransaction:(NSArray <NSString *> *)sqlArr actionTypr:(HXDBActionType)type callback:(void(^)(NSError *error))block{
    if (sqlArr.count == 0 || !sqlArr) {
        if (block) {
            NSError *error = [self errorWithErrorCode:2000];
            block(error);
        }
        return;
    }

    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if ([db open]) {
            [sqlArr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                BOOL result = [db executeUpdate:obj];
                if (!result) {
                    if (block) {
                        block([db lastError]);
                    }
                    *rollback = YES;
                    *stop = YES;
                    return;
                }
            }];
        }
//        [db close];
    }];
}

#pragma mark 查询
//根据条件查询有多少条数据
- (int)itemCountForTable:(NSString *)tableName whereArr:(NSArray *)whereArr{
    NSMutableString *sqlStr = [NSMutableString stringWithFormat:@"SELECT count(*) from %@",tableName];
    NSMutableArray *values = [NSMutableArray array];
    if (whereArr.count > 0) {
        NSDictionary *whereDict = [self combineWhereStat:whereArr];
        if (whereDict.count > 0) {
            NSArray *whereSqls = [whereDict allKeys];
            [sqlStr appendFormat:@" %@",whereSqls[0]];
            [values addObjectsFromArray:[whereDict objectForKey:whereSqls[0]]];
        }
    }
    __block int count = 0;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs;
        if (values.count == 0) {
            rs = [db executeQuery:sqlStr];
        } else{
            rs = [db executeQuery:sqlStr withArgumentsInArray:values];
        }
        while ([rs next]) {
            count = [rs intForColumnIndex:0];
        }
        [rs close];
    }];
    return count;
}

//查询单条
- (NSMutableArray *)queryTable:(NSString *)tableName columns:(NSArray *)columnArr whereArr:(NSArray *)whereArr callback:(void(^)(NSError *error))block{
    if (tableName == nil){
        if (block) {
            NSError *error = [self errorWithErrorCode:2000];
            block(error);
        }
        return nil;
    }
    NSMutableArray *dataArr = [NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        if (![self isExistTable:db table:tableName]) {
            if (block) {
                NSError *error = [self errorWithErrorCode:2001];
                block(error);
            }
            return;
        }
        if ([db open]) {
            NSMutableArray *columns = [NSMutableArray arrayWithCapacity:0];//table中的字段名
            FMResultSet *resultSet = [db getTableSchema:tableName];
            while([resultSet next]){
                [columns addObject:[resultSet stringForColumn:@"name"]];//获得table中的字段名
            }
            [resultSet close];
            NSMutableString *sqlStr = [NSMutableString stringWithString:@"SELECT "];
            if (columnArr == nil || columnArr.count == 0) {
                [sqlStr appendString:@"* "];
            }else{
                [columnArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([columns containsObject:obj]) {
                        [sqlStr appendFormat:@"%@ ,",obj];
                    }
                }];
                [sqlStr deleteCharactersInRange:NSMakeRange(sqlStr.length - 1, 1)];
            }
            [sqlStr appendFormat:@"FROM %@",tableName];
            
            NSMutableArray *values = [NSMutableArray array];
            if (whereArr.count > 0) {
                NSDictionary *whereDict = [self combineWhereStat:whereArr];
                if (whereDict.count > 0) {
                    NSArray *whereSqls = [whereDict allKeys];
                    [sqlStr appendFormat:@"%@",whereSqls[0]];
                    [values addObjectsFromArray:[whereDict objectForKey:whereSqls[0]]];
                }
            }
            
            //分页
//            NSInteger itemCount = [self itemCountForTable:tableName whereArr:whereArr];
//            for (int i = 0; i < itemCount; i += kMaxPageCount) {
//                @autoreleasepool {
//                    NSString *limit = [NSString stringWithFormat:@" LIMIT %@,%@",@(i),@(kMaxPageCount)];
//                    [sqlStr appendString:limit];
                    FMResultSet *rs = [db executeQuery:sqlStr withArgumentsInArray:values];
                    if (rs == nil) {
                        if (block) {
                            NSError *error = [self errorWithErrorCode:2003];
                            block(error);
                        }
                    }
                    while ([rs next]) {
                        int count = [rs columnCount];
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        for (int i = 0 ; i < count ; i++) {
                            NSString *key = [rs columnNameForIndex:i];
                            NSString *value = [rs stringForColumnIndex:i];
                            [dic setValue:value forKey:key];
                        }
                        [dataArr addObject:dic];
                    }
                    [rs close];
//                }
//            }
        }
    }];
    return dataArr;
}

//查询整表
- (NSMutableArray *)queryAll:(NSString *)tableName callback:(void(^)(NSError *error))block{
    if (tableName == nil){
        if (block) {
            NSError *error = [self errorWithErrorCode:2000];
            block(error);
        }
        return nil;
    }

    NSMutableArray *dataArr = [NSMutableArray array];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            int count = [rs columnCount];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            for (int i = 0 ; i < count ; i++) {
                NSString *key = [rs columnNameForIndex:i];
                NSString *value = [rs stringForColumnIndex:i];
                [dic setValue:value forKey:key];
            }
            [dataArr addObject:dic];
        }
        if (rs == nil) {
            if (block) {
                NSError *error = [self errorWithErrorCode:2003];
                block(error);
            }
        }
        [rs close];
    }];
    return dataArr;
}

- (dispatch_queue_t)queue{
    if (_queue == nil) {
        _queue = dispatch_queue_create("DataBaseConcurrent", DISPATCH_QUEUE_CONCURRENT);
    }
    return _queue;
}

- (FMDatabaseQueue *)dbQueue{
    return _dbQueue;
}

- (NSError *)errorWithErrorCode:(NSInteger)errorCode {
    NSString *errorMessage;
    
    switch (errorCode) {
        case 2000:
            errorMessage = @"传入参数有误";
            break;
        case 2001:
            errorMessage = @"该表不存在";
            break;
        case 2002:
            errorMessage = @"更新数据-警告：没有where子句";
            break;
        case 2003:
            errorMessage = @"查询错误";
            break;
        default:
            errorMessage = @"hxdb 不可描述的出出错";
            break;
    }
    return [NSError errorWithDomain:HXDBErrorDomain
                               code:errorCode
                           userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
}

@end
