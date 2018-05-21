//
//  SBUserInfoAgent.h
//  MVVMFrameWork
//
//  Created by qyb on 2018/1/2.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import <SSKeychain/SSKeychain.h>
#import "BaseModel.h"

#define SBUserInfo [SBUserInfoAgent shareInfo]

extern NSString *const kSBUserInfoAgentAccountKey;

extern NSString *const kSBUserInfoCurrentUserChangeNotification;

extern NSString *const kSBUserInfoValueChangeNotification;


extern NSString *const kSBUserInfoNotificationKeyPath;

extern NSString *const kSBUserInfoNotificationValue;

@interface SBUserInfoAgent : BaseModel

@property (copy,nonatomic) NSString *userId;

@property (copy,nonatomic) NSString *userName;
// account
@property (copy,nonatomic) NSString *mobileCode;
//password 的充分条件是 mobile code
@property (copy,nonatomic) NSString *password;

/**
 单例化一个用户信息代理, 首先会从序列化磁盘里面拿，没有则直接创建一个

 @return SBUserInfoAgent
 */
+ (SBUserInfoAgent *)shareInfo;


/**
 重置用户信息  用过一个json

 @param json 源json
 @return self
 */
- (SBUserInfoAgent *)resetForJson:(id)json;
//提交修改到磁盘
- (void)commit;
@end
