//
//  SBFileItem.h
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/13.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,SBFileItemType){
    SBFileItemWithBaseData,//数据库
    SBFileItemWithModel,//序列化后model 通过coding
    SBFileItemWithBaseValue,//基础类型 如dict array 直接写入文件部分
    SBFileItemWithResource,//资源 音视频等
    SBFileItemWithOther, //其他
};

@interface SBFileItem : NSObject
//命名
@property (copy,nonatomic) NSString *name;
//文件地址
@property (copy,nonatomic) NSString *path;
//类型
@property (strong,nonatomic) NSNumber *type;
//简介
@property (copy,nonatomic) NSString *desc;

+ (instancetype)modelWithDictionary:(NSDictionary *)jsonDict;
@end
