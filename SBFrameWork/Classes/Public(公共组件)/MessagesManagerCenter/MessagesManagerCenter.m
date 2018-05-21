//
//  MessagesManagerCenter.m
//  园长版
//
//  Created by qyb on 2017/11/13.
//  Copyright © 2017年 qyb. All rights reserved.
//
#import <libkern/OSAtomic.h>
#import "MessagesManagerCenter.h"

@interface MessageCountSuperUnit()
//消息总数
@property (assign,nonatomic,readwrite) int32_t totalCount;
@end

@implementation MessageCountSuperUnit
{
    dispatch_semaphore_t _lock;
}
- (instancetype)init{
    if (self = [super init]) {
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}
#pragma mark - public
- (void)increment{
    OSAtomicIncrement32(&_totalCount);
    [self callBindBlock];
}
- (void)decrement{
    OSAtomicDecrement32(&_totalCount);
    if (_totalCount < 0) {
        OSAtomicIncrement32(&_totalCount);
    }
    [self callBindBlock];
}
- (void)clearToZero{
    NSInteger old = _totalCount;
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    _totalCount = 0;
    dispatch_semaphore_signal(_lock);
    if (old != _totalCount) {
        [self callBindBlock];
    }
}
- (void)updateTotalCount{
    if (_totalEvent) {
        __weak typeof(self) weak = self;
        _totalEvent(^(NSInteger count){
            dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
            weak.totalCount = (int32_t)count;
            dispatch_semaphore_signal(_lock);
            [weak callBindBlock];
        });
    }
}
#pragma mark - private
- (void)callBindBlock{
    if (_bindMessageBlock) {
        dispatch_main_async_safe(^{
            _bindMessageBlock(_totalCount);
        });
    }
}
@end
static char *const queuelabel = "com.sb.message";
@interface MessagesManagerCenter()

@end
@implementation MessagesManagerCenter
+ (MessagesManagerCenter *)managerCenter{
    static MessagesManagerCenter *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [MessagesManagerCenter new];
    });
    return manager;
}
- (dispatch_queue_t)asyncQueue{
    if (!_asyncQueue) {
        _asyncQueue = dispatch_queue_create(queuelabel, DISPATCH_QUEUE_SERIAL);
    }
    return _asyncQueue;
}
- (instancetype)init{
    if (self = [super init]) {
        _units = [self setupUnits];
    }
    return self;
}
- (NSArray *)setupUnits{
    NSMutableArray *units = [NSMutableArray new];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (int i = 0; i < outCount; i ++) {
        objc_property_t property = properties[i];
        const char* char_f = property_getName(property);
        NSLog(@"%s",char_f);
        NSString *name = [[NSString alloc] initWithUTF8String:char_f];;
        id propertyValue = [self valueForKey:(NSString *)name];
        if ([propertyValue isKindOfClass:[MessageCountSuperUnit class]]) {
            [units addObject:propertyValue];
        }
        
    }
    free(properties);
    return units.copy;
}
#pragma mark - utils

- (void)refreshAllMessage{
    for (MessageCountSuperUnit *unit in self.units) {
        [unit updateTotalCount];
    }
}
+ (void)updateTSMessageCountWithIds:(NSString *)ids onTable:(NSString *)table{
    if (ids.length == 0 && table.length == 0) {
        return;
    }
    dispatch_async([MessagesManagerCenter managerCenter].asyncQueue, ^{
        [TSMessageModel updateReadDate:[NSDate date] forKey:ids completedBlock:^(BOOL success) {
            if (!success) {
                return;
            }
            if ([table isEqualToString:kTSSchoolNewsTable]) {
                [[MessagesManagerCenter managerCenter].schoolMessage decrement];
            }else if ([table isEqualToString:kTSLiveNewsTable]){
                [[MessagesManagerCenter managerCenter].liveOnlineMessage decrement];
            }else if ([table isEqualToString:kTSTeacherSignNewsTable]){
                [[MessagesManagerCenter managerCenter].teacherShiftMessage decrement];
            }
        }];
    });
}

#pragma mark - lazy init
- (MessageCountSuperUnit *)platformMessage{
    if (_platformMessage == nil) {
        _platformMessage = [MessageCountSuperUnit new];
    }
    return _platformMessage;
}
- (MessageCountSuperUnit *)systemMessage{
    if (_systemMessage == nil) {
        _systemMessage = [MessageCountSuperUnit new];
    }
    return _systemMessage;
}
- (MessageCountSuperUnit *)schoolMessage{
    if (_schoolMessage == nil) {
        _schoolMessage = [MessageCountSuperUnit new];
    }
    return _schoolMessage;
}

- (MessageCountSuperUnit *)homeBradgeMessage{
    if (_homeBradgeMessage == nil) {
        _homeBradgeMessage = [MessageCountSuperUnit new];
    }
    return _homeBradgeMessage;
}
- (MessageCountSuperUnit *)liveOnlineMessage{
    if (_liveOnlineMessage == nil) {
        _liveOnlineMessage = [MessageCountSuperUnit new];
    }
    return _liveOnlineMessage;
}
- (MessageCountSuperUnit *)teacherShiftMessage{
    if (_teacherShiftMessage == nil) {
        _teacherShiftMessage = [MessageCountSuperUnit new];
    }
    return _teacherShiftMessage;
}
- (MessageCountSuperUnit *)childBirthdayMessage{
    if (_childBirthdayMessage == nil) {
        _childBirthdayMessage = [MessageCountSuperUnit new];
    }
    return _childBirthdayMessage;
}

@end
