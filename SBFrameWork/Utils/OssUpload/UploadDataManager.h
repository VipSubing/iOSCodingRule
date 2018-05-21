//
//  UploadDataAliyunOSS.h
//  BossCockpit
//
//  Created by qyb on 2017/2/6.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AliyunOSSiOS/OSSService.h>

typedef NS_ENUM(NSInteger, UploadFaildErrorType) {
    UploadFaildForOther, //其他原因
    UploadFaildForSourceTypeFalse,     //资源类型错误
    UploadFaildForNetLost  // 网络原因
    
};
@interface UploadDataManager : NSObject

+ (instancetype)shareManager;
//取消所有上传任务
- (void)cancleAllTask;
/**
 上传图片
 
 @param object data/filepath
 @param uploadProgress 进度回调
 @param success 成功block
 @param failure 失败block
 */
- (void)uploadVoiceWithObject:(id)object progress:(void(^)(float progress))uploadProgress success:(void(^)(NSString *address))success failure:(void (^)(NSError *error))failure;

/**
 上传图片
 
 @param datas 需要上传的资源数组 成员为data/filepath
 @param uploadProgress 进度回调
 @param success 成功block
 @param failure 失败block
 */
- (void)uploadImageWithObject:(NSArray*)datas progress:(void(^)(float progress))uploadProgress success:(void(^)(NSArray *addresss))success failure:(void (^)(NSError *error))failure;

/**
 上传视频
 
 @param object data/filepath
 @param uploadProgress 进度回调
 @param success 成功block
 @param failure 失败block
 */
- (void)uploadVideoWithObject:(id)object progress:(void(^)(float progress))uploadProgress success:(void(^)(NSString *address))success failure:(void (^)(NSError *error))failure;

@end
