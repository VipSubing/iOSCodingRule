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
//password keychain path
extern NSString *const kSBUserInfoAgentAccountKey;
//当前用户更换通知
extern NSString *const kSBUserInfoCurrentUserChangeNotification;
//用户信息改变通知
extern NSString *const kSBUserInfoValueChangeNotification;

//获取通知中的信 keypath
extern NSString *const kSBUserInfoNotificationKeyPath;
//获取通知中的信 vaule  就是 userinfo 自己
extern NSString *const kSBUserInfoNotificationValue;

@interface SBUserInfoAgent : BaseModel

@property (copy,nonatomic) NSString *userId;

@property (copy,nonatomic) NSString *userName;
// account
@property (copy,nonatomic) NSString *accout;
//password 的充分条件是 mobile code
@property (copy,nonatomic) NSString *password;

//老账号
@property (copy,nonatomic) NSString *oldAccount;
//老密码
@property (copy,nonatomic) NSString *oldPassword;
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
