//
//  SBNavigationController.m
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/6.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import "SBNavigationController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "BaseViewController.h"
@interface SBNavigationController ()<UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@end

@implementation SBNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupNavigationBarTheme];
    self.interactivePopGestureRecognizer.delegate = self;
    self.delegate = self;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [super pushViewController:viewController animated:animated];
}

#pragma mark - UIGestureRecognizerDelegate 在根视图时不响应interactivePopGestureRecognizer手势

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return self.viewControllers.count > 1;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (([NSStringFromClass(otherGestureRecognizer.view.class) isEqualToString:@"WKContentView"] && [NSStringFromClass(gestureRecognizer.view.class) isEqualToString:@"UILayoutContainerView"])) {
        return YES;
    }
    return NO;
}
#pragma mark - navigationDelegate 实现此代理方法也是为防止滑动返回时界面卡死
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //开启滑动手势
    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        navigationController.interactivePopGestureRecognizer.enabled = YES;
        BaseViewController *controller = self.viewControllers.lastObject;
        if ([controller isKindOfClass:[BaseViewController class]]) {
            navigationController.interactivePopGestureRecognizer.enabled = !controller.banBackGestures;
        }
    }
}
+ (void)initialize{
    [self setupBarButtonItemTheme];
}

/**
 *  设置UINavigationBarTheme的主题
 */
- (void)setupNavigationBarTheme{
    UINavigationBar *navigationBar = self.navigationBar;
    // 设置导航栏的样式
    [navigationBar setBarStyle:UIBarStyleDefault];
    //设置导航栏文字按钮的渲染色
    [navigationBar setTintColor:[UIColor whiteColor]];
    // 设置导航栏的背景渲染色
    CGFloat rgb = 0.1;
    [navigationBar setBarTintColor:[UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.65]];
    // 设置文字属性
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:18];
    textAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    // UIOffsetZero是结构体, 只要包装成NSValue对象, 才能放进字典\数组中
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset =  CGSizeZero;
    textAttrs[NSShadowAttributeName] = shadow;
    [navigationBar setTitleTextAttributes:textAttrs];
    /// 去掉导航栏的阴影图片
    [navigationBar setShadowImage:[UIImage new]];
}

/**
 *  设置UIBarButtonItem的主题
 */
+ (void)setupBarButtonItemTheme{
    // 通过appearance对象能修改整个项目中所有UIBarButtonItem的样式
    UIBarButtonItem *appearance = [UIBarButtonItem appearance];
    // 设置普通状态的文字属性
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset =  CGSizeZero;
    textAttrs[NSShadowAttributeName] = shadow;
    [appearance setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    
    // 设置高亮状态的文字属性
    NSMutableDictionary *highTextAttrs = [NSMutableDictionary dictionaryWithDictionary:textAttrs];
    highTextAttrs[NSForegroundColorAttributeName] = [[UIColor whiteColor] colorWithAlphaComponent:.5f];
    [appearance setTitleTextAttributes:highTextAttrs forState:UIControlStateHighlighted];
    
    // 设置不可用状态(disable)的文字属性
    NSMutableDictionary *disableTextAttrs = [NSMutableDictionary dictionaryWithDictionary:textAttrs];
    disableTextAttrs[NSForegroundColorAttributeName] = [[UIColor whiteColor] colorWithAlphaComponent:.5f];
    [appearance setTitleTextAttributes:disableTextAttrs forState:UIControlStateDisabled];
}
#pragma mark - Override

- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return self.topViewController.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden{
    return self.topViewController.prefersStatusBarHidden;
}

@end
