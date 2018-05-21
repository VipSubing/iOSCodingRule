//
//  SBFileManager.m
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/13.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import "SBFileManager.h"

static NSString *const SBFilePlistName = @"SBFile";
static NSString *const SBRootFileName = @"SBRootFile";

@interface SBFileManager()
@property (assign,nonatomic,readwrite) NSUInteger fileCount;
@property (assign,nonatomic,readwrite) unsigned long long rootFolderSize;
@end
@implementation SBFileManager
{
    NSFileManager *_fileManager;
    NSString *_filePlistPath;
    NSDictionary *_filePlist;
    NSDictionary *_fileItems;
    NSString *_rootPath;
}

/**
 *  文件管理器
 */
+ (SBFileManager *)fileManager
{
    static SBFileManager *file = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        file = [[SBFileManager alloc] init];
    });
    return file;
}
- (SBFileItem *)fileItemForName:(NSString *)name{
    return _fileItems[name];
}
- (instancetype)init{
    if (self = [super init]) {
        _fileManager = [NSFileManager defaultManager];
        _filePlistPath = [[NSBundle mainBundle] pathForResource:SBFilePlistName ofType:@"plist"];
        _filePlist = [NSDictionary dictionaryWithContentsOfFile:_filePlistPath];
        NSMutableDictionary *items = [NSMutableDictionary new];
        [_filePlist enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            SBFileItem *item = [SBFileItem modelWithDictionary:obj];
            items[key] = item;
        }];
        _fileItems = items.copy;
        [self createRootPath];
    }
    return self;
}
#pragma mark -
- (void)createRootPath{
    NSString *rootPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    if (![[NSFileManager defaultManager] fileExistsAtPath:rootPath]) {
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:rootPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (success) _rootPath = rootPath;
    }else _rootPath = rootPath;
}
- (NSUInteger)fileCount{
    if (_fileCount) return _fileCount;
    _fileCount = [self.class fileCountInPath:_rootPath];
    return _fileCount;
}
- (unsigned long long)rootFolderSize{
    _rootFolderSize = [self.class folderSizeAtPath:_rootPath];
    return _rootFolderSize;
}
#pragma mark  - utils
/**
 *  文件个数
 */
+ (NSUInteger)fileCountInPath:(NSString *)path
{
    NSUInteger count = 0;
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    for (__unused NSString *fileName in fileEnumerator) {
        count += 1;
    }
    return count;
}

/**
 *  目录大小
 */
+ (unsigned long long)folderSizeAtPath:(NSString *)path
{
    __block unsigned long long totalFileSize = 0;
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [path stringByAppendingPathComponent:fileName];
        NSDictionary *fileAttrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        totalFileSize += fileAttrs.fileSize;
    }
    return totalFileSize;
}
@end
