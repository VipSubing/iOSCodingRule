//
//  UIImageView+SBUserDisplay.m
//  BossCockpit
//
//  Created by qyb on 2017/9/15.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <objc/runtime.h>
#import "UIImageView+SBUserDisplay.h"
#import "SDWebImageDownloader.h"
#import "SDImageCache.h"
#import "SDWebImageManager.h"
#define ToRad(deg)      ( (M_PI * (deg)) / 180.0 )
#define randomColor(C) [NSArray arrayWithObjects:RGBCOLOR(43, 182, 170),RGBCOLOR(235, 97, 90),RGBCOLOR(97, 137, 156),RGBCOLOR(108, 187, 90),RGBCOLOR(241, 142, 56),RGBCOLOR(250, 190, 0),RGBCOLOR(235, 109, 142),RGBCOLOR(0, 134, 205),RGBCOLOR(121, 107, 175),RGBCOLOR(0, 159, 185), nil][C]

static CALayer *sb_highLightLayer;
static CALayer *sb_circleHighLightLayer;

static void *touch_flag = &touch_flag;
static void *draw_count_flag = &draw_count_flag;
static void *cache_task_flag = &cache_task_flag;
static void *download_task_flag = &download_task_flag;
static void *draw_url_task_flag = &draw_url_task_flag;
static void *draw_name_task_flag = &draw_name_task_flag;

static void *target_flag = &target_flag;
static void *action_flag = &action_flag;

static dispatch_queue_t _acysnQueue;
@implementation UIImageView (SBUserDisplay)


#pragma mark - write  attributes
- (void)setSb_clipsCircle:(BOOL)clipsCircle{
    if (clipsCircle != self.sb_clipsCircle) {
        objc_setAssociatedObject(self, @selector(sb_clipsCircle), @(clipsCircle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self sb_setName:self.sb_name imageUrl:self.sb_url placeHold:nil];
    }
}
- (BOOL)sb_clipsCircle{
    id result = objc_getAssociatedObject(self, @selector(sb_clipsCircle));
    if (!result) {
        return YES;
    }
    return [result boolValue];
}
- (void)setSb_allowClick:(BOOL)allowClick{
    self.userInteractionEnabled = allowClick;
    if (allowClick && !objc_getAssociatedObject(self, touch_flag)) {
        [self addGestureRecognizer:[self pressRecognizer]];
    }
}
- (BOOL)sb_allowClick{
    return self.userInteractionEnabled;
}
- (void)setSb_highlighted:(BOOL)highlighted{
    objc_setAssociatedObject(self, @selector(sb_highlighted), @(highlighted), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)sb_highlighted{
    id result = objc_getAssociatedObject(self, @selector(sb_highlighted));
    if (!result) {
        return YES;
    }
    return [result boolValue];
}
- (void)setSb_namePriority:(BOOL)namePriority{
    objc_setAssociatedObject(self, @selector(sb_namePriority), @(namePriority), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)sb_namePriority{
    id result = objc_getAssociatedObject(self, @selector(sb_namePriority));
    if (!result) {
        return NO;
    }
    return [result boolValue];
}

- (void)setSb_name:(NSString *)sb_name{
    objc_setAssociatedObject(self, @selector(sb_name), sb_name.copy, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)sb_name{
    return [objc_getAssociatedObject(self, @selector(sb_name)) copy];
}

- (void)setSb_url:(NSString *)sb_url{
    objc_setAssociatedObject(self, @selector(sb_url), sb_url.copy, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)sb_url{
    return [objc_getAssociatedObject(self, @selector(sb_url)) copy];
}
- (SBUImageFlagType)imageType{
    return self.image.sb_flagType;
}
- (void)setSb_image:(UIImage *)sb_image{
    if (!sb_image) return;
    self.image = drawCircleWithImage(sb_image,self.bounds.size);
}
- (UIImage *)sb_image{
    return self.image;
}
#pragma mark - write over

+ (void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        const char *label = "com.xqboss.custom.drawName";
        _acysnQueue = dispatch_queue_create(label, DISPATCH_QUEUE_CONCURRENT);
    });
}

#pragma mark - public
- (void)sb_addTarget:(id)target action:(nonnull SEL)action{
    if (!target || !action) {
        return;
    }
    objc_setAssociatedObject(self, target_flag, target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSString *actionName = NSStringFromSelector(action);
    objc_setAssociatedObject(self, action_flag, actionName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (void)sb_setImageUrl:(NSString *)url placeHold:(UIImage *)placeHold{
    [self sb_setName:nil imageUrl:url placeHold:placeHold completedBlock:nil];
}
- (void)sb_setName:(NSString *)name placeHold:(UIImage *)placeHold{
    [self sb_setName:name imageUrl:nil placeHold:placeHold completedBlock:nil];
}
- (void)sb_setImageUrl:(NSString *)url{
    [self sb_setName:nil imageUrl:url placeHold:nil completedBlock:nil];
}
- (void)sb_setName:(NSString *)name{
    [self sb_setName:name imageUrl:nil placeHold:nil completedBlock:nil];
}

- (void)sb_setName:(NSString *)name imageUrl:(NSString *)imageUrl{
    [self sb_setName:name imageUrl:imageUrl placeHold:nil completedBlock:nil];
}

- (void)sb_setName:(NSString *)name imageUrl:(NSString *)imageUrl placeHold:(UIImage *)placeHold{
    [self sb_setName:name imageUrl:imageUrl placeHold:placeHold completedBlock:nil];
}

- (void)sb_setName:(NSString *)name imageUrl:(NSString *)imageUrl placeHold:(UIImage *)placeHold completedBlock:(void(^)(UIImage *image, NSError *error, NSURL *imageURL,NSString *name))completedBlock{
    self.sb_name = name;
    self.sb_url = imageUrl;
    [self _cancleAllTask];
    if (imageUrl.length == 0 && name.length == 0) {
        placeHold.sb_flag = @"";
        placeHold.sb_flagType = SBUImageFlagWithHold;
        self.image = placeHold;
        return;
    }
    
    NSString *cacheKey = [self cacheKeyWithName:name url:imageUrl];
    __weak typeof(self) weak = self;
    if (placeHold && !weak.image){
        placeHold.sb_flag = @"";
        placeHold.sb_flagType = SBUImageFlagWithHold;
        weak.image = placeHold;
    }
    
    NSOperation *cacheOperation = [[SDImageCache sharedImageCache] queryCacheOperationForKey:cacheKey done:^(UIImage * _Nullable cacheImage, NSData * _Nullable data, SDImageCacheType cacheType) {
        //主线程
        if (!weak) return;
        if (cacheImage) {
            cacheImage.sb_flag = @"";
            cacheImage.sb_flagType = SBUImageFlagWithCache;
            if (completedBlock) {
                completedBlock(cacheImage,nil,[NSURL URLWithString:imageUrl],name);
            }
            weak.image = cacheImage;
            [weak setNeedsLayout];
            return;
        }
        
        __block BOOL drawUrlTaskFinish = NO;
        __block BOOL drawNameTaskFinish = NO;
        if (imageUrl.length) {
            id <SDWebImageOperation> operation = [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                if (!weak) return ;
                if (image) {
                    NSOperation *drawTask = [NSOperation new];
                    objc_setAssociatedObject(weak, draw_url_task_flag, drawTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    CGSize size = weak.bounds.size;
                    dispatch_async(_acysnQueue, ^{
                        if (!weak || drawTask.isCancelled) return ;
                        UIImage *drawImage = weak.sb_clipsCircle? drawCircleWithImage(image,size):image;
                        if (weak.sb_namePriority && drawNameTaskFinish) {
                            return;
                        }
                        [[SDImageCache sharedImageCache] storeImage:drawImage imageData:nil
                                                             forKey:cacheKey toDisk:YES completion:nil];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (!weak || drawTask.isCancelled) return ;
                            
                            drawImage.sb_flag = imageUrl;
                            drawImage.sb_flagType = SBUImageFlagWithUrl;
                            if (completedBlock) {
                                completedBlock(drawImage,error,[NSURL URLWithString:imageUrl],nil);
                            }
                            weak.image = drawImage;
                            [weak setNeedsLayout];
                            drawUrlTaskFinish = YES;
                        });
                    });
                }else {
                    if (completedBlock) {
                        completedBlock(nil,error,[NSURL URLWithString:imageUrl],nil);
                    }
                }
            }];
            objc_setAssociatedObject(weak, download_task_flag, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        if (name.length) {
            NSOperation *drawTask = [NSOperation new];
            objc_setAssociatedObject(weak, draw_name_task_flag, drawTask, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            CGSize size = weak.bounds.size;
            dispatch_async(_acysnQueue, ^{
                if (!weak || drawTask.isCancelled) return ;
                UIImage *nameImage = drawNameWithImage(name,size);
                UIImage *drawImage = weak.sb_clipsCircle? drawCircleWithImage(nameImage,size):nameImage;
                if (!weak.sb_namePriority && drawUrlTaskFinish) {
                    return;
                }
                if (![imageUrl hasPrefix:@"http"]) {
                    [[SDImageCache sharedImageCache] storeImage:drawImage imageData:nil
                                                         forKey:cacheKey toDisk:YES completion:nil];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!weak || drawTask.isCancelled) return ;
                    
                    drawImage.sb_flag = name;
                    drawImage.sb_flagType = SBUImageFlagWithName;
                    
                    if (completedBlock) {
                        completedBlock(drawImage,nil,nil,name);
                    }
                    weak.image = drawImage;
                    [weak setNeedsLayout];
                    drawNameTaskFinish = YES;
                });
            });
        }
    }];
    objc_setAssociatedObject(self, cache_task_flag, cacheOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - private
- (UILongPressGestureRecognizer *)pressRecognizer{
    UILongPressGestureRecognizer *press = objc_getAssociatedObject(self, touch_flag);
    if (!press) {
        press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        press.minimumPressDuration = 0.02f;
        objc_setAssociatedObject(self, touch_flag, press, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return press;
}

- (void)_cancleAllTask{
    NSOperation *cacheOperation = objc_getAssociatedObject(self, cache_task_flag);
    if (cacheOperation) {
        [cacheOperation cancel];
    }
    id <SDWebImageOperation> operation = objc_getAssociatedObject(self, download_task_flag);
    if (operation) {
        [operation cancel];
    }
    NSOperation *draw_url_operation = objc_getAssociatedObject(self, draw_url_task_flag);
    if (draw_url_operation) {
        [draw_url_operation cancel];
    }
    NSOperation *draw_name_operation = objc_getAssociatedObject(self, draw_name_task_flag);
    if (draw_name_operation) {
        [draw_name_operation cancel];
    }
}

- (NSString *)cacheKeyWithName:(NSString *)name url:(NSString *)url
{
    if (!name.length) {
        name = @"#";
    }
    if (!url.length) {
        url = @"#";
    }
    //裁剪
    char circle = self.sb_clipsCircle?'c':'n';
    char priority = self.sb_namePriority?'n':'u';
    return [[NSString stringWithFormat:@"%@_%c%c_",name,circle,priority] stringByAppendingString:url];
}

- (void)autoIncrement{
    int inc = [objc_getAssociatedObject(self, draw_count_flag) intValue];
    inc ++;
    objc_setAssociatedObject(self, draw_count_flag, @(inc), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (int)currentDrawCount{
    return [objc_getAssociatedObject(self, draw_count_flag) intValue];
}
#pragma mark - touch
- (void)longPressAction:(UILongPressGestureRecognizer *)longPress{
    UIView *self_item = longPress.view;
    if (longPress.state == UIGestureRecognizerStateBegan) {
        if (self.sb_highlighted) {
            [self.layer addSublayer:[self sb_highLightLayer]];
        }
    }else if (longPress.state == UIGestureRecognizerStateCancelled || longPress.state == UIGestureRecognizerStateFailed){
        CALayer *layer = [self sb_highLightLayer];
        if (layer.superlayer == self.layer) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1f*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [layer removeFromSuperlayer];
            });
        }
    }else if (longPress.state == UIGestureRecognizerStateEnded){
        
        CALayer *layer = [self sb_highLightLayer];
        if (layer.superlayer == self.layer) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1f*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [layer removeFromSuperlayer];
            });
        }
        
        CGPoint point = [longPress locationInView:self];
        CGPoint sb_point = [self convertPoint:point toView:self_item];
        if (sb_point.x>=0 && sb_point.x<=self_item.bounds.size.width && sb_point.y>=0 && sb_point.y<=self_item.bounds.size.height)
        {
            if ([self sb_highLightLayer].superlayer == self.layer || ![self sb_highLightLayer].superlayer) {
                SEL sel = NSSelectorFromString(objc_getAssociatedObject(self, &action_flag));
                id target = objc_getAssociatedObject(self, &target_flag);
                if (sel && target) {
                    if ([target respondsToSelector:sel]) {
                        [target performSelector:sel withObject:self];
                    }else NSAssert(NO, @"%@ responds the sel:%@",target,NSStringFromSelector(sel));
                }
            }
        }
    }
}


- (CALayer *)sb_highLightLayer{
    CALayer *layer = nil;
    if (self.sb_clipsCircle) {
        //圆形裁剪
        if (!sb_circleHighLightLayer) {
            sb_circleHighLightLayer = [[CALayer alloc] init];
            sb_circleHighLightLayer.frame = self.bounds;
            sb_circleHighLightLayer.contents = (id)drawCircleWithImage(highLightImage(self.bounds.size),self.bounds.size).CGImage;
        }
        layer = sb_circleHighLightLayer;
    }else {
        //未裁剪
        if (!sb_highLightLayer) {
            sb_highLightLayer = [[CALayer alloc] init];
            sb_highLightLayer.frame = self.bounds;
            sb_highLightLayer.contents = highLightImage(self.bounds.size).CIImage;
        }
        layer = sb_highLightLayer;
    }
    return layer;
}
#pragma mark - draw
static inline UIImage * highLightImage(CGSize size){
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *color = [UIColor colorWithRed:140.f/255.f green:140.f/255.f blue:140.f/255.f alpha:0.65];
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    CGContextSetFillColorWithColor(context, color.CGColor);
    UIImage *highLightImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return highLightImage;
}
static inline UIImage * drawCircleWithImage(UIImage *image,CGSize size){
    
    CGRect circleRect = (CGRect) {CGPointZero, size};
    UIGraphicsBeginImageContextWithOptions(circleRect.size, NO, 0);
    UIBezierPath *circle = [UIBezierPath bezierPathWithRoundedRect:circleRect cornerRadius:circleRect.size.width/2];
    [circle addClip];
    [image drawInRect:circleRect];
    circle.lineWidth = 1;
    [[UIColor whiteColor] set];
    [circle stroke];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return roundedImage;
}
static inline UIImage *drawNameWithImage(NSString *name,CGSize size){
    if (name.length == 0) {
        return nil;
    }
    if (name.length > 2) {
        name = [name substringFromIndex:name.length-2];
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    int rand = defineHash(name);
    UIColor *color = randomColor(rand);
    [color set];
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    UIFont *font = [UIFont boldSystemFontOfSize:17];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.alignment = NSTextAlignmentCenter;;
    [name drawInRect:CGRectMake(0, (size.height-font.lineHeight)/2, size.width, font.lineHeight) withAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle}];
    UIImage *singleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return singleImage;
}
static inline int defineHash(NSString *name){
    if (!name.length) {
        return 0;
    }
    NSMutableString *pName = [name mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pName, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pName, NULL, kCFStringTransformStripCombiningMarks, NO);
    name = [pName uppercaseString].copy;
    int index = 0;
    int result = 0;
    while (index<name.length) {
        char c = [name characterAtIndex:index];
        result += c;
        index ++;
    }
    
    return result%10;
}
@end

