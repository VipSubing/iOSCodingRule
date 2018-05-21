//
//  UIImage+SBFlag.h
//  BossCockpit
//
//  Created by qyb on 2017/9/20.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,SBUImageFlagType){
    SBUImageFlagWithHold = 0,//暂位图
    SBUImageFlagWithName = 1,//名字
    SBUImageFlagWithUrl = 2,//http url
    SBUImageFlagWithCache = 3,//cache
};

@interface UIImage (SBFlag)
@property (copy,nonatomic) NSString *sb_flag;
@property (assign,nonatomic) SBUImageFlagType sb_flagType;
@property (assign,nonatomic) BOOL sb_circle;
@end
