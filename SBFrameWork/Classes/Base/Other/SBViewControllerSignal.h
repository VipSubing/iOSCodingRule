//
//  SBViewControllerSignal.h
//  MVVMFrameWork
//
//  Created by qyb on 2018/5/18.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBViewControllerSignal : NSObject

//控制器视图已经加载的信号
@property (nonatomic,strong,readonly) RACSubject *viewDidLoadSignal;
//控制器视图已经出现的信号
@property (nonatomic,strong,readonly) RACSubject *viewDidAppearSignal;
//控制器视图已经消失的信号
@property (nonatomic,strong,readonly) RACSubject *viewDidDisappearSignal;
//控制器视图即将出现的信号
@property (nonatomic,strong,readonly) RACSubject *viewWillAppearSignal;
//控制器视图即将消失的信号
@property (nonatomic,strong,readonly) RACSubject *viewWillDisappearSignal;
//控制器释放信号消失的信号
@property (nonatomic,strong,readonly) RACSubject *selfDealloc;

@end
