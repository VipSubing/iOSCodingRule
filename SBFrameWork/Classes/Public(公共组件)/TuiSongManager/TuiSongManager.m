//
//  TuiSongManager.m
//  MVVMFrameWork
//
//  Created by qyb on 2018/5/21.
//  Copyright © 2018年 qyb. All rights reserved.
//
#import <AudioToolbox/AudioToolbox.h>
#import <UserNotifications/UserNotifications.h>
#import "GVUserDefaults+CustomUser.h"
#import "TuiSongManager.h"
#import "GeTuiSdk.h"
#import "SBSimpleRouter.h"
#import "MessagesManagerCenter.h"


#define kGtAppId           @""
#define kGtAppKey          @""
#define kGtAppSecret       @""

//系统默认路由调整
NSString *const rJumpTargetOfSpecifiedUrl = @"AppDelegate/Route#defaultJump?@@@";

NSString *const NotificationCategoryIdent = @"ACTIONABLE";
NSString *const NotificationActionOneIdent = @"ACTION_ONE";
NSString *const NotificationActionTwoIdent = @"ACTION_TWO";

@interface TuiSongManager()<GeTuiSdkDelegate>
@end
@implementation TuiSongManager
#pragma mark - Public
+ (TuiSongManager *)shareManager{
    static TuiSongManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [TuiSongManager new];
    });
    return manager;
}
- (void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userChange:) name:kSBUserInfoCurrentUserChangeNotification object:nil];
}
/** 注册用户通知 */
- (void)registerUserNotification{
    [self getuiRegist];
    [self notificationRegist];
}

- (BOOL)didReceiveRemoteNotificationWithUserInfo:(NSDictionary *)userInfo{
    TSMessageModel *model = [self apnsModelParseWithJson:userInfo];
    if (model) {
       return [self routeTarget:model.fromTable param:model.fromId withModel:model];
    }else return NO;
}
- (void)handleGetuiOriginalData:(NSData *)data andOffLine:(BOOL)offLine
{
    NSError *error = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        return;
    }
    //消息存入db
    TSMessageModel *model = [TSMessageModel modelWithDictionary:dic];
    if (!model) {
        return;
    }
    model.receiveDate = [NSDate date];
    [model commitDBWithCompletedBlock:nil];
    
    //刷新消息数
    [[MessagesManagerCenter managerCenter] refreshAllMessage];
    if (!offLine) {
        //在线消息直接阅读
        IF_NULL_TO_STRING(model.fromId);
        __weak typeof(self) weak = self;
        [EMAlertView showAlertWithTitle:@"系统消息" message:@"您有一条新的消息" completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
            __strong typeof(weak) strong = weak;
            if (buttonIndex == 1) {
                [strong routeTarget:model.fromTable param:model.fromId withModel:model];
            }
        } cancelButtonTitle:@"忽略" otherButtonTitles:@"查看",nil];
    }
}
#pragma mark - within  route
- (BOOL)routeTarget:(NSString *)targetCode param:(id)param withModel:(TSMessageModel *)model
{
    //标记已读
    model.readDate = [NSDate date];
    model.receiveDate = [NSDate date];
    [model commitDBWithCompletedBlock:nil];
    //刷新消息数
    [[MessagesManagerCenter managerCenter] refreshAllMessage];
    UIViewController *target = nil;
    
    if ([targetCode isEqualToString:kTSSchoolNewsTable])
    {
        
        
    }else if ([targetCode isEqualToString:kTSTeacherSignNewsTable])
    {
        
    }
    if (target) {
        [[SBSimpleRouter shareRouter] callActionRequest:rJumpTargetOfSpecifiedUrl params:@[target,@"push"]];
        return YES;
    }
    return NO;
}
#pragma mark - Regist
- (void)userChange:(NSNotification *)notification{
    SBUserInfoAgent *user = notification.userInfo[kSBUserInfoNotificationValue];
    //解绑
    [GeTuiSdk unbindAlias:user.oldAccount andSequenceNum:user.oldAccount];
    //发送别名通知
    [GeTuiSdk bindAlias:user.accout andSequenceNum:user.accout];
}
- (void)registRoute{
    
    //注册自定义anps跳转路由  firstP:target?vc  secondP:Type > push.present
    [[SBSimpleRouter shareRouter] registHandleBlock:^id(NSArray *params) {
        if (![params.firstObject isKindOfClass:[UIViewController class]] || params.count != 2) {
            return nil;
        }
        //未登陆不得跳转
        if (!SBUserDefault.isLogin) {
            return nil;
        }
        CYLTabBarController *root = (CYLTabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        
        if (![root isKindOfClass:[CYLTabBarController class]]) {
            return nil;
        }
        UINavigationController *select = (UINavigationController *)root.selectedViewController;
        NSString *type = [params objectAtIndex:1];
        UIViewController *target = params.firstObject;
        if ([target isMemberOfClass:[self.class showingController].class]) {
            return @NO;
        }
        if ([type isEqualToString:@"push"]) {
            [select pushViewController:target animated:YES];
            return @YES;
        }else if ([type isEqualToString:@"present"]){
            while (root.presentedViewController) {
                root = root.presentedViewController;
            }
            [root presentViewController:target animated:YES completion:nil];
            return @YES;
        }
        return nil;
    } forFullRoute:rJumpTargetOfSpecifiedUrl];
}
- (void)getuiRegist{
    // 通过 appId、 appKey 、appSecret 启动SDK，注：该方法需要在主线程中调用
    [GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret delegate:self];
}
- (void)notificationRegist{
    if (([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0)) {
        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        
        center.delegate = self;
        
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"成功");
            }
        }];
        
    } else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && [[UIDevice currentDevice].systemVersion doubleValue] < 10.0){//iOS8-iOS10
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound) categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
    }
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}
#pragma mark - 用户通知(推送)回调 _IOS 8.0以上使用

/** 已登记用户通知 */
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // 注册远程通知（推送）
    [application registerForRemoteNotifications];
}

#pragma mark - 远程通知(推送)回调

/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"\n>>>[DeviceToken Success]:%@\n\n", token);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [GeTuiSdk registerDeviceToken:token];
    });
}

/** APP已经接收到“远程”通知(推送) - (App运行在后台/App运行在前台) */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
}


#pragma mark - GeTuiSdkDelegate

/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    
}


//别名推送返回结果
- (void)GeTuiSdkDidAliasAction:(NSString *)action result:(BOOL)isSuccess sequenceNum:(NSString *)aSn error:(NSError *)aError {
    if ([kGtResponseBindType isEqualToString:action]) {
        NSLog(@"绑定结果 ：%@ !, sn : %@", isSuccess ? @"成功" : @"失败", aSn);
        if (!isSuccess) {
            NSLog(@"失败原因: %@", aError);
        }
    } else if ([kGtResponseUnBindType isEqualToString:action]) {
        NSLog(@"绑定结果 ：%@ !, sn : %@", isSuccess ? @"成功" : @"失败", aSn);
        if (!isSuccess) {
            NSLog(@"失败原因: %@", aError);
        }
    }
}

/** SDK收到透传消息回调 */
- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId {
    if (payloadData) {
        [self handleGetuiOriginalData:payloadData andOffLine:offLine];
        
        if (!offLine) {
            //在线推送
            if (SBUserDefault.allowMessageVoice) {
                //允许声音
                AudioServicesPlaySystemSound(1007);
            }
            if (SBUserDefault.allowMessageVibration) {
                //允许震动
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
        }
    }
    [GeTuiSdk sendFeedbackMessage:90001  andTaskId:taskId andMsgId:msgId];
}

#pragma mark - 用户通知(推送) _自定义方法
/** 远程通知注册失败委托 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"\n>>>[DeviceToken Error]:%@\n\n", error.description);
}
/** SDK遇到错误回调 */
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    NSLog(@"\n>>>[GexinSdk error]:%@\n\n", [error localizedDescription]);
}

/** SDK收到sendMessage消息回调 */
- (void)GeTuiSdkDidSendMessage:(NSString *)messageId result:(int)result {
    
}

/** SDK运行状态通知 */
- (void)GeTuiSDkDidNotifySdkState:(SdkStatus)aStatus {
    // [EXT]:通知SDK运行状态
    NSLog(@"\n>>>[GexinSdk SdkState]:%u\n\n", aStatus);
}

/** SDK设置推送模式回调 */
- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error {
    if (error) {
        NSLog(@"\n>>>[GexinSdk SetModeOff Error]:%@\n\n", [error localizedDescription]);
        return;
    }
    NSLog(@"\n>>>[GexinSdk SetModeOff]:%@\n\n", isModeOff ? @"开启" : @"关闭");
}
#pragma mark - Utils
//json解析model
- (TSMessageModel *)apnsModelParseWithJson:(id)json{
    //个推
    if (json[@"aps"][@"category"]) {
        NSDictionary *info = json[@"aps"][@"category"];
        if ([info isKindOfClass:[NSDictionary class]
             ]) {
            TSMessageModel * model = [TSMessageModel modelWithDictionary:info];
            
            return model;
        }else if ([info isKindOfClass:[NSString class]]){
            NSData *JSONData = [(NSString *)info dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableLeaves error:nil];
            TSMessageModel * model = [TSMessageModel modelWithDictionary:responseJSON];
            
            return model;
        }
    }
    return nil;
}
+ (UIViewController *)showingController{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    id  nextResponder = nil;
    UIViewController *appRootVC=window.rootViewController;
    if (appRootVC.presentedViewController) {
        nextResponder = appRootVC.presentedViewController;
    }else{
        
        NSLog(@"===%@",[window subviews]);
        UIView *frontView = [[window subviews] objectAtIndex:0];
        nextResponder = [frontView nextResponder];
    }
    
    if ([nextResponder isKindOfClass:[UITabBarController class]]){
        UITabBarController * tabbar = (UITabBarController *)nextResponder;
        UINavigationController * nav = (UINavigationController *)tabbar.viewControllers[tabbar.selectedIndex];
        result=nav.childViewControllers.lastObject;
        
    }else if ([nextResponder isKindOfClass:[UINavigationController class]]){
        UIViewController * nav = (UIViewController *)nextResponder;
        result = nav.childViewControllers.lastObject;
    }else{
        result = nextResponder;
    }
    return result;
}
@end
