/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "EMAlertView.h"
#import <objc/runtime.h>

#define kTitleFont [UIFont boldSystemFontOfSize:18]
#define kTitleColor [UIColor blackColor]

#define kMessageFont [UIFont systemFontOfSize:15]
#define kMessageColor [UIColor colorWithWhite:0.2 alpha:1]
@interface EMAlertView ()
@end

@implementation EMAlertView

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle{
    EMAlertView *alert = [super alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    
    alert.sTitleColor = kTitleColor;
    alert.sTitleFont = kTitleFont;
    alert.sMessageColor = kMessageColor;
    alert.sMessageFont = kMessageFont;
    return alert;
}
+ (id)alertWithTitle:(NSString *)title message:(NSString *)message
            preferredStyle:(UIAlertControllerStyle)style
         completionBlock:(void (^)(NSUInteger buttonIndex, EMAlertView *alertView))block
       cancelButtonTitle:(NSString *)cancelButtonTitle
       otherButtonTitles:(NSArray *)otherTitles
{
    EMAlertView *alertView = [self alertControllerWithTitle:title message:message preferredStyle:style];
    __weak typeof(alertView) weakAlertView = alertView;
    if (alertView) {
        if (cancelButtonTitle) {
            UIAlertAction *cancle = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                if (block) {
                    block([self alertAction:action indexForAlertView:weakAlertView],weakAlertView);
                }
            }];
            [alertView addAction:cancle];
        }
        if (otherTitles.count) {
            for (NSString *title in otherTitles) {
                UIAlertAction *action = [self alertActionWithTitle:title block:block alertView:weakAlertView];
                [alertView addAction:action];
            }
        }
    }
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (root.presentedViewController) {
        root = root.presentedViewController;
    }
    [root presentViewController:alertView animated:YES completion:nil];
    return alertView;
}

+ (id)showAlertWithTitle:(NSString *)title message:(NSString *)message
          preferredStyle:(UIAlertControllerStyle)style
         completionBlock:(void (^)(NSUInteger buttonIndex, EMAlertView *alertView))block
       cancelButtonTitle:(NSString *)cancelButtonTitle
       otherButtonTitles:(NSString *)otherButtonTitles, ...{
    NSMutableArray *otherTitles = [NSMutableArray array];
    va_list argList;
    if (otherButtonTitles)
    {
        [otherTitles addObject:otherButtonTitles];
        id arg;
        va_start(argList, otherButtonTitles);
        while ((arg = va_arg(argList, id)))
        {
            [otherTitles addObject:arg];
        }
        va_end(argList);
    }
    
    EMAlertView *alertView = [self alertWithTitle:title message:message preferredStyle:style completionBlock:block cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherTitles.copy];
    return alertView;
}
+ (id)showAlertWithTitle:(NSString *)title message:(NSString *)message
         completionBlock:(void (^)(NSUInteger buttonIndex, EMAlertView *alertView))block
       cancelButtonTitle:(NSString *)cancelButtonTitle
       otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    NSMutableArray *otherTitles = [NSMutableArray array];
    va_list argList;
    if (otherButtonTitles)
    {
        [otherTitles addObject:otherButtonTitles];
        id arg;
        va_start(argList, otherButtonTitles);
        while ((arg = va_arg(argList, id)))
        {
            [otherTitles addObject:arg];
        }
        va_end(argList);
    }
    
    EMAlertView *alertView = [self alertWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert completionBlock:block cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherTitles.copy];
    return alertView;
}

+ (void)alertWithMessage:(NSString *)message handle:(dispatch_block_t)block{
    [EMAlertView showAlertWithTitle:nil message:message completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView){
        if (block) {
            block();
        }
    } cancelButtonTitle:@"知道了" otherButtonTitles:nil];
}
+ (UIAlertAction *)alertActionWithTitle:(NSString *)title block:(void (^)(NSUInteger buttonIndex, EMAlertView *alertView))block alertView:(UIAlertController *)alertView{
    if (!title) {
        return nil;
    }
    __weak typeof(alertView) weakAlertView = alertView;
    UIAlertAction *s_action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (block) {
            block([self alertAction:action indexForAlertView:weakAlertView],(id)weakAlertView);
        }
    }];
    return s_action;
}

+ (NSInteger)alertAction:(UIAlertAction *)action indexForAlertView:(UIAlertController *)alertView{
    NSInteger index = 0;
    for (int i = 0; i < alertView.actions.count; i ++) {
        if (action == alertView.actions[i]) {
            index = i;
            break;
        }
    }
    return index;
}
#pragma mark -
- (void)setSTitleColor:(UIColor *)sTitleColor{
    _sTitleColor = sTitleColor;
    if (self.title.length && sTitleColor) {
        NSMutableAttributedString *titleAttribute = [[NSMutableAttributedString alloc] initWithString:self.title];
        [titleAttribute addAttribute:NSForegroundColorAttributeName value:sTitleColor range:NSMakeRange(0, self.title.length)];
        [titleAttribute addAttribute:NSFontAttributeName value:_sTitleFont?_sTitleFont:kTitleFont range:NSMakeRange(0, self.title.length)];
        [self setValue:titleAttribute forKey:@"attributedTitle"];
    }
}
- (void)setSMessageColor:(UIColor *)sMessageColor{
    _sMessageColor = sMessageColor;
    if (self.message.length && sMessageColor) {
        NSMutableAttributedString *messageAttribute = [[NSMutableAttributedString alloc] initWithString:self.message];
        [messageAttribute addAttribute:NSForegroundColorAttributeName value:sMessageColor range:NSMakeRange(0, self.message.length)];
        [messageAttribute addAttribute:NSFontAttributeName value:_sMessageFont?_sMessageFont:kMessageFont range:NSMakeRange(0, self.message.length)];
        [self setValue:messageAttribute forKey:@"attributedMessage"];
    }
}
- (void)setSTitleFont:(UIFont *)sTitleFont{
    _sTitleFont = sTitleFont;
    if (self.title.length && sTitleFont) {
        NSMutableAttributedString *titleAttribute = [[NSMutableAttributedString alloc] initWithString:self.title];
        [titleAttribute addAttribute:NSForegroundColorAttributeName value:_sTitleColor?_sTitleColor:kTitleColor range:NSMakeRange(0, self.title.length)];
        [titleAttribute addAttribute:NSFontAttributeName value:sTitleFont range:NSMakeRange(0, self.title.length)];
        [self setValue:titleAttribute forKey:@"attributedTitle"];
    }
}
- (void)setSMessageFont:(UIFont *)sMessageFont{
    _sMessageFont = sMessageFont;
    if (self.message.length && sMessageFont) {
        NSMutableAttributedString *messageAttribute = [[NSMutableAttributedString alloc] initWithString:self.message];
        [messageAttribute addAttribute:NSForegroundColorAttributeName value:_sMessageColor?_sMessageColor:kMessageColor range:NSMakeRange(0, self.message.length)];
        [messageAttribute addAttribute:NSFontAttributeName value:sMessageFont range:NSMakeRange(0, self.message.length)];
        [self setValue:messageAttribute forKey:@"attributedMessage"];
    }
}
@end

