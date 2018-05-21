//
//  SBWebViewController.m
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/13.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import "SBWebViewController.h"
static void *WkwebBrowserContext = &WkwebBrowserContext;
static const NSTimeInterval requestInterval = 7;
@interface SBWebViewController ()

//web view
@property (nonatomic, strong,readwrite) WKWebView *wkWebView;
//bridge
@property (nonatomic,strong,readwrite) WKWebViewJavascriptBridge* bridge;
//设置加载进度条
@property (nonatomic,strong,readwrite) UIProgressView *progressView;

@end

@implementation SBWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hideBack = NO;
    
    [self.view addSubview:self.wkWebView];
    
    if (!self.hideProgress) [self.view addSubview:self.progressView];
    if (_url.length) [self loadWebURLSring:_url];
}

#pragma  mark -  public
- (void)loadWebURLSring:(NSString *)string{
    if ([string rangeOfString:@"?"].location != NSNotFound) {
        NSArray *urls = [string componentsSeparatedByString:@"?"];
        NSString *parameter = [urls lastObject];
        NSString *parameterEncode = [parameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        string = [string stringByReplacingOccurrencesOfString:parameter withString:parameterEncode];
    }
    NSURLRequest * Request = [NSURLRequest requestWithURL:[NSURL URLWithString:string] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:requestInterval];
    if (_wkWebView) {
        [_wkWebView loadRequest:Request];
    }else _url = string.copy;
}
+ (NSDictionary *)defaultsJSBridgeResponse{
    return [self JSBridgeReponseWithStatus:1 data:nil msg:nil];
}
+ (NSDictionary *)JSBridgeReponseWithStatus:(int)status data:(NSDictionary *)data msg:(NSString *)msg{
    if (!data) {
        data = @{};
    }
    if (!msg) {
        msg = @"";
    }
    return @{@"status":@(status),@"data":data,@"msg":msg};
}
#pragma mark - Override

- (void)setHideProgress:(BOOL)hideProgress{
    _hideProgress = hideProgress;
    if (hideProgress == YES) {
        if (self.progressView.superview) [self.progressView removeFromSuperview];
    }else{
        if (!self.progressView.superview) [self.view addSubview:self.progressView];
    }
}
- (void)setHideNavigation:(BOOL)hideNavigation{
    [super setHideNavigation:hideNavigation];
    if (hideNavigation) {
        self.wkWebView.frame = CGRectMake(0, STATUS_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-STATUS_HEIGHT);
    }else self.wkWebView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-StatusAndNaviBarHeight);
}
- (UIProgressView *)progressView{
    if (!_progressView) {
        CGFloat progressViewW = SCREEN_WIDTH;
        CGFloat progressViewH = 3;
        CGFloat progressViewX = 0;
        CGFloat progressViewY = CGRectGetHeight(self.navigationController.navigationBar.frame) - progressViewH + 1;
        UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(progressViewX, progressViewY, progressViewW, progressViewH)];
        progressView.progressTintColor = [UIColor colorWithRed:(10 / 255.0) green:(193 / 255.0) blue:(42 / 255.0) alpha:1];
        progressView.trackTintColor = [UIColor clearColor];
        _progressView = progressView;
    }
    return _progressView;
}
- (WKWebView *)wkWebView{
    if (_wkWebView == nil) {
        //设置网页的配置文件
        WKWebViewConfiguration * Configuration = [[WKWebViewConfiguration alloc]init];
        //允许视频播放
        if ([UIDevice currentDevice].systemVersion.floatValue > 9.0f) {
            Configuration.allowsAirPlayForMediaPlayback = YES;
        }
        Configuration.allowsInlineMediaPlayback = YES;
        Configuration.selectionGranularity = YES;
        Configuration.processPool = [[WKProcessPool alloc] init];
        //自定义配置,一般用于 js调用oc方法(OC拦截URL中的数据做自定义操作)
        WKUserContentController * UserContentController = [[WKUserContentController alloc]init];
        // 是否支持记忆读取
        //解决iOS 8加载完成后短暂黑屏问题
        if (@available(iOS 9.0, *)) {
            Configuration.suppressesIncrementalRendering = YES;
        }
        Configuration.userContentController = UserContentController;
        _wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-StatusAndNaviBarHeight) configuration:Configuration];
        // 设置代理
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
        [_wkWebView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:WkwebBrowserContext];
        _wkWebView.allowsBackForwardNavigationGestures = YES;
    }
    return _wkWebView;
}
#pragma mark ======== WKNavigationDelegate =======

//这个是网页加载完成，导航的变化
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
}

//开始加载
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    //开始加载的时候，让加载进度条显示
    _progressView.hidden = NO;
}

//内容返回时调用
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
}

//服务器请求跳转的时候调用
-(void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    
}
//服务器开始请求的时候调用
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    _progressView.hidden = NO;
    WebViewJavascriptBridgeBase *base = [[WebViewJavascriptBridgeBase alloc] init];
    if ([base isWebViewJavascriptBridgeURL:navigationAction.request.URL])
    {
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 内容加载失败时候调用
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    _progressView.hidden = YES;
}

//跳转失败的时候调用
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    
}

// 获取js 里面的提示
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    completionHandler();
}

// js 信息的交流
-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    completionHandler(YES);
}

// 交互。可输入的文本。
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    completionHandler(@"");
}
#pragma mark - progress
//KVO监听进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == _wkWebView && _progressView.superview) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.wkWebView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.wkWebView.estimatedProgress animated:animated];
        // Once complete, fade out UIProgressView
        if(self.wkWebView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
                self.progressView.hidden = YES;
            }];
        }
    }
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:self.hideNavigation animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
- (void)dealloc
{
    [_wkWebView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    _wkWebView.navigationDelegate = nil;
    _wkWebView.UIDelegate = nil;
}
@end
