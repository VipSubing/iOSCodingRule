//
//  UIImage+SBFlag.m
//  BossCockpit
//
//  Created by qyb on 2017/9/20.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import "UIImage+SBFlag.h"
#import <objc/runtime.h>
@implementation UIImage (SBFlag)
- (void)setSb_flag:(NSString *)flag{
    objc_setAssociatedObject(self, @selector(sb_flag), flag.copy, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)sb_flag{
    id result = [objc_getAssociatedObject(self, @selector(sb_flag)) copy];
    return result;
}
- (void)setSb_flagType:(SBUImageFlagType)flagType{
    objc_setAssociatedObject(self, @selector(sb_flagType), @(flagType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (SBUImageFlagType)sb_flagType{
    id result = objc_getAssociatedObject(self, @selector(sb_flagType));
    if (!result) {
        return SBUImageFlagWithHold;
    }
    return (SBUImageFlagType)[result integerValue];
}
- (void)setSb_circle:(BOOL)circle{
    objc_setAssociatedObject(self, @selector(sb_circle), @(circle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)sb_circle{
    id result = objc_getAssociatedObject(self, @selector(sb_circle));
    if (!result) {
        return NO;
    }
    return [result boolValue];
}
@end
