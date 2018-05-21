//
//  AppDelegate+OpenUrl.m
//  MVVMFrameWork
//
//  Created by qyb on 2018/5/21.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import "AppDelegate+OpenUrl.h"
#import "TuiSongManager.h"
@implementation AppDelegate (OpenUrl)
/** iOS 10以后 APP已经接收到“远程”通知(推送) - 透传推送消息  */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    completionHandler(UIBackgroundFetchResultNewData);
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if ([[TuiSongManager shareManager] didReceiveRemoteNotificationWithUserInfo:userInfo]) {
        
    }
}
/** APP已经接收到“远程”通知(推送) - 透传推送消息  */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler{
    if ([[TuiSongManager shareManager] didReceiveRemoteNotificationWithUserInfo:userInfo]) {
        
    }
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return YES;
}
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(nonnull NSURL *)url
{
    return YES;
}
@end
