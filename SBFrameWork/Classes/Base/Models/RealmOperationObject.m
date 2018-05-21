//
//  RealmOperationObject.m
//  MVVMFrameWork
//
//  Created by qyb on 2018/1/2.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import "RealmOperationObject.h"

#define kDefaultOperationQueue [self.class defaultQueue]

@implementation RealmOperationObject

+ (dispatch_queue_t)defaultQueue{
    static dispatch_queue_t queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.realm.default.sb", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}
@end
