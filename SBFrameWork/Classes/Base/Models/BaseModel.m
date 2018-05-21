//
//  BaseModel.m
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/6.
//  Copyright © 2017年 qyb. All rights reserved.
//
#import <libextobjc/EXTRuntimeExtensions.h>
#import <objc/runtime.h>
#import <YYModel.h>
#import "BaseModel.h"

// Used to cache the reflection performed in +propertyKeys.
static void *SBObjectCachedPropertyKeysKey = &SBObjectCachedPropertyKeysKey;

@implementation BaseModel
#pragma mark - public
+ (instancetype)modelWithDictionary:(NSDictionary *)jsonDict{
    id model = [[self alloc]initWithDictionary:jsonDict];
    [model modelingCompleted];
    return model;
}
//对象创建完成
- (void)objectInitialized{}
//模型化完成
- (void)modelingCompleted{}
#pragma mark - NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    for (NSString *key in self.class.propertyKeys) {
        [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder{
    for (NSString *key in self.class.propertyKeys) {
         [aCoder encodeObject:[self valueForKey:key] forKey:key];
    }
}
#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone{
    return [self yy_modelCopy];
}
#pragma mark - Override
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    id model = [super allocWithZone:zone];
    [model objectInitialized];
    return model;
}
- (id)initWithDictionary:(NSDictionary *)dic
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}
//没有找到对应的key可以在这里处理
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"ID"];
    }
    if ([key isEqualToString:@"description"]) {
        [self setValue:value forKey:@"desc"];
    }
}
- (NSDictionary *)dictionaryValue {
    return [self dictionaryWithValuesForKeys:self.class.propertyKeys.allObjects];
}
+ (NSSet *)propertyKeys {
    NSSet *cachedKeys = objc_getAssociatedObject(self, SBObjectCachedPropertyKeysKey);
    if (cachedKeys != nil) return cachedKeys;
    
    NSMutableSet *keys = [NSMutableSet set];
    
    [self enumeratePropertiesUsingBlock:^(objc_property_t property, BOOL *stop) {
        ext_propertyAttributes *attributes = ext_copyPropertyAttributes(property);
        @onExit {
            free(attributes);
        };
        if (attributes->readonly && attributes->ivar == NULL) return;
        NSString *key = @(property_getName(property));
        [keys addObject:key];
    }];
    // It doesn't really matter if we replace another thread's work, since we do
    // it atomically and the result should be the same.
    objc_setAssociatedObject(self, SBObjectCachedPropertyKeysKey, keys, OBJC_ASSOCIATION_COPY);
    return keys;
}
#pragma mark - private
+ (void)enumeratePropertiesUsingBlock:(void (^)(objc_property_t property, BOOL *stop))block {
    Class cls = self;
    BOOL stop = NO;
    
    while (!stop && ![cls isEqual:BaseModel.class]) {
        unsigned count = 0;
        objc_property_t *properties = class_copyPropertyList(cls, &count);
        
        cls = cls.superclass;
        if (properties == NULL) continue;
        
        @onExit {
            free(properties);
        };
        
        for (unsigned i = 0; i < count; i++) {
            block(properties[i], &stop);
            if (stop) break;
        }
    }
}
@end
