//
//  SBWebViewController.h
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/13.
//  Copyright © 2017年 qyb. All rights reserved.
//
#import <WebViewJavascriptBridge/WKWebViewJavascriptBridge.h>
#import <WebKit/WKWebView.h>
#import <WebKit/WebKit.h>
#import "BaseViewController.h"

@interface SBWebViewController : BaseViewController<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler,UINavigationControllerDelegate,UINavigationBarDelegate>

@property (nonatomic, strong,readonly) WKWebView *wkWebView;

@property (nonatomic,strong,readonly) WKWebViewJavascriptBridge* bridge;
//设置加载进度条
@property (nonatomic,strong,readonly) UIProgressView *progressView;

@property (copy,nonatomic) NSString *url;
//隐藏进度条
@property (assign,nonatomic) BOOL hideProgress;
//关闭桥接
@property (assign,nonatomic) BOOL closeBridge;

- (void)loadWebURLSring:(NSString *)string;




//默认js返回
+ (NSDictionary *)defaultsJSBridgeResponse;

+ (NSDictionary *)JSBridgeReponseWithStatus:(int)status data:(NSDictionary *)data msg:(NSString *)msg;
@end
