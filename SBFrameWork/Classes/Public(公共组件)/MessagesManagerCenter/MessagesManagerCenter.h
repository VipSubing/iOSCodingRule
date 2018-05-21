//
//  MessagesManagerCenter.h
//  园长版
//
//  Created by qyb on 2017/11/13.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSMessageModel.h"
/**
 消息管理的单元，如一个负责管理推送消息 它是线程安全的
 */

@interface MessageCountSuperUnit:NSObject
//消息总数
@property (assign,nonatomic,readonly) int32_t totalCount;
//获取消息总数的事务 用backValueBlock返回值
@property (copy,nonatomic) void (^totalEvent)(void(^backValueBlock)(NSInteger count));
//通过block让UI或者其他绑定消息数量，该bindMessageBlock会根据消息变化实时刷新调用
@property (copy,nonatomic) void (^bindMessageBlock)(NSInteger count);
//消息数增量
- (void)increment;
//消息数减量
- (void)decrement;
//刷新消息总数 如果设置了获取消息总数的事务，会调用该事物
- (void)updateTotalCount;
//消息数归零
- (void)clearToZero;
@end

/**
 消息提示管理中心 如 item bradge  icon message count
 */
@interface MessagesManagerCenter : NSObject
+ (MessagesManagerCenter *)managerCenter;

@property (strong,nonatomic) dispatch_queue_t asyncQueue;
@property (nonatomic) NSArray *units;

//重新拉消息
- (void)refreshAllMessage;
/**
 刷新推送消息数 

 @param ids fromId
 @param table fromTable
 */
+ (void)updateTSMessageCountWithIds:(NSString *)ids onTable:(NSString *)table;


//平台公告
@property (strong,nonatomic) MessageCountSuperUnit *platformMessage;
//系统消息
@property (strong,nonatomic) MessageCountSuperUnit *systemMessage;
//校园公告
@property (strong,nonatomic) MessageCountSuperUnit *schoolMessage;
//home message
@property (strong,nonatomic) MessageCountSuperUnit *homeBradgeMessage;
//在线直播
@property (strong,nonatomic) MessageCountSuperUnit *liveOnlineMessage;
//在线直播
@property (strong,nonatomic) MessageCountSuperUnit *teacherShiftMessage;
@property (strong,nonatomic) MessageCountSuperUnit *childBirthdayMessage;
@end
