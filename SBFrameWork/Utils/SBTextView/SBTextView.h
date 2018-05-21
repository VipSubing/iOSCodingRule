//
//  PBTextView.h
//  com.worldEyesCompany.babyhood
//
//  Created by bayi on 16/8/25.
//  Copyright © 2016年 bayi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBTextView : UITextView
/** 占位文字  */
@property (nonatomic, copy) NSString *placeholder;
/** 占位文字颜色*/
@property (nonatomic, strong) UIColor *placeholderColor;

//是否是占位状态
@property (nonatomic) BOOL isHolding;
//是否限制输入长度  默认YES
@property (nonatomic) BOOL isLimitLength;
//限制的字符长度
@property (assign,nonatomic) NSUInteger limitCount;
//text 变化回调
@property (copy,nonatomic) void (^lengthCallback)(SBTextView *textView,NSInteger length);
//超出最大限制 回调
@property (copy,nonatomic) void (^beyondCallback)(SBTextView *textView);

//过滤掉表情的text
@property (copy,nonatomic) NSString *filterEmojiText;


@end
