//
//  TSMessageModel.m
//  BossCockpit
//
//  Created by qyb on 2017/8/2.
//  Copyright © 2017年 qyb. All rights reserved.
//
#import "NSDate+DateTools.h"
#import "FMDB.h"
#import "TSMessageModel.h"

NSString *const kTSSchoolNewsTable = @"news";
NSString *const kTSLiveNewsTable = @"live";
NSString *const kTSTeacherSignNewsTable = @"teacher_sign_time";

NSString *const sMMddHHmmDateFormat = @"yyyy-MM-dd HH:mm";

@implementation TSMessageModel
+ (void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self initial_db];
    });
}
#pragma mark - public
+ (void)selectMessageForLimit:(NSRange)range completedBlock:(void(^)(NSArray <TSMessageModel *>*))completedBlock{
    [self selectForLimit:range completedBlock:completedBlock];
}
+ (void)allMessagesWithCompletedBlock:(void(^)(NSArray <TSMessageModel *>*))completedBlock{
    [self selectForLimit:(NSRange){NSNotFound,0} completedBlock:completedBlock];
}
- (void)commitDBWithCompletedBlock:(void(^)(BOOL success))completedBlock{
    [self.class commitIds:self.fromId content:self.content table:self.fromTable receiveDate:self.receiveDate readedDate:self.readDate other:self.otherMessage completedBlock:completedBlock];
    //    [self.class isExistForIds:self.fromId completedBlock:^(BOOL exit) {
    //        if (exit) {
    //            [self updateReadDateWithCompletedBlock:completedBlock];
    //        }else{
    //           [self insertDBWithCompletedBlock:completedBlock];
    //        }
    //    }];
    
}
- (void)updateReadDateWithCompletedBlock:(void(^)(BOOL success))completedBlock{
    [self.class updateReadDate:self.readDate forKey:self.fromId completedBlock:completedBlock];
}
- (void)insertDBWithCompletedBlock:(void(^)(BOOL success))completedBlock{
    [self.class insertIds:self.fromId content:self.content table:self.fromTable receiveDate:self.receiveDate other:self.otherMessage completedBlock:completedBlock];
}
#pragma mark - over write
- (NSString *)fromId{
    return IF_NULL_TO_STRING(_fromId);
}
- (NSString *)fromTable{
    return IF_NULL_TO_STRING(_fromTable);
}
- (NSString *)content{
    return IF_NULL_TO_STRING(_content);
}
//输出 mm-dd HH:mm 时间格式
+ (NSString *)outputFormatWithDate:(NSDate *)date{
    return [date formattedDateWithFormat:sMMddHHmmDateFormat];
}

#pragma mark - db operation

#define tableName [NSString stringWithFormat:@"message_%@",SBUserInfo.userId]

//key
#define fromId_key @"fromId"
#define content_key @"content"
#define fromTable_key @"fromTable"
#define readDate_key @"readDate"
#define otherMessage_key @"otherMessage"
#define receiveDate_key @"receiveDate"

static FMDatabaseQueue *_queue;
NSString *const filePath = @"getuiMessages.db";
NSString *const directoryPath = @"sqliteDirectory";
//初始化
+ (NSString *)_dbPath{
    
    NSString *path = [[self _fileDirectory] stringByAppendingPathComponent:filePath];
    return path;
}
//目录
+ (NSString *)_fileDirectory{
    NSString *file = [NSString stringWithFormat:@"Documents/%@",directoryPath];
    return [NSHomeDirectory() stringByAppendingPathComponent:file];
}
+ (void)initial_db{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[self _fileDirectory]]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:[self _fileDirectory] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    NSString *path = [self _dbPath];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:path];
    _queue = queue;
    [_queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement, %@ varchar(40), %@ text,%@ varchar(40),%@ datetime,%@ datetime,%@ blob)",tableName,fromId_key,content_key,fromTable_key,readDate_key,receiveDate_key,otherMessage_key];
        BOOL createSuccess = [db executeUpdate:sql];
        if (createSuccess) {
            NSLog(@"createSuccess");
        }
    }];
}
+ (void)insertIds:(NSString *)ids content:(NSString *)content table:(NSString *)table receiveDate:(NSDate*)date other:(id)other db:(id)db completedBlock:(void(^)(BOOL success))completedBlock{
    NSData *otherData = other?[NSJSONSerialization dataWithJSONObject:other options:NSJSONWritingPrettyPrinted error:nil]:[NSNull null];
    NSString *sql = [NSString stringWithFormat:@"insert into %@ (%@, %@, %@, %@, %@, %@) values (?, ?, ?, ?, ?, ?)",tableName,fromId_key,content_key,fromTable_key,readDate_key,receiveDate_key,otherMessage_key];
    BOOL insertSuccess = [db executeUpdate:sql,ids,content,table,[NSNull null],date,otherData];
    if (insertSuccess) {
        NSLog(@"insertSuccess");
    }
    if (completedBlock) {
        dispatch_main_async_safe(^{
            completedBlock(insertSuccess);
        });
    }
}
//插入
+ (void)insertIds:(NSString *)ids content:(NSString *)content table:(NSString *)table receiveDate:(NSDate*)date other:(id)other completedBlock:(void(^)(BOOL success))completedBlock{
    __weak typeof(self) weak = self;
    [_queue inDatabase:^(FMDatabase *db) {
        [weak.class insertIds:ids content:content table:table receiveDate:date other:other db:db completedBlock:completedBlock];
    }];
}
+ (void)commitIds:(NSString *)ids content:(NSString *)content table:(NSString *)table receiveDate:(NSDate*)date readedDate:(NSDate *)readDate other:(id)other completedBlock:(void(^)(BOOL success))completedBlock{
    __weak typeof(self) weak = self;
    [_queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *sql = [NSString stringWithFormat:@"select count(*) from %@ where %@ = '%@'",tableName,fromId_key,ids];
        NSUInteger exist = [db intForQuery:sql];
        if (exist) {
            [weak.class updateReadDate:readDate forKey:ids db:db completedBlock:completedBlock];
        }else{
            [weak.class insertIds:ids content:content table:table receiveDate:date other:other db:db completedBlock:completedBlock];
        }
    }];
}



+ (void)schoolUnreadMessageCountWithCompletedBlock:(void(^)(NSInteger count))completedBlock{
    [self unreadMessageForKey:kTSSchoolNewsTable completedBlock:completedBlock];
}
+ (void)teacherShiftListMessageCountWithCompletedBlock:(void(^)(NSInteger count))completedBlock{
    [self unreadMessageForKey:kTSTeacherSignNewsTable completedBlock:completedBlock];
}

+ (void)liveUnreadMessageCountWithCompletedBlock:(void(^)(NSInteger count))completedBlock{
    [self unreadMessageForKey:kTSLiveNewsTable completedBlock:completedBlock];
}

+ (void)unreadMessageForKey:(NSString *)key completedBlock:(void(^)(NSInteger count))completedBlock{
    [_queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select count(*) from %@ where %@ = '%@' and %@ is null",tableName,fromTable_key,key,readDate_key];
        NSUInteger count = [db intForQuery:sql,[NSNull null]];
        if (completedBlock) {
            dispatch_main_async_safe(^{
                completedBlock(count);
            });
        }
    }];
}
+ (void)messageCountWithCompletedBlock:(void(^)(NSInteger count))completedBlock{
    [_queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select count(*) from %@",tableName];
        NSUInteger count = [db intForQuery:sql];
        if (completedBlock) {
            dispatch_main_async_safe(^{
                completedBlock(count);
            });
        }
    }];
}
+ (void)updateReadDate:(NSDate *)date forKey:(NSString *)key db:(id)db completedBlock:(void(^)(BOOL success))completedBlock{
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@ = ? where %@ = ?",tableName,readDate_key,fromId_key];
    BOOL updateSuccess = [db executeUpdate:sql,date,key];
    if (updateSuccess) {
        NSLog(@"updateSuccess");
    }
    if (completedBlock) {
        dispatch_main_async_safe(^{
            completedBlock(updateSuccess);
        });
    }
}
//更新
+ (void)updateReadDate:(NSDate *)date forKey:(NSString *)key completedBlock:(void(^)(BOOL success))completedBlock{
    __weak typeof(self) weak = self;
    [_queue inDatabase:^(FMDatabase *db) {
        [weak.class updateReadDate:date forKey:key db:db completedBlock:completedBlock];
    }];
}
+ (void)isExistForIds:(NSString *)ids db:(id)db completedBlock:(void(^)(BOOL success))completedBlock{
    NSString *sql = [NSString stringWithFormat:@"select count(*) from %@ where %@ = '%@'",tableName,fromId_key,ids];
    NSUInteger count = [db intForQuery:sql];
    if (completedBlock) {
        dispatch_main_async_safe(^{
            completedBlock(count);
        });
    }
}
+ (void)isExistForIds:(NSString *)ids completedBlock:(void(^)(BOOL success))completedBlock{
    __weak typeof(self) weak = self;
    [_queue inDatabase:^(FMDatabase *db) {
        [weak.class isExistForIds:ids db:db completedBlock:completedBlock];
    }];
}
+ (void)updateAllMessageMakeReadedWithCompletedBlock:(void(^)(void))completedBlock{
    [_queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"update %@ set %@ = ?",tableName,readDate_key];
        BOOL updateSuccess = [db executeUpdate:sql,[NSDate date]];
        if (updateSuccess) {
            NSLog(@"updateSuccess");
        }
        if (completedBlock) {
            dispatch_main_async_safe(^{
                completedBlock();
            });
        }
    }];
}
+ (void)unreadMessageCountWithCompletedBlock:(void(^)(NSInteger count))completedBlock{
    [_queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select count(*) from %@ where %@ is null",tableName,readDate_key];
        NSUInteger count = [db intForQuery:sql];
        if (completedBlock) {
            dispatch_main_async_safe(^{
                completedBlock(count);
            });
        }
    }];
}
+ (void)selectAllForTable:(NSString *)table completedBlock:(void(^)(NSArray * datas))completedBlock{
    [_queue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@ = '%@'",tableName,fromTable_key,table];
        FMResultSet *resultSet = [db executeQuery:sql];
        NSMutableArray *datas = [NSMutableArray new];
        while (resultSet.next) {
            TSMessageModel *message = [TSMessageModel new];
            message.fromId = [resultSet objectForColumnName:fromId_key];
            message.content = [resultSet objectForColumnName:content_key];
            message.fromTable = [resultSet objectForColumnName:fromTable_key];
            message.readDate = [resultSet dateForColumn:readDate_key];
            message.receiveDate = [resultSet dateForColumn:receiveDate_key];
            NSData *otherdata = [resultSet dataForColumn:otherMessage_key];
            NSDictionary *otherMessage = nil;
            if (otherdata && ![otherdata isKindOfClass:[NSNull class]]) {
                otherMessage = [NSJSONSerialization JSONObjectWithData:otherdata options:NSJSONReadingMutableContainers error:nil];
            }
            message.otherMessage = otherMessage;
            [datas addObject:message];
        }
        if (completedBlock) {
            dispatch_main_async_safe(^{
                completedBlock(datas.copy);
            });
        }
    }];
    
}
//查询所有
+ (void)selectForLimit:(NSRange)range completedBlock:(void(^)(NSArray * datas))completedBlock{
    [_queue inDatabase:^(FMDatabase *db) {
        NSString *sql = range.location == NSNotFound?[NSString stringWithFormat:@"select * from %@",tableName]:[NSString stringWithFormat:@"select * from %@ order by id desc limit %ld,%ld",tableName,range.location,range.length];
        FMResultSet *resultSet = [db executeQuery:sql];
        NSMutableArray *datas = [NSMutableArray new];
        while (resultSet.next) {
            TSMessageModel *message = [TSMessageModel new];
            message.fromId = [resultSet objectForColumnName:fromId_key];
            message.content = [resultSet objectForColumnName:content_key];
            message.fromTable = [resultSet objectForColumnName:fromTable_key];
            message.readDate = [resultSet dateForColumn:readDate_key];
            message.receiveDate = [resultSet dateForColumn:receiveDate_key];
            NSData *otherdata = [resultSet objectForColumnName:otherMessage_key];
            NSDictionary *otherMessage = nil;
            if (otherdata && ![otherdata isKindOfClass:[NSNull class]]) {
                otherMessage = [NSJSONSerialization JSONObjectWithData:otherdata options:NSJSONReadingMutableContainers error:nil];
            }
            message.otherMessage = otherMessage;
            [datas addObject:message];
        }
        if (completedBlock) {
            dispatch_main_async_safe(^{
                completedBlock(datas.copy);
            });
        }
    }];
}
@end

