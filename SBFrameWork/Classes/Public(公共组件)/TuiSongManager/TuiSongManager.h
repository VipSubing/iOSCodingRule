//
//  TuiSongManager.h
//  MVVMFrameWork
//
//  Created by qyb on 2018/5/21.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSMessageModel.h"

@interface TuiSongManager : NSObject


+ (TuiSongManager *)shareManager;


- (void)registerUserNotification;


- (BOOL)routeTarget:(NSString *)targetCode param:(id)param withModel:(TSMessageModel *)model;

- (BOOL)didReceiveRemoteNotificationWithUserInfo:(NSDictionary *)userInfo;
@end
