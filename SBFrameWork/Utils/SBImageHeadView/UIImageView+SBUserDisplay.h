//
//  UIImageView+SBUserDisplay.h
//  BossCockpit
//
//  Created by qyb on 2017/9/15.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+SBFlag.h"

@interface UIImageView (SBUserDisplay)
@property (strong,nonatomic) UIImage *sb_image;
//Defaulst YES 自动裁圆
@property (assign,nonatomic) BOOL sb_clipsCircle;//设置是否自动修剪成圆形，默认YES
//Defaulst NO 允许点击
@property (assign,nonatomic) BOOL sb_allowClick;
//Defaulst YES  点击高亮
@property (assign,nonatomic) BOOL sb_highlighted;
//Defaulst NO  name image 优先
@property (assign,nonatomic) BOOL sb_namePriority;//设置name 和 url 显示优先级别，如果味YES 那么在http图片和name 图片同时存在的情况下 会选择显示 name
//name
@property (copy,nonatomic,readonly) NSString *sb_name;
//imageUrl
@property (copy,nonatomic,readonly) NSString *sb_url;
//Image 类型
@property (assign,nonatomic,readonly) SBUImageFlagType imageType;


/**
 添加事件响应  需要 sb_allowClick = YES

 @param target target
 @param action sel
 */
- (void)sb_addTarget:(id)target action:(SEL)action;
/**
 设置 name url 赞位图 通过 sb_namePriority 判断最终显示哪个
 
 @param name name
 @param imageUrl http url
 @param placeHold 赞位图
 @param completedBlock 回调
 */
- (void)sb_setName:(NSString *)name imageUrl:(NSString *)imageUrl placeHold:(UIImage *)placeHold completedBlock:(void(^)(UIImage *image, NSError *error, NSURL *imageURL,NSString *name))completedBlock;

/**
 设置 name url 赞位图 通过 sb_namePriority 判断最终显示哪个
 
 @param name name
 @param imageUrl http url
 @param placeHold 赞位图
 */
- (void)sb_setName:(NSString *)name imageUrl:(NSString *)imageUrl placeHold:(UIImage *)placeHold;
/**
 设置图片url

 @param url http url
 @param placeHold 赞位图
 */
- (void)sb_setImageUrl:(NSString *)url placeHold:(UIImage *)placeHold;

/**
 设置名字 name

 @param name name
 @param placeHold 赞位图
 */
- (void)sb_setName:(NSString *)name placeHold:(UIImage *)placeHold;

/**
 设置 图片url

 @param url http url
 */
- (void)sb_setImageUrl:(NSString *)url;

/**
 设置name

 @param name name
 */
- (void)sb_setName:(NSString *)name;

/**
 设置name 和 url  通过 sb_namePriority 判断最终显示哪个

 @param name name
 @param imageUrl http url
 */
- (void)sb_setName:(NSString *)name imageUrl:(NSString *)imageUrl;


@end
