//
//  PBTextView.m
//  com.worldEyesCompany.babyhood
//
//  Created by qyb on 16/8/25.
//  Copyright © 2016年 qyb. All rights reserved.
//

#import "SBTextView.h"

@implementation SBTextView
{
    UIColor *p_textColor;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup{
    
    _placeholderColor = [UIColor lightGrayColor];
    p_textColor = self.textColor;
    _isLimitLength = YES;
    _isHolding = YES;
    
//    self.delegate = (id <UITextViewDelegate>)self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startEditing:) name:UITextViewTextDidBeginEditingNotification object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishEditing:) name:UITextViewTextDidEndEditingNotification object:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChange:) name:UITextViewTextDidChangeNotification object:self];
    
}


#pragma mark - Override
//- (void)setIsLimitLength:(BOOL)isLimitLength{
//    _isLimitLength = isLimitLength;
//    if (!isLimitLength && self.delegate == (id <UITextViewDelegate>)self) {
//        self.delegate = nil;
//    }
//}
- (void)setPlaceholder:(NSString *)place{
    _placeholder = place;
    if (_isHolding) {
        [self holdState];
    }
}
- (void)setPlaceholderColor:(UIColor *)color{
    _placeholderColor = color;
    if (_isHolding) {
        [self holdState];
    }
}
- (void)setTextColor:(UIColor *)textColor{
    [super setTextColor:textColor];
    p_textColor = textColor;
}

- (NSString *)text{
    //判断是否是占位字符
    if (self.isHolding) {
        return @"";
    }
    return [super text];
}

- (void)holdState{
    super.text = self.placeholder;
    self.textColor = self.placeholderColor;
}
- (void)nomalState{
    super.text = @"";
    self.textColor = p_textColor;
}

- (NSString *)filterEmojiText{
    NSString *text = [self.class filterEmoji:self.text];
    return text;
}
#pragma mark - notification

- (void)startEditing:(NSNotification *)notification
{
    if (self.isHolding) {
        [self nomalState];
    }
    self.isHolding = NO;
}

- (void)finishEditing:(NSNotification *)notification
{
    if (self.text.length == 0) {
        self.isHolding = YES;
        [self holdState];
    }
}
- (void)textViewDidChange:(NSNotification *)notification{
    if (_isLimitLength && self.text.length > _limitCount) {
        
        if (self.beyondCallback) {
            self.beyondCallback(self);
        }
        //  #这里需要在判断一次 self.text.length > _limitCount 不然会出现奇怪的bug
        if (self.markedTextRange == nil && self.text.length > _limitCount){
            //删枝
            self.text = [self.text substringToIndex:_limitCount];
            [self setNeedsDisplay];
        }
    }
    //回调
    if (_lengthCallback) {
        _lengthCallback(self,self.text.length);
    }
    
}

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    if ([text isEqualToString:@"\n"]) {
//        [textView resignFirstResponder];
//        return NO;
//    }
//    if (range.length == 1) {
//        return YES;
//    }
//    if (_isLimitLength && self.text.length >= _limitCount) {
//        return NO;
//    }
//    return YES;
//}


//过滤表情
+ (NSString *)filterEmoji:(NSString *)text {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        return text;
    }
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                              options:0
                                                                 range:NSMakeRange(0,[text length])
                                                         withTemplate:@""];
    
    return modifiedString;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
