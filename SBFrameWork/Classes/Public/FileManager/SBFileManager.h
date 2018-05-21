//
//  SBFileManager.h
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/13.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBFileItem.h"
@interface SBFileManager : NSObject

/**
 *  文件管理器
 */
+ (SBFileManager *)fileManager;

/**
 通过name获取fileItem

 @param name name
 @return item
 */
- (SBFileItem *)fileItemForName:(NSString *)name;
//文件个数
@property (assign,nonatomic,readonly) NSUInteger fileCount;
//根目录大小
@property (assign,nonatomic,readonly) unsigned long long rootFolderSize;
@end
