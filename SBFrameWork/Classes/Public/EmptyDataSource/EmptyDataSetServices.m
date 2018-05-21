//
//  EmptyDataSetServices.m
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/28.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import "EmptyDataSetServices.h"
@interface EmptyDataSetServices()
@property (nonatomic,readwrite) EmptyDataSetStyle *style;
@end
@implementation EmptyDataSetServices

#pragma mark - config
- (void)configEmptyForStyle:(SBPlaceHolderStyle)style{
    self.style = [EmptyDataSetStyle configEmptyForStyle:style];
    self.style.updateEmptyLayoutBlock = self.updateEmptyLayoutBlock;
    if (self.style.updateEmptyLayoutBlock) {
        self.style.updateEmptyLayoutBlock();
    }
}
- (void)setUpdateEmptyLayoutBlock:(void (^)(void))updateEmptyLayoutBlock{
    _updateEmptyLayoutBlock = [updateEmptyLayoutBlock copy];
    self.style.updateEmptyLayoutBlock = _updateEmptyLayoutBlock;
}
#pragma mark - delegate

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    return [[NSAttributedString alloc] initWithString:self.style.title attributes:@{NSFontAttributeName:self.style.titleFont,NSForegroundColorAttributeName:self.style.titleColor}];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView{
    return [[NSAttributedString alloc] initWithString:self.style.desc attributes:@{NSFontAttributeName:self.style.descFont,NSForegroundColorAttributeName:self.style.descColor}];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView{
    if (self.style.isLoading) {
        return [UIImage imageNamed:self.style.loadingUrl];
    }
    return [UIImage imageNamed:self.style.imgUrl];
}

- (UIColor *)imageTintColorForEmptyDataSet:(UIScrollView *)scrollView{
    return self.style.imgTintColor;;
}
- (CAAnimation *)imageAnimationForEmptyDataSet:(UIScrollView *)scrollView
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D: CATransform3DMakeRotation(M_PI_2, 0.0, 0.0, 1.0) ];
    animation.duration = 0.25;
    animation.cumulative = YES;
    animation.repeatCount = MAXFLOAT;
    
    return animation;
}
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return self.style.allowScroll;
}

- (BOOL)emptyDataSetShouldAnimateImageView:(UIScrollView *)scrollView
{
    return self.style.allowLoadingAnimation && self.style.isLoading;
}
- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView{
    return self.style.backgroundColor;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView{
    return self.style.verticalOffset;
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView{
    return self.style.spaceHeight;
}
- (UIImage *)buttonImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state{
    return [UIImage imageNamed:self.style.buttonImgUrl];
}

- (UIImage *)buttonBackgroundImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state{
    return [UIImage imageNamed:self.style.buttonBackgroundImgUrl];
}

#pragma mark -
- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button{
    if (self.style.allowTouchButton && _didTouchButtonBlock) {
        _didTouchButtonBlock(scrollView,button);
    }
}

#pragma mark -
- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view{
    if (self.style.allowTouch && _didEmptyViewBlock) {
        _didEmptyViewBlock(scrollView,view);
    }
}
- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView{
    return self.style.allowTouch;
}
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView{
    return self.style.shouldDisplay;
}
@end
