//
//  GVUserDefaults+CustomUser.h
//  XuYouProduct
//
//  Created by bayi on 2017/2/14.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import "GVUserDefaults.h"
#define SBUserDefault [GVUserDefaults standardUserDefaults]
@interface GVUserDefaults (CustomUser)
//新版本
@property (copy,nonatomic) NSString *latelyVesion;
//是否登陆
@property (assign,nonatomic) BOOL isLogin;
//同意协议
@property (assign,nonatomic) BOOL IsDelegateAgree;

///preferences
//是否允许接受新消息
@property (assign,nonatomic) BOOL allowReceiveMessage;
//新消息是否需要声音
@property (assign,nonatomic) BOOL allowMessageVoice;
//新消息是否需要震动
@property (assign,nonatomic) BOOL allowMessageVibration;
@end
