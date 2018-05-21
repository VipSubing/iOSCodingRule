//
//  BaseViewController.m
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/6.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import "BaseViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"


@interface BaseViewController ()

@property (strong,nonatomic) UIButton *backButton;

@end

@implementation BaseViewController
{
    BOOL _backButtonLock;
}
#pragma mark - public

#pragma mark -

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    BaseViewController *viewController = [super allocWithZone:zone];
    [viewController objectInitialized];
    return viewController;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BackgroundDefaultColor;
    self.navigationController.navigationBar.translucent = NO;
    if (@available(iOS 11.0, *)) {
        if([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]){
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    [self.cSignal.viewDidLoadSignal sendNext:nil];
    [self setupBackItem];
}
- (void)setupBackItem{
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.backButton];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
}

- (UIButton *)backButton{
    if (_backButton == nil) {
        _backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 5, 30, 30)];
        [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [_backButton setImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
        if ((self == [self.navigationController.viewControllers firstObject] && self.navigationController.viewControllers.count <= 1)) _backButton.hidden = YES;
        if (_backButtonLock) _backButton.hidden = _hideBack;
    }
    return _backButton;
}
- (void)objectInitialized{
    
}
#pragma mark - Override
- (void)setHideBack:(BOOL)hideBack{
    _backButtonLock = YES;
    _hideBack = hideBack;
    _backButton.hidden = hideBack;
}
- (void)setBanBackGestures:(BOOL)banBackGestures{
    _banBackGestures = banBackGestures;
    self.fd_interactivePopDisabled = banBackGestures;
}
- (void)setHideNavigation:(BOOL)hideNavigation{
    _hideNavigation = hideNavigation;
    [self.navigationController setNavigationBarHidden:hideNavigation animated:YES];
}
//此vc是否在显示
- (BOOL)isVisible{
    return (self.isViewLoaded && self.view.window);
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.cSignal.viewDidAppearSignal sendNext:nil];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.cSignal.viewWillAppearSignal sendNext:nil];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.cSignal.viewDidDisappearSignal sendNext:nil];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.cSignal.viewWillDisappearSignal sendNext:nil];
}
- (void)dealloc{
    [self.cSignal.selfDealloc sendNext:nil];
    NSLog(@"\n =========+++ %@  销毁了  ========== \n",[self class]);
}

#pragma mark - back
- (void)back
{
    if (self.naviBackType == BaseNaviGationBackWithPopAndDiss) {
        //兼容模式
        [self _popAndDiss];
    }else if (self.naviBackType == BaseNaviGationBackWithPop){
        //pop
        [self _onlyPop];
    }else if (self.naviBackType == BaseNaviGationBackWithDiss){
        [self _onlyDiss];
    }
}
- (void)_onlyDiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)_onlyPop{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)_popAndDiss{
    if (self.navigationController.viewControllers.count>1) {
        [self _onlyPop];
    }
    else{
        [self _onlyDiss];
    }
}


#pragma mark - Orientation
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {return UIInterfaceOrientationMaskPortrait;}
- (BOOL)shouldAutorotate {return YES;}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {return UIInterfaceOrientationPortrait;}

#pragma mark - Status bar
- (BOOL)prefersStatusBarHidden { return NO; }
- (UIStatusBarStyle)preferredStatusBarStyle { return UIStatusBarStyleLightContent; }
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation { return UIStatusBarAnimationFade; }

@end
