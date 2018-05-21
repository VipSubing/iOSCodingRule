//
//  UIView+SBCategpry.m
//  MVVMFrameWork
//
//  Created by qyb on 2018/1/3.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import <objc/runtime.h>
#import "UIView+SBCategpry.h"

@implementation UIView (SBCategpry)

- (void)setSbReadedTintColor:(UIColor *)sbReadedTintColor{
    objc_setAssociatedObject(self, @selector(sbReadedTintColor), sbReadedTintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIColor *)sbReadedTintColor{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setSbReadedBackgroundColor:(UIColor *)sbReadedBackgroundColor{
    objc_setAssociatedObject(self, @selector(sbReadedBackgroundColor), sbReadedBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIColor *)sbReadedBackgroundColor{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setSbIsReaded:(BOOL)sbIsReaded{
    //相同状态退出
    if (self.sbIsReaded == sbIsReaded && self.sbAllowDidRead) return;
    
    //修改子集状态
    if (self.sbReadServiceLayer)
    [self _setViewsReadStatus:sbIsReaded];
    
    //修改自身状态
    if(self.sbAllowDidRead && self.sbIsReaded != sbIsReaded) {
        objc_setAssociatedObject(self, @selector(sbIsReaded), @(sbIsReaded), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        id temp = self.sbReadedBackgroundColor;
        if (temp) {
            self.sbReadedBackgroundColor = self.backgroundColor;
            self.backgroundColor = temp;
        }
        
        temp = self.sbReadedTintColor;
        if (temp) {
            self.sbReadedTintColor = self.tintColor;
            self.tintColor = temp;
        }
        if ([self isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)self;
            id temp = self.sbReadedTextColor;
            if (temp) {
                self.sbReadedTextColor = label.textColor;
                label.textColor = temp;
            }
        }
    }
}

- (BOOL)sbIsReaded{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
- (void)setSbAllowDidRead:(BOOL)sbAllowDidRead{
    objc_setAssociatedObject(self, @selector(sbAllowDidRead), @(sbAllowDidRead), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (sbAllowDidRead) {
        
        UIView * readView = self.superview;
        //不为为服务层 或者 有父视图  则继续 while
        while (!readView.sbReadServiceLayer && readView) {
            readView = readView.superview;
        }
        if (readView.sbReadServiceLayer) {
            if (![readView.sbReads containsObject:self]) {
                [readView.sbReads addObject:self];
            }
        }
    }
}
- (BOOL)sbAllowDidRead{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setSbReads:(NSMutableArray *)sbReads{
    objc_setAssociatedObject(self, @selector(sbReads), sbReads, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableArray *)sbReads{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setSbReadServiceLayer:(BOOL)sbReadServiceLayer{
    objc_setAssociatedObject(self, @selector(sbReadServiceLayer), @(sbReadServiceLayer), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.sbReads == nil && sbReadServiceLayer) {
        self.sbReads = [NSMutableArray new];
    }
}
- (BOOL)sbReadServiceLayer{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)_setViewsReadStatus:(BOOL)readed{
    for (UIView *view in self.sbReads) {
        view.sbIsReaded = readed;
    }
}
- (void)setSbReadedTextColor:(UIColor *)sbReadedTextColor{
    objc_setAssociatedObject(self, @selector(sbReadedTextColor), sbReadedTextColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIColor *)sbReadedTextColor{
    return objc_getAssociatedObject(self, _cmd);
}
@end
