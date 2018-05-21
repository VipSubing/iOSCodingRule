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
{
    BOOL _filterNullLock;
}
#pragma mark - public
+ (instancetype)modelWithDictionary:(NSDictionary *)jsonDict{
    id model = [[self alloc]initWithDictionary:jsonDict];
    [model modelingCompleted];
    return model;
}
//对象创建完成
- (void)objectInitialized{
    _filterNull = 1;
}
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
    
}

//根据类型 对应value为null情况下赋默认值 如 value为NSString类型 那么当value = null ,这里转成value = @""
- (void)setValue:(id)value forKey:(NSString *)key{
    [super setValue:[self ts_filterValue:value forKey:key] forKey:key
     ];
}
- (void)setFilterNull:(NSInteger)filterNull{
    if (_filterNull != filterNull) {
        _filterNullLock = NO;
    }
    _filterNull = filterNull;
}
- (NSDictionary *)propertyClassDict{
    if (_propertyClassDict == nil || !_filterNullLock) {
        _filterNullLock = YES;
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        Class class = self.class;
        for (int x = 0; x < _filterNull; x ++) {
            unsigned int count;
            objc_property_t* props = class_copyPropertyList(class, &count);
            for (int i = 0; i < count; i++) {
                objc_property_t property = props[i];
                const char * name = property_getName(property);
                NSString *propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
                const char * type = property_getAttributes(property);
                NSString *attr = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
                [tempDic setObject:attr forKey:propertyName];
            }
            free(props);
            if (class.superclass) {
                class = class.superclass;
            }else break;
        }
        _propertyClassDict = tempDic.copy;
    }
    return _propertyClassDict;
}
- (id)ts_filterValue:(id)value forKey:(NSString *)key{
    if ([value isKindOfClass:[NSNull class]] || !value) {
        id new = nil;
        // 获取key属性对应的数据类型
        if ([self.propertyClassDict[key] containsString:@"NSNumber"]) {
            new = @0;
        }
        if ([self.propertyClassDict[key] containsString:@"NSString"]) {
            new = @"";
        }
        if ([self.propertyClassDict[key] containsString:@"NSArray"]) {
            new = @[];
        }
        if ([self.propertyClassDict[key] containsString:@"NSDictionary"]) {
            new = @{};
        }
        return new;
    }
    return value;
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
