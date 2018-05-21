//
//  PruductKey.h
//  XuYouProduct
//
//  Created by bayi on 2017/2/6.
//  Copyright © 2017年 qyb. All rights reserved.
//
//全局关键字 如 项目名称 开发团队名称
#ifndef PruductKey_h
#define PruductKey_h

#define PruductName @""
#define AppVersionCode [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
#define AppBuildCode [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
#define AppBundleId [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]
#define AppDeviceUUId [[[UIDevice currentDevice] identifierForVendor] UUIDString]
#define AppSystemVersionCode [[UIDevice currentDevice] systemVersion]
#define AppScreenSizeCode [NSString stringWithFormat:@"%fx%f",SCREEN_WIDTH,SCREEN_HEIGHT]

#define App_itunes_ID @""
#define Bayi_AppScheme @""
#define Wechat_UrlScheme @""
//web userAgent
#define UserAgent @""

#endif /* PruductKey_h */
