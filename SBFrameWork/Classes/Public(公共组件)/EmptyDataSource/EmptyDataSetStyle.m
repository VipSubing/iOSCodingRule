//
//  EmptyDataSetStyle.m
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/28.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import "EmptyDataSetStyle.h"

@implementation EmptyDataSetStyle
- (instancetype)init{
    if (self = [super init]) {
        _shouldDisplay = YES;
        _allowTouch = YES;
        _allowLoadingAnimation = YES;
        _allowTouchButton = YES;
        _verticalOffset = 0.f;
        _spaceHeight = 11.f;
        _backgroundColor = [UIColor clearColor];
        _loadingUrl = @"loading_imgBlue_78x78";
        _titleColor = [UIColor grayColor];
        _titleFont = [UIFont systemFontOfSize:15];
        _desc = @"";
        _descColor = [UIColor grayColor];
        _descFont = [UIFont systemFontOfSize:13];
    }
    return self;
}
- (void)setIsLoading:(BOOL)isLoading{
    _isLoading = isLoading;
    _allowTouch = _allowTouchButton = !isLoading;
    if (self.updateEmptyLayoutBlock) {
        self.updateEmptyLayoutBlock();
    }
}
- (void)setShouldDisplay:(BOOL)shouldDisplay{
    _shouldDisplay = shouldDisplay;
    if (self.updateEmptyLayoutBlock) {
        self.updateEmptyLayoutBlock();
    }
}

+ (EmptyDataSetStyle *)defaultStyle{
    EmptyDataSetStyle *empty = [EmptyDataSetStyle new];
    return empty;
}
+ (EmptyDataSetStyle *)configEmptyForStyle:(SBPlaceHolderStyle)style{
    EmptyDataSetStyle *empty = nil;
    switch (style) {
        case SBPlaceHolderStyleWithLoading:
            empty = [self loadingStyle];
            break;
        case SBPlaceHolderStyleWithNotData:
            empty = [self notDataStyle];
            break;
        case SBPlaceHolderStyleWithLostNet:
            empty = [self lostNetStyle];
            break;
        case SBPlaceHolderStyleWithError:
            empty = [self errorStyle];
            break;
        default:
            empty = [self defaultStyle];
            break;
    }
    return empty;
}

+ (EmptyDataSetStyle *)loadingStyle{
    EmptyDataSetStyle *style = [EmptyDataSetStyle new];
    style.isLoading = YES;
    style.holdStyle = SBPlaceHolderStyleWithLoading;
    style.title = @"";
    style.spaceHeight = 35;
    style.allowTouch = NO;
    style.allowTouchButton = NO;
    return style;
}
+ (EmptyDataSetStyle *)notDataStyle{
    EmptyDataSetStyle *style = [EmptyDataSetStyle new];
    style.holdStyle = SBPlaceHolderStyleWithNotData;
    style.imgUrl = @"empty_icon";
    style.title = @"还没有数据 ～";
    style.spaceHeight = 30;
    style.allowTouch = NO;
    style.allowTouchButton = NO;
    return style;
}

+ (EmptyDataSetStyle *)lostNetStyle{
    EmptyDataSetStyle *style = [EmptyDataSetStyle new];
    style.holdStyle = SBPlaceHolderStyleWithLostNet;
    style.imgUrl = @"empty_icon";
    style.title = @"网络异常，点击重新连接 ～";
    style.spaceHeight = 20;
    style.buttonImgUrl = @"";
    return style;
}
+ (EmptyDataSetStyle *)errorStyle{
    EmptyDataSetStyle *style = [EmptyDataSetStyle new];
    style.holdStyle = SBPlaceHolderStyleWithError;
    style.imgUrl = @"empty_icon";
    style.title = @"发现异常，点击刷新 ～";
    style.buttonImgUrl = @"";
    return style;
}
@end
