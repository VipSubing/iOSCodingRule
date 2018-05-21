//
//  ACMarcos.h
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/6.
//  Copyright © 2017年 qyb. All rights reserved.
//

#ifndef ACMarcos_h
#define ACMarcos_h

#define AdaptiveScreen ({\
    float result;\
    if (iPhone6_Plus) {\
        result = 5.5/4.7;\
    }else if (iPhone6){\
        result = 4.7/4.7;\
    }else if(iPhone5){\
        result = 4.0/4.7;\
    }else{\
        result = 4.7/4.7;\
    }\
    (result);\
})

#define SCREEN_WIDTH                    ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT                   ([UIScreen mainScreen].bounds.size.height)
#define StatusAndNaviBarHeight (STATUS_HEIGHT+NAVI_HEIGHT)
#define STATUS_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define NAVI_HEIGHT self.navigationController.navigationBar.bounds.size.height
#define TABBAR_HEIGHT 49
//系统提示框 AlertController m :message block : 点击事件
#define Alert(m,block) [EMAlertView alertWithMessage:m handle:block];

//提示框
#define SBShowStatus(status) \
if(self){\
    if([self isKindOfClass:[UIView class]]){\
        UIView *view = (UIView *)self;\
        if(view.viewController.isVisible) {\
            ShowStatus(status);\
        }\
    }else if([self isKindOfClass:[UIViewController class]]){\
        UIViewController *viewController = (UIViewController *)self;\
        if(viewController.isVisible) {\
            ShowStatus(status);\
        }\
    }else {\
        ShowStatus(status);\
    }\
}

#define ShowStatus(status) CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle]; \
[KeyWindow  makeToast:status duration:1 position:CSToastPositionBottom style:style];\
KeyWindow.userInteractionEnabled = NO; \
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{\
KeyWindow.userInteractionEnabled = YES;\
});\

#define KeyWindow [UIApplication sharedApplication].keyWindow

// 判断字段时候为空的情况
#define IF_NULL_TO_STRING(x) x=([(x) isEqual:[NSNull null]]||(x)==nil)? @"":TEXT_STRING(x)
// 转换为字符串
#define TEXT_STRING(x) [NSString stringWithFormat:@"%@",x]

// GCD
#define dispatch_main_async_safe(block)\
    if ([NSThread isMainThread]) {\
    block();\
    } else {\
    dispatch_async(dispatch_get_main_queue(), block);\
    }
#define dispatch_main_sync_safe(block)\
    if ([NSThread isMainThread]) {\
    block();\
    } else {\
    dispatch_sync(dispatch_get_main_queue(), block);\
    }
//主线延迟执行
#define dispatch_main_async_afterRun(time,block) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), block)


///获取设备 Device
#define iPhone7_Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone7 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone6_Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )



/// Log
// 输出日志 (格式: [时间] [哪个方法] [哪行] [输出内容])
#ifdef DEBUG
#define NSLog(format, ...)  printf("\n[%s] %s [第%zd行] 💕 %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(format, ...)
#endif

// 打印方法
#define SBLogFunc NSLog(@"%s", __func__)
// 打印请求错误信息
#define SBLogError(error) NSLog(@"Error: %@", error)
// 销毁打印
#define SBDealloc NSLog(@"\n =========+++ %@  销毁了 +++======== \n",[self class])
#endif /* ACMarcos_h */
