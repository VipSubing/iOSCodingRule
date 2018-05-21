//
//  UIView+SBCategpry.h
//  MVVMFrameWork
//
//  Created by qyb on 2018/1/3.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SBCategpry)
//已读 背景颜色
@property (nonatomic) UIColor *sbReadedBackgroundColor;
//已读前景色
@property (nonatomic) UIColor *sbReadedTintColor;
//已读未读服务层
@property (nonatomic) BOOL sbReadServiceLayer;
//允许已读未读操作的子层
@property (nonatomic) NSMutableArray *sbReads;
//是否已读
@property (nonatomic) BOOL sbIsReaded;

//是否允许  已读未读操作
@property (nonatomic) BOOL sbAllowDidRead;

@property (nonatomic) UIColor *sbReadedTextColor;
@end
