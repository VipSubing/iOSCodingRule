//
//  AppDelegate.m
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/5.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+Setup.h"
#import "ZJLoginController.h"
#import "UMMobClick/MobClick.h"
#import "TuiSongManager.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //launch setup
    [self launchSetup];
    [self launchRegist];
    _window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen] .bounds];
    _window.backgroundColor = [UIColor whiteColor];
    [_window makeKeyAndVisible];
    _window.rootViewController = [[ZJLoginController alloc] init];
    return YES;
}


- (void)launchRegist{
    //友盟注册
    UMConfigInstance.appKey = @"";
    UMConfigInstance.channelId = @"appstore";
    [MobClick startWithConfigure:UMConfigInstance];
    //个推注册
    [[TuiSongManager shareManager] registerUserNotification];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
 

@end
