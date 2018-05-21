//
//  OSSPutObjectRequest+SBFree.m
//  www.qyb.QuanYouBaoParents
//
//  Created by qyb on 2017/8/2.
//  Copyright © 2017年 qyb. All rights reserved.
//
#import <objc/runtime.h>
#import "OSSPutObjectRequest+SBFree.h"

@implementation OSSPutObjectRequest (SBFree)
- (NSString *)endpoint{
    return objc_getAssociatedObject(self, _cmd);
}
- (void)setEndpoint:(NSString *)endpoint{
    if (endpoint.length == 0) endpoint = @"";
    objc_setAssociatedObject(self, @selector(endpoint), endpoint, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSUInteger)flag{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}
- (void)setFlag:(NSUInteger)flag{
    objc_setAssociatedObject(self, @selector(flag), @(flag), OBJC_ASSOCIATION_COPY_NONATOMIC);
}
@end
