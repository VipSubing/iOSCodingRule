//
//  BaseViewController.h
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/6.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBViewControllerSignal.h"
//返回类型
typedef NS_ENUM(NSInteger,BaseNaviGationBackType) {
    BaseNaviGationBackWithPopAndDiss,
    BaseNaviGationBackWithPop,
    BaseNaviGationBackWithDiss
};

typedef NS_ENUM(NSInteger,SBNavigationTransitionType) {
    SBNavigationTransitionWithPresent, //模态跳转
    SBNavigationTransitionWithPush, //Push
    SBNavigationTransitionWithDissmiss, //dissmiss
    SBNavigationTransitionWithPop, //POP
    SBNavigationTransitionWithRoot, //keyWindow.root
};

@interface BaseViewController : UIViewController
//是否禁止侧滑
@property (nonatomic,assign) BOOL banBackGestures;
//是否需要返回按钮
@property (assign,nonatomic) BOOL hideBack;
//hide Navigation  Default NO
@property (assign,nonatomic) BOOL hideNavigation;
//回调block
@property (copy,nonatomic) void(^baseCallback)(id data);

//返回对应的动画类型 pop dissmiss all Deafults BaseNaviGationBackWithPopAndDiss
@property (assign,nonatomic) BaseNaviGationBackType naviBackType;

//viewcontroller life cycle signal
@property (nonatomic) SBViewControllerSignal *cSignal;
// 是否正在显示
@property (nonatomic,readonly) BOOL isVisible;
//对象初始化后调用方法
- (void)objectInitialized;

@end
