//
//  UIColor+SBCategpry.h
//  MVVMFrameWork
//
//  Created by qyb on 2018/5/20.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (SBCategpry)
+ (UIColor *)colorFromHexString:(NSString *)color;

//从十六进制字符串获取颜色，
//color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)colorFromHexString:(NSString *)color alpha:(CGFloat)alpha; 
@end
