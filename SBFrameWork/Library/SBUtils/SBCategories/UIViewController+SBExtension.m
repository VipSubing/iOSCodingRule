//
//  UIViewController+SBExtension.m
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/6.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <objc/runtime.h>
#import "UIViewController+SBExtension.h"

@implementation UIViewController (SBExtension)
- (BOOL)isVisible
{
    return (self.isViewLoaded && self.view.window);
}

@end
