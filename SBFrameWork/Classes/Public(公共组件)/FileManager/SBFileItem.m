//
//  SBFileItem.m
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/13.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import "SBFileItem.h"

@implementation SBFileItem
#pragma mark - public
+ (instancetype)modelWithDictionary:(NSDictionary *)jsonDict{
    id model = [[self alloc]initWithDictionary:jsonDict];
    return model;
}

#pragma mark - Override

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
@end
