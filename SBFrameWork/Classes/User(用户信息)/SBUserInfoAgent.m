//
//  SBUserInfoAgent.m
//  MVVMFrameWork
//
//  Created by qyb on 2018/1/2.
//  Copyright © 2018年 qyb. All rights reserved.
//

#import "SBUserInfoAgent.h"
#import "SBFileManager.h"
//password keychain path
NSString *const kSBUserInfoAgentAccountKey = @"kSBUserInfoAgentAccountKey";
//当前用户更换通知
NSString *const kSBUserInfoCurrentUserChangeNotification = @"kSBUserInfoCurrentUserChangeNotification";
//用户信息改变通知
NSString *const kSBUserInfoValueChangeNotification = @"kSBUserInfoValueChangeNotification";
//获取通知中的信 keypath
NSString *const kSBUserInfoNotificationKeyPath = @"kSBUserInfoNotificationKeyPath";

//获取通知中的信 vaule  就是 userinfo 自己
NSString *const kSBUserInfoNotificationValue = @"kSBUserInfoNotificationValue";

static NSString *const UserInfoFileKey = @"userInfo";

static SBFileItem *fileItem;

@implementation SBUserInfoAgent
@dynamic password;
+ (void)initialize{
    fileItem = [[SBFileManager fileManager] fileItemForName:UserInfoFileKey];
}

+ (SBUserInfoAgent *)shareInfo{
    static SBUserInfoAgent *user = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        user = [[SBUserInfoAgent alloc] initWithFilePath:fileItem.path];
    });
    return user;
}
- (SBUserInfoAgent *)resetForJson:(id)json{
    SBUserInfoAgent *userInfo = [self initWithDictionary:json];
    //提交修改
    [userInfo commit];
    //发出通知
    [userInfo postCurrentUserChangeNotification];
    return userInfo;
}
- (void)commit{
    [self shouldSerialization];
}
- (instancetype)initWithFilePath:(NSString *)filePath{
    self = [super init];
    id object = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    if (object) {
        self = object;
    }
    if (self) {
        [self addObserve];
    }
    return self;
}

- (void)shouldSerialization{
    [NSKeyedArchiver archiveRootObject:self toFile:fileItem.path];
}
#pragma mark - Observe And Notification
- (void)postCurrentUserChangeNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSBUserInfoCurrentUserChangeNotification object:nil];
}
- (void)addObserve{
    @weakify(self);
    [[RACObserve(self,userId) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self postValueChangeNotificationWithKey:@"userId" value:x];
    }];
    [[RACObserve(self,userName) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self postValueChangeNotificationWithKey:@"userName" value:x];
    }];
    [[RACObserve(self,mobileCode) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self postValueChangeNotificationWithKey:@"mobileCode" value:x];
    }];
}
- (void)postValueChangeNotificationWithKey:(NSString *)key value:(id)value{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSBUserInfoValueChangeNotification object:nil userInfo:@{kSBUserInfoNotificationKeyPath:key,kSBUserInfoNotificationValue:self}];
}
#pragma mark - atrributes
- (NSString *)password{
    return [SSKeychain passwordForService:kSBUserInfoAgentAccountKey account:_mobileCode];
}
- (void)setPassword:(NSString *)password{
    [SSKeychain setPassword:password forService:kSBUserInfoAgentAccountKey account:_mobileCode];
}
@end
