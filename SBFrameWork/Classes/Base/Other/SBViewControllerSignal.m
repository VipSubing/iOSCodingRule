//
//  SBViewControllerSignal.m
//  MVVMFrameWork
//
//  Created by qyb on 2018/5/18.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import "SBViewControllerSignal.h"
@interface SBViewControllerSignal()
@property (nonatomic,strong,readwrite) RACSubject *viewDidLoadSignal;
@property (nonatomic,strong,readwrite) RACSubject *viewDidAppearSignal;
@property (nonatomic,strong,readwrite) RACSubject *viewDidDisappearSignal;
@property (nonatomic,strong,readwrite) RACSubject *viewWillAppearSignal;
@property (nonatomic,strong,readwrite) RACSubject *viewWillDisappearSignal;
//控制器释放信号消失的信号
@property (nonatomic,strong,readwrite) RACSubject *selfDealloc;
@end
@implementation SBViewControllerSignal
- (RACSubject *)viewDidLoadSignal{
    if (_viewDidLoadSignal == nil) {
        _viewDidLoadSignal = [RACSubject subject];
    }
    return _viewDidLoadSignal;
}
- (RACSubject *)viewWillDisappearSignal{
    if (_viewWillDisappearSignal == nil) {
        _viewWillDisappearSignal = [RACSubject subject];
    }
    return _viewDidDisappearSignal;
}
- (RACSubject *)viewWillAppearSignal{
    if (_viewWillAppearSignal == nil) {
        _viewWillAppearSignal = [RACSubject subject];
    }
    return _viewWillAppearSignal;
}
- (RACSubject *)viewDidAppearSignal{
    if (_viewDidAppearSignal == nil) {
        _viewDidAppearSignal = [RACSubject subject];
    }
    return _viewDidAppearSignal;
}
- (RACSubject *)viewDidDisappearSignal{
    if (_viewDidDisappearSignal == nil) {
        _viewDidDisappearSignal = [RACSubject subject];
    }
    return _viewDidDisappearSignal;
}
- (RACSubject *)selfDealloc{
    if (_selfDealloc == nil) {
        _selfDealloc = [RACSubject subject];
    }
    return _selfDealloc;
}

@end
