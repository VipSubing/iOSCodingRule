//
//  BaseModel.h
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/6.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseModel : NSObject<NSCopying,NSCoding>

/**
 一般模型化方法

 @param jsonDict dict
 @return model
 */
+ (instancetype)modelWithDictionary:(NSDictionary *)jsonDict;

/**
 通过字典初始化一个对象

 @param dict dict
 @return self  不改变 最初 alloc 获取的地址
 */
- (id)initWithDictionary:(NSDictionary *)dict;
//对象初始化完成 在allocWithZone:以后调用
- (void)objectInitialized;
//模型化完成  在modelWithDictionary:以后调用
- (void)modelingCompleted;

// Returns the keys for all @property declarations, except for `readonly`
// properties without ivars, or properties on MHObject itself.
/// 返回所有@property声明的属性，除了只读属性，以及属性列表不包括成员变量
+ (NSSet *)propertyKeys;
// @{propertyKeyName:value}
@property (nonatomic, copy, readonly) NSDictionary *dictionaryValue;
// wether filter value where the is null , Default 1,
// no filter set 0. filter one super propertys can set filter = 2,two super propertys set filter = 3，and so on
@property (nonatomic) NSInteger filterNull;
//属性类型 如 {@"property":@"propertyClass"}
@property (nonatomic) NSDictionary *propertyClassDict;
@end
