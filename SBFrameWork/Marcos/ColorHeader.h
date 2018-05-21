//
//  ColorHeader.h
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/6.
//  Copyright © 2017年 qyb. All rights reserved.
//

#ifndef ColorHeader_h
#define ColorHeader_h

#import "UIColor+SBCategpry.h"
/* Color  Enumeration  */

//标准
#define StandardDefaultColor ColorFromHexString(@"#044893")
//标题
#define TitleDefaultColor ColorFromHexString(@"#333333")
//正文
#define ContentDefaultColor ColorFromHexString(@"#7d828a")
//描述
#define DescDefaultColor ColorFromHexString(@"#aaacfa")

//橙色
#define OrangeDefaultColor ColorFromHexString(@"#ff9600")
//浅灰
#define ShallowGayDefaultColor ColorFromHexString(@"#e5e5e5")
//背景
#define BackgroundDefaultColor ColorFromHexString(@"#f5f5f5")
//褐色
#define BrownnessDefaultColor ColorFromHexString(@"#d0b66a")

// 颜色(RGB)
#define RGBCOLOR(r, g, b)       [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r, g, b, a)   [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
// RGB颜色转换（16进制->10进制）
#define UIColorFromRGB(rgbValue)\
\
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]
#define UIColorFromRGBA(rgbValue, a)\
\
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:a]

/// 根据hex 获取颜色
#define ColorFromHexString(__hexString__) ([UIColor colorFromHexString:__hexString__])

#endif /* ColorHeader_h */
