//
//  EmptyDataSetStyle.h
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/28.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,SBPlaceHolderStyle) {
    SBPlaceHolderStyleWithLoading = -1,//正在加载状态
    SBPlaceHolderStyleWithOther = 0, //默认其他
    SBPlaceHolderStyleWithLostNet,  //丢失网络
    SBPlaceHolderStyleWithNotData,  //没有数据
    SBPlaceHolderStyleWithError    //错误
};
@interface EmptyDataSetStyle : NSObject

/*   control  */

//是否显示 //Default YES
@property (assign,nonatomic) BOOL shouldDisplay;
//是否正在加载
@property (assign,nonatomic) BOOL isLoading;
//是否允许点击button 默认 YES
@property (assign,nonatomic) BOOL allowTouchButton;
//允许加载动画 default YES
@property (assign,nonatomic) BOOL allowLoadingAnimation;
//是否允许点击  Default YES
@property (assign,nonatomic) BOOL allowTouch;
//是否允许滑动 默认 NO
@property (assign,nonatomic) BOOL allowScroll;
//loading
//加载 img url
@property (copy,nonatomic) NSString *loadingUrl;
/*  style  */
//占位状态 类型
@property (assign,nonatomic) SBPlaceHolderStyle holdStyle;
// title
@property (copy,nonatomic) NSString *title;
@property (strong,nonatomic) UIColor *titleColor;
@property (strong,nonatomic) UIFont *titleFont;
//desc
@property (copy,nonatomic) NSString *desc;
@property (strong,nonatomic) UIColor *descColor;
@property (strong,nonatomic) UIFont *descFont;
// img
@property (copy,nonatomic) NSString *imgUrl;

@property (strong,nonatomic) UIColor *imgTintColor;

//button
@property (copy,nonatomic) NSString *buttonImgUrl;

@property (copy,nonatomic) NSString *buttonBackgroundImgUrl;



@property (strong,nonatomic) UIColor *backgroundColor;

@property (assign,nonatomic) CGFloat verticalOffset;

@property (assign,nonatomic) CGFloat spaceHeight;

//默认
+ (EmptyDataSetStyle *)defaultStyle;

+ (EmptyDataSetStyle *)configEmptyForStyle:(SBPlaceHolderStyle)style;

@property (copy,nonatomic) void (^updateEmptyLayoutBlock)(void);
@end
