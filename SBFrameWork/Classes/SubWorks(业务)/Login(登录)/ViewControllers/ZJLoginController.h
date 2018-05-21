//
//  ZJLoginController.h
//  MVVMFrameWork
//
//  Created by qyb on 2018/5/18.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import "BaseViewController.h"

@interface ZJLoginController : BaseViewController
- (instancetype)initWithAccount:(NSString *)account password:(NSString *)password callback:(void(^)(BOOL success,id other))callback;
@end
