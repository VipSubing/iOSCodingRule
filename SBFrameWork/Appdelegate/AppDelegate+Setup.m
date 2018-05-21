//
//  AppDelegate+setup.m
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/6.
//  Copyright © 2017年 qyb. All rights reserved.
//
#if DEBUG
#import <JPFPSStatus/JPFPSStatus.h>
#import <FLEX/FLEX.h>
#endif
#import <Realm/Realm.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <SDWebImage/SDWebImageDownloader.h>
#import <SDWebImage/SDImageCache.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import "AppDelegate+Setup.h"
#import "JDStatusBarNotification.h"
#import "AvoidCrash.h"
//网络状态监控地址
static NSString* const kURL_Reachability__Address = @"www.baidu.com";
@implementation AppDelegate (Setup)
- (void)launchSetup{
    //debug
    [self debugSetup];
    //crash
    [self crashSetup];
    //user agent
    [self webUserAgentSetup];
    //网络监听
    [self networkListening];
    //用户偏好设置
    [self userPreferences];
    //键盘设置
    [self keyBoardSetup];
    //webimage
    [self webImageDecodeSetup];
    //realm
    [self setupRealm];
}
- (void)debugSetup{
#if DEBUG
    [[FLEXManager sharedManager] showExplorer];
#endif
#if defined(DEBUG)||defined(_DEBUG)
    [[JPFPSStatus sharedInstance] openWithHandler:^(NSInteger fpsValue) {
        NSLog(@"fpsvalue %@",@(fpsValue));
    }];
#endif
}
- (void)crashSetup{
#if 1
    [AvoidCrash becomeEffective];
#endif
}
- (void)setupRealm{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //添加userInfo 当前用户更换的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:_cmd name:kSBUserInfoCurrentUserChangeNotification object:nil];
    });
    SBUserInfo.userId = @"123456_test";
    if (SBUserInfo.userId.length) {
        return;
    }
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    // 使用默认的目录，但是请将文件名替换为用户名
    config.fileURL = [[[config.fileURL URLByDeletingLastPathComponent]
                       URLByAppendingPathComponent:SBUserInfo.userId]
                      URLByAppendingPathExtension:@"realm"];
    // 将该配置设置为默认 Realm 配置
    [RLMRealmConfiguration setDefaultConfiguration:config];
}
- (void)webUserAgentSetup{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *appFlag = [NSString stringWithFormat:@"_%@@%@",UserAgent,AppVersionCode];
    NSString *newUserAgent = [userAgent stringByAppendingString:appFlag];//自定义需要拼接的字符串
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:newUserAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
}
- (void)networkListening{
    //添加网络监听
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [AFNetworkActivityIndicatorManager sharedManager].activationDelay = 0.5f;
    AFNetworkReachabilityManager *networking = [AFNetworkReachabilityManager sharedManager];
    [AFNetworkReachabilityManager  managerForDomain:kURL_Reachability__Address];
    [networking setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                //不可知网络
                [JDStatusBarNotification showWithStatus:@"当前网络连接异常，请查看设置"];
                break;
            case AFNetworkReachabilityStatusNotReachable:
                //无网络
                [JDStatusBarNotification showWithStatus:@"当前网络连接失败，请查看设置"];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                //移动网络
                [JDStatusBarNotification dismissAnimated:YES];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                //Wi-Fi网络
                [JDStatusBarNotification dismissAnimated:YES];
                break;
            default:
                break;
        }
    }];
    [networking startMonitoring];
}
- (void)userPreferences{
    //第一次启动
    if (0) {
        SBUserDefault.allowReceiveMessage = YES;
        SBUserDefault.allowMessageVoice = YES;
        SBUserDefault.allowMessageVibration = YES;
    }
}
- (void)keyBoardSetup{
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES; // 控制整个功能是否启用。
    manager.shouldResignOnTouchOutside = YES; // 控制点击背景是否收起键盘
    manager.shouldToolbarUsesTextFieldTintColor = YES; // 控制键盘上的工具条文字颜色是否用户自定义
    manager.enableAutoToolbar = YES; // 控制是否显示键盘上的工具条
    manager.toolbarManageBehaviour = IQAutoToolbarByTag; // 最新版的设置键盘的returnKey的关键字 ,可以点击键盘上的next键，自动跳转到下一个输入框，最后一个输入框点击完成，自动收起键盘。
}
- (void)webImageDecodeSetup{
    [[SDImageCache sharedImageCache].config setShouldDecompressImages:NO];
    [[SDWebImageDownloader sharedDownloader] setShouldDecompressImages:NO];
}
@end
