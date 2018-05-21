//
//  RealmOperationObject.h
//  MVVMFrameWork
//
//  Created by qyb on 2018/1/2.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import <Realm/Realm.h>

#define RealmDefaultOperationQueue [self.class defaultQueue]

@interface RealmOperationObject : RLMObject
+ (dispatch_queue_t)defaultQueue;
@end
