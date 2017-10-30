//
//  HXDBManager.h
//  XiaoYa
//
//  Created by commet on 2017/9/25.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SQL_TEXT     @"TEXT" //文本
#define SQL_INTEGER  @"INTEGER" //int long integer ...
#define SQL_REAL     @"REAL" //浮点
#define SQL_BLOB     @"BLOB" //data
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
+ (instancetype)shareDB;
+ (instancetype)shareDB:(NSString *)dbName;
+ (instancetype)shareDB:(NSString *)dbName dbPath:(NSString *)dbpath;

- (FMDatabaseQueue *)dbQueue;
- (void)changeFilePath:(NSString *)path dbName:(NSString *)dbName;
- (BOOL)tableCreate:(NSString *)sql table:(NSString *)tableName;
- (BOOL)createTable:(NSString *)tableName colDict:(NSDictionary *)dict primaryKey:(NSString *)pk;
- (BOOL)createTable:(NSString *)tableName modelClass:(Class)cls primaryKey:(NSString *)pk excludeProperty:(NSArray *)colArr;
- (void)dropTable:(NSString *)tableName callback:(void(^)(NSError *error ))block;


/**
 插入单个模型

 @param tableName 表名
 @param model 模型对象
 @param colArr 模型中不需要插入到表的属性名集合
 @param block 回调
 */
- (void)insertTable:(NSString *)tableName model:(id)model excludeProperty:(NSArray *)colArr callback:(void(^)(NSError *error ))block;

/**
 批量插入模型

 @param tableName 表名
 @param modelArr 模型对象数组
 @param colArr 一一对应模型对象数组中的每一元素，模型对象中不需要插入到表的属性名集合
 @param block 回调
 */
- (void)insertTableInTransaction:(NSString *)tableName modelArr:(NSArray <id>*)modelArr excludeProperty:(NSArray <NSArray *>*)colArr callback:(void(^)(NSError *error ))block;

/**
 插入单条记录

 @param tableName 表名
 @param paraDict 待插入数据。字典key：字段名，value：字段值
 @param block 回调
 */
- (void)insertTable:(NSString *)tableName param:(NSDictionary *)paraDict callback:(void(^)(NSError *error ))block;

/**
 批量插入记录

 @param tableName 表名
 @param paraArr 待插入数据数组。数组每个元素是字典，字典构成同上。
 @param block 回调
 */
- (void)insertTableInTransaction:(NSString *)tableName paramArr:(NSArray <NSDictionary *>*)paraArr callback:(void(^)(NSError *error))block;


/**
 更新单个记录

 @param tableName 表名
 @param paraDict 待更新数据。字典key：字段名，value：字段值
 @param where where子句字典。key:where子句遵循绑定语法，value：绑定值数组。比如“where name = 'John' AND age = '17'” -> @{@"WHERE name = ? AND age = ?":@[@"John",@"17"]}。要保证where字典有且仅有一个key-value
 @param block 回调
 */
- (void)updateTable:(NSString *)tableName param:(NSDictionary *)paraDict whereDict:(NSDictionary *)where callback:(void(^)(NSError *error ))block;

/**
 批量更新记录

 @param tableName 表名
 @param paraArr 待更新数据集合。数组每个元素是字典，字典构成同上
 @param whereArr where子句字典的集合
 @param block 回调
 */
- (void)updateTableInTransaction:(NSString *)tableName paramArr:(NSArray <NSDictionary *>*)paraArr whereArrs:(NSArray <NSDictionary *>*)whereArr callback:(void(^)(NSError *error))block;

/**
 更新单个模型

 @param tableName 表名
 @param model 模型对象
 @param colArr 模型中不需要更新的属性名集合
 @param where where子句字典
 @param block 回调
 */
- (void)updateTable:(NSString *)tableName model:(id)model excludeProperty:(NSArray *)colArr whereDict:(NSDictionary *)where callback:(void(^)(NSError *error ))block;

/**
 批量更新模型

 @param tableName 表名
 @param modelArr 模型对象集合
 @param colArr 一一对应模型对象数组中的每一元素，模型对象中不需要更新的属性名集合
 @param whereArr where子句字典的集合
 @param block 回调
 */
- (void)updateTableInTransaction:(NSString *)tableName modelArr:(NSArray <id>*)modelArr excludeProperty:(NSArray <NSArray *>*)colArr whereArrs:(NSArray<NSDictionary *> *)whereArr callback:(void (^)(NSError *))block;


/**
 删除单条记录

 @param tableName 表名
 @param where where子句字典
 @param block 回调
 */
- (void)deleteTable:(NSString *)tableName whereDict:(NSDictionary *)where callback:(void(^)(NSError *error))block;

/**
 批量删除记录

 @param tableName 表名
 @param whereArrs where子句字典的集合
 @param block 回调
 */
- (void)deleteTableInTransaction:(NSString *)tableName whereArrs:(NSArray <NSDictionary *>*)whereArrs callback:(void(^)(NSError *error))block;


/**
 直接传入sql语句进行增删查改

 @param sql SQL语句
 @param type 暂时没用
 @param block 回调
 */
- (void)updateWithSqlStat:(NSString *)sql actionTypr:(HXDBActionType)type callback:(void(^)(NSError *error ))block;
- (void)updateWithSqlStatInTransaction:(NSArray <NSString *> *)sqlArr actionTypr:(HXDBActionType)type callback:(void(^)(NSError *error))block;


/**
 根据条件查询有多少条记录

 @param tableName 表名
 @param where where子句字典
 @return 记录数目
 */
- (int)itemCountForTable:(NSString *)tableName whereDict:(NSDictionary *)where;

/**
 根据条件查询模型

 @param tableName 表名
 @param cls 模型类
 @param colArr 模型中不需要被查询的属性名集合
 @param where where子句字典
 @param block 回调
 @return 查询结果
 */
- (NSMutableArray *)queryTable:(NSString *)tableName modelClass:(Class)cls excludeProperty:(NSArray *)colArr whereDict:(NSDictionary *)where callback:(void(^)(NSError *error))block;

/**
 根据条件查询

 @param tableName 表名
 @param columnDict 查询字段。字典：key 字段名，value 字段对应的sql数据类型
 @param where where子句字典
 @param block 回调
 @return 查询结果
 */
- (NSMutableArray *)queryTable:(NSString *)tableName columns:(NSDictionary *)columnDict whereDict:(NSDictionary *)where callback:(void(^)(NSError *error))block;

/**
 查询整表

 @param tableName 表名
 @param block 回调
 @return 查询结果
 */
- (NSMutableArray *)queryAll:(NSString *)tableName callback:(void(^)(NSError *error))block;
@end
