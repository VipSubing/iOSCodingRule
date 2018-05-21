//
//  TSMessageModel.h
//  BossCockpit
//
//  Created by qyb on 2017/8/2.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import "BaseModel.h"

extern NSString *const kTSSchoolNewsTable;
extern NSString *const kTSLiveNewsTable;
extern NSString *const kTSTeacherSignNewsTable;
@interface TSMessageModel : BaseModel

//内容
@property (nonatomic,copy) NSString *content;
//对象标记
@property (nonatomic,copy) NSString *fromTable;
// ids
@property (nonatomic,copy) NSString * fromId;
//收到推送时间
@property (copy,nonatomic) NSDate *receiveDate;
//最新查看时间查看
@property (nonatomic,copy) NSDate * readDate;
//其他信息
@property (nonatomic,strong) NSDictionary *otherMessage;


/**
 查询通过 limit
 
 @param range range
 @return messages
 */
+ (void)selectMessageForLimit:(NSRange)range completedBlock:(void(^)(NSArray <TSMessageModel *>*))completedBlock;
/**
 查询所有message
 
 @return messages
 */
+ (void)allMessagesWithCompletedBlock:(void(^)(NSArray <TSMessageModel *>*))completedBlock;

/**
 查询所有 关于某个table
 
 @param table 推送模块标志
 @return TSMessageModels
 */
+ (void)selectAllForTable:(NSString *)table completedBlock:(void(^)(NSArray * datas))completedBlock;
//提交db
- (void)commitDBWithCompletedBlock:(void(^)(BOOL success))completedBlock;

//更新
+ (void)updateReadDate:(NSDate *)date forKey:(NSString *)key completedBlock:(void(^)(BOOL success))completedBlock;

//输出 mm-dd HH:mm 时间格式
+ (NSString *)outputFormatWithDate:(NSDate *)date;

//未读消息数
+ (void)unreadMessageCountWithCompletedBlock:(void(^)(NSInteger count))completedBlock;
//消息总数
+ (void)messageCountWithCompletedBlock:(void(^)(NSInteger count))completedBlock;
//校园公告未读消息数
+ (void)schoolUnreadMessageCountWithCompletedBlock:(void(^)(NSInteger count))completedBlock;
//教师排班
+ (void)teacherShiftListMessageCountWithCompletedBlock:(void(^)(NSInteger count))completedBlock;
//直播未读消息
+ (void)liveUnreadMessageCountWithCompletedBlock:(void(^)(NSInteger count))completedBlock;
//标记所有已读
+ (void)updateAllMessageMakeReadedWithCompletedBlock:(void(^)(void))completedBlock;
@end

