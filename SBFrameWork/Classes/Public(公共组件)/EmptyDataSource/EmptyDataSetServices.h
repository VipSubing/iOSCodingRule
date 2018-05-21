//
//  EmptyDataSetServices.h
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/28.
//  Copyright © 2017年 qyb. All rights reserved.
//
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <Foundation/Foundation.h>
#import "EmptyDataSetStyle.h"


@interface EmptyDataSetServices : NSObject<DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (nonatomic,readonly) EmptyDataSetStyle *style;

//配置占位状态 通过style
- (void)configEmptyForStyle:(SBPlaceHolderStyle)style;

@property (copy,nonatomic) void (^didEmptyViewBlock)(UIScrollView *scrollView,UIView *tapView);

@property (copy,nonatomic) void (^didTouchButtonBlock)(UIScrollView *scrollView,UIButton *button);

@property (copy,nonatomic) void (^updateEmptyLayoutBlock)(void);
@end
