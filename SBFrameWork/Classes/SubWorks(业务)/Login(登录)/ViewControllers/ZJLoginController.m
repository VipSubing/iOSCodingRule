//
//  ZJLoginController.m
//  MVVMFrameWork
//
//  Created by qyb on 2018/5/18.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import "ZJLoginController.h"
#import "ZJExampleController.h"

@interface ZJLoginController ()
@property (nonatomic) UITextField *accountText;

@property (nonatomic) UITextField *passwordText;

@property (nonatomic) UIButton *loginBtn;

@property (nonatomic) NSString *account;
@property (nonatomic) NSString *password;
@end

@implementation ZJLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"登录";
    self.hideBack = YES;
    [self initContent];
    

}
- (instancetype)initWithAccount:(NSString *)account password:(NSString *)password callback:(void(^)(BOOL success,id other))callback{
    return nil;
}
- (void)initContent{
    _accountText = [[UITextField alloc] initWithFrame:CGRectMake(0, StatusAndNaviBarHeight, SCREEN_WIDTH, 50)];
    _accountText.borderStyle = UITextBorderStyleRoundedRect;
    _accountText.textColor = [UIColor darkTextColor];
    _accountText.placeholder = @"账号";
    [self.view addSubview:_accountText];
    
    _passwordText = [[UITextField alloc] initWithFrame:CGRectMake(0, _accountText.bottom+20, SCREEN_WIDTH, 50)];
    _passwordText.borderStyle = UITextBorderStyleRoundedRect;
    _passwordText.textColor = [UIColor darkTextColor];
    _passwordText.placeholder = @"密码";
    [self.view addSubview:_passwordText];
    
    _loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, _passwordText.bottom+20, SCREEN_WIDTH, 50)];
    [_loginBtn addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
    [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    _loginBtn.backgroundColor = StandardDefaultColor;
    [self.view addSubview:_loginBtn];
}

#pragma mark - Action
- (void)loginAction:(UIButton *)sender{
    SBHttpRequest *request = [SBHttpRequest defaultRequest];
    NSMutableDictionary *param = [SBHttpRequest defaultParam];
    [param setObject:@"18768105821" forKey:@"mobile"];
    [param setObject:@"123456" forKey:@"password"];
    [param setObject:@"3" forKey:@"platform"];
    [request sendRequestWithBaseUrl:@"http://bayi-api.hzbayi.com:81/V2.1.0" requestUrl:@"user/login" requestParameter:param completionWithSuccess:^(YTKRequest * _Nonnull request, id  _Nonnull responseObject) {
        if (responseObject) {
            //发送成功通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kSBUserInfoCurrentUserChangeNotification object:nil];
            //模拟跳转
            [self toExample];
        }else{
            SBShowStatus(responseObject[@"msg"]);
        }
    } failure:^(YTKRequest * _Nonnull request, NSError * _Nonnull error) {
        SBShowStatus(error.userInfo[SBRequestFailureErrorDescKey]);
    }];
    
}
- (void)toExample{
    [UIApplication sharedApplication].keyWindow.rootViewController = [AppDelegate  applicationRoot];
}
@end
