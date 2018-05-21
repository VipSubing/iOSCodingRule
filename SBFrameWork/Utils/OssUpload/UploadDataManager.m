//
//  UploadDataAliyunOSS.m
//  BossCockpit
//
//  Created by qyb on 2017/2/6.
//  Copyright © 2017年 qyb. All rights reserved.
//
#import <objc/runtime.h>
#import "UploadDataManager.h"
#import "AFNetworking.h"
#import "OSSPutObjectRequest+SBFree.h"

#define Main_Domain_Name @"https://oss-cn-hangzhou.aliyuncs.com/"
#define Signature @"LTAIVRgyl3ffuafJ"
#define Secret @"CFlD7jMqHo7uyEUalz0As3erQL42Xm"

#define Lock() dispatch_semaphore_wait(_globalLock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(_globalLock)

static dispatch_semaphore_t _globalLock;
NSString* const kURL_Reachability__Address = @"www.baidu.com";

@interface UploadResource : NSObject
@property (copy,nonatomic) NSString *prefixName;
@property (copy,nonatomic) NSString *bucketName;
@property (copy,nonatomic) NSString *routeLabel;
@property (copy,nonatomic) NSString *contentType;
@property (copy,nonatomic) NSString *suffixName;
@end
@implementation UploadResource
@end


@interface UploadDataManager()
@property (strong,nonatomic) OSSClient *client;
@property (strong,nonatomic) OSSPutObjectRequest * put;
@property (strong,nonatomic) id<OSSCredentialProvider> saveCredential;
@property (strong,nonatomic) OSSClientConfiguration * conf;
@property (strong,nonatomic) NSMutableArray *putsArray;
@property (strong,nonatomic) AFNetworkReachabilityManager *netManager;
@property (strong,nonatomic) NSTimer *timer;

@property (strong,nonatomic) UploadResource *imgSource;
@property (strong,nonatomic) UploadResource *voiceSource;
@property (strong,nonatomic) UploadResource *videoSource;

@end
@implementation UploadDataManager
#pragma mark - init
+ (instancetype)shareManager
{
    static UploadDataManager *uploadManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uploadManager = [[UploadDataManager alloc]init];
        
        _globalLock = dispatch_semaphore_create(1);
    });
    return uploadManager;
}
- (instancetype)init
{
    if (self = [super init]) {
        _putsArray = [NSMutableArray new];
        [OSSLog enableLog];
        [self initOSSClient];
        [self createTimer];
    }
    return self;
}
//主动断网检测
- (void)createTimer{
    _timer = [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(netLostCheck) userInfo:nil repeats:YES];
}
- (void)netLostCheck{
    if (self.netManager.networkReachabilityStatus == AFNetworkReachabilityStatusUnknown || self.netManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        [self cancleAllTask];
    }
}
//被动断网检测
- (AFNetworkReachabilityManager *)netManager{
    if (_netManager == nil) {
        _netManager = [AFNetworkReachabilityManager sharedManager];
        [AFNetworkReachabilityManager  managerForDomain:kURL_Reachability__Address];
        [_netManager startMonitoring];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netReachabilityNotification:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    }
    return _netManager;
}
- (void)netReachabilityNotification:(NSNotification *)notification{
    AFNetworkReachabilityStatus status = [[notification.userInfo objectForKey:AFNetworkingReachabilityNotificationStatusItem] integerValue];
    if (status == AFNetworkReachabilityStatusUnknown || status == AFNetworkReachabilityStatusNotReachable) {
        [self cancleAllTask];
    }
}
//配置权鉴及生成Client
- (void)initOSSClient {
    // 自实现签名，可以用本地签名也可以远程加签
    id<OSSCredentialProvider> credential = [[OSSCustomSignerCredentialProvider alloc] initWithImplementedSigner:^NSString *(NSString *contentToSign, NSError *__autoreleasing *error) {
        NSString *signature = [OSSUtil calBase64Sha1WithData:contentToSign withSecret:Secret];
        if (signature != nil) {
            *error = nil;
        } else {
            // construct error object
            *error = [NSError errorWithDomain:@"OSS自签名错误" code:OSSClientErrorCodeSignFailed userInfo:nil];
            return nil;
        }
        return [NSString stringWithFormat:@"OSS %@:%@", Signature, signature];
    }];
    OSSClientConfiguration * conf = [OSSClientConfiguration new];
    conf.maxRetryCount = 20;
    conf.timeoutIntervalForRequest = 15;
    conf.timeoutIntervalForResource = 120;
    NSString *endpoint = Main_Domain_Name;
    _client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential clientConfiguration:conf];
}

#pragma mark - set get
- (UploadResource *)videoSource{
    if (_videoSource == nil) {
        _videoSource = [[UploadResource alloc] init];
        _videoSource.bucketName = @"xiaozhu-video";
        _videoSource.prefixName = @"https://xiaozhu-video.hzbayi.com/";
        _videoSource.suffixName = @"mp4";
        _videoSource.routeLabel = @"byjyVideo";
        _videoSource.contentType = @"mp4";
    }
    return _videoSource;
}
- (UploadResource *)imgSource{
    if (_imgSource == nil) {
        _imgSource = [[UploadResource alloc] init];
        _imgSource.bucketName = @"xiaozhu-image";
        _imgSource.prefixName = @"https://xiaozhu-image.hzbayi.com/";
        _imgSource.suffixName = @"jpg";
        _imgSource.routeLabel = @"byjyImage";
        _imgSource.contentType = @"image/jpg";
    }
    return _imgSource;
}
- (UploadResource *)voiceSource{
    if (_voiceSource == nil) {
        _voiceSource = [[UploadResource alloc] init];
        _voiceSource.bucketName = @"xiaozhu-voice";
        _voiceSource.prefixName = @"https://xiaozhu-voice.hzbayi.com/";
        _voiceSource.suffixName = @"mp3";
        _voiceSource.routeLabel = @"byjyVoice";
        _voiceSource.contentType = @"mp3";
    }
    return _voiceSource;
}
#pragma mark - public
- (void)cancleAllTask{
    for (OSSPutObjectRequest *put in _putsArray) {
        if (!put.isCancelled) {
            [put cancel];
        }
    }
}
- (void)cancleRequestWithFlag:(NSUInteger)flag{
    for (OSSPutObjectRequest *put in _putsArray) {
        if (!put.isCancelled && put.flag == flag) {
            [put cancel];
        }
    }
}
- (void)uploadImageWithObject:(NSArray*)datas progress:(void(^)(float progress))uploadProgress success:(void(^)(NSArray *addresss))success failure:(void (^)(NSError *error))failure
{
    if (!datas.count) {
        failure([NSError errorWithDomain:@"上传对象不存在" code:-10010 userInfo:nil]);
        return;
    }
    NSString *endpoint = self.imgSource.prefixName;
    NSMutableArray *successAddresss = [NSMutableArray new];
    __block int count = 0;
    NSInteger sum = datas.count;
    __block BOOL cancle = NO;
    int index = 0;
    NSUInteger flag = time(NULL);
    for (id object in datas) {
        OSSPutObjectRequest * put = [OSSPutObjectRequest new];
        put.endpoint = endpoint;
        put.flag = flag;
        put.bucketName = self.imgSource.bucketName;
        put.objectKey = [self joiningTogetherRouteWithSource:self.imgSource index:index];
        if ([object isKindOfClass:[UIImage class]]) {
            NSData *imageData = UIImagePNGRepresentation([self.class compressionWithImage:(UIImage *)object]);
            if (![self.class contentTypeForImageData:imageData]) {
                cancle = YES;
                [self cancleRequestWithFlag:flag];
                failure([NSError errorWithDomain:@"图片格式错误" code:-10009 userInfo:nil]);
                return;
            }
            put.uploadingData = imageData;
        }else if ([object isKindOfClass:[NSString class]]){
            put.uploadingFileURL = [NSURL fileURLWithPath:object];
        }
        
        put.contentType = self.imgSource.contentType;
        index ++;
        [self createUploadTaskWithPut:put progress:nil success:^(NSString *address) {
            if (cancle) {
                return ;
            }
            count ++;
            [successAddresss addObject:address];
            if (uploadProgress && !cancle) {
                uploadProgress((count/1.0f)/(sum/1.0f));
            }
            if (count == sum) {
                success(successAddresss.copy);
            }
        } failure:^(NSError *error) {
            if (cancle) {
                return ;
            }
            cancle = YES;
            if (failure) {
                failure(error);
            }
        }];
    }
}
- (void)uploadVoiceWithObject:(id)object progress:(void(^)(float progress))uploadProgress success:(void(^)(NSString *address))success failure:(void (^)(NSError *error))failure{
    if (!object) {
        failure([NSError errorWithDomain:@"上传对象不存在" code:-10010 userInfo:nil]);
        return;
    }
    NSString *endpoint = self.voiceSource.prefixName;
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    put.endpoint = endpoint;
    put.flag = time(NULL);
    put.bucketName = self.voiceSource.bucketName;
    put.objectKey = [self joiningTogetherRouteWithSource:self.voiceSource];
    if ([object isKindOfClass:[NSData class]]) {
        put.uploadingData = (NSData *)object;
    }else if ([object isKindOfClass:[NSString class]]){
        put.uploadingFileURL = [NSURL fileURLWithPath:object];
    }
    put.contentType = self.voiceSource.contentType;
    [self createUploadTaskWithPut:put progress:uploadProgress success:success failure:failure];
}
- (void)uploadVideoWithObject:(id)object progress:(void(^)(float progress))uploadProgress success:(void(^)(NSString *address))success failure:(void (^)(NSError *error))failure
{
    if (!object) {
        failure([NSError errorWithDomain:@"上传对象不存在" code:-10010 userInfo:nil]);
        return;
    }
    NSString *endpoint = self.videoSource.prefixName;
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    put.endpoint = endpoint;
    put.flag = time(NULL);
    put.bucketName = self.videoSource.bucketName;
    put.objectKey = [self joiningTogetherRouteWithSource:self.videoSource];
    if ([object isKindOfClass:[NSData class]]) {
        put.uploadingData = (NSData *)object;
    }else if ([object isKindOfClass:[NSString class]]){
        put.uploadingFileURL = [NSURL fileURLWithPath:object];
    }
    put.contentType = self.videoSource.contentType;
    [self createUploadTaskWithPut:put progress:uploadProgress success:success failure:failure];
}
#pragma mark - private
- (void)createUploadTaskWithPut:(OSSPutObjectRequest *)put progress:(void(^)(float progress))uploadProgress success:(void(^)(NSString *address))success failure:(void (^)(NSError *error))failure{
    if (self.netManager.networkReachabilityStatus == AFNetworkReachabilityStatusUnknown || self.netManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        NSError *error = [[NSError alloc] initWithDomain:@"网络链接异常" code:-1001 userInfo:nil];
        failure(error);
        return;
    }
    //进度
    if (uploadProgress) {
        put.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            if (uploadProgress) {
                float progress = (totalBytesSent/1.0f)/(totalBytesExpectedToSend/1.0f);
                dispatch_main_async_safe(^{
                    uploadProgress(progress);
                });
            }
        };
    }
    Lock();
    [_putsArray addObject:put];
    Unlock();
    OSSTask * putTask = [_client putObject:put];
    
    NSString *endpoint = put.endpoint;
    __weak typeof(self) weak = self;
    //完成回调
    [putTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            //成功
            if (success) {
                dispatch_main_async_safe(^{
                    success([weak getUploadCompleteAddressWithString:put.objectKey endpoint:endpoint]);
                });
            }
        } else {
            //失败
            if (failure) {
                dispatch_main_async_safe(^{
                    failure(task.error);
                });
                
            }
        }
        Lock();
        [weak.putsArray removeObject:put];
        Unlock();
        return nil;
    }];
}



#pragma mark  - join route
- (NSString *)joiningTogetherRouteWithSource:(UploadResource *)source{
    return [self joiningTogetherRouteWithSource:source index:0];
}
- (NSString *)joiningTogetherRouteWithSource:(UploadResource *)source index:(NSUInteger)index{
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *name = [NSString stringWithFormat:@"%lld-%ld-%@.%@",recordTime,index,uuid,source.suffixName];
    NSString *load = [NSString stringWithFormat:@"%@/%@/%@/%@",source.routeLabel,@"iOS",[self dayDate],name];
    return load;
}
- (NSString *)dayDate
{
    NSDate *today = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];//格式化
    [df setDateFormat:@"yyyyMMdd"];
    NSString * time = [df stringFromDate:today];
    return time;
}

- (NSString *)getUploadCompleteAddressWithString:(NSString *)string endpoint:(NSString *)endpoint
{
    NSArray *arr = [string componentsSeparatedByString:@"/"];
    NSMutableString *Str = [[NSMutableString alloc]initWithString:endpoint];
    for (NSString *str in arr) {
        [Str appendFormat:@"%@/",str];
    }
    NSRange range = {Str.length-1,1};
    [Str deleteCharactersInRange:range];
    return Str;
}
#pragma mark - units
+ (UIImage *)scaleImage:(UIImage *)image toKb:(NSInteger)kb{
    if (!image) {
        return image;
    }
    if (kb<1) {
        return image;
    }
    kb*=1024;
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > kb && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    NSLog(@"当前大小:%fkb",(float)[imageData length]/1024.0f);
    UIImage *compressedImage = [UIImage imageWithData:imageData];
    return compressedImage;
}
+ (UIImage *)compressionWithImage:(UIImage *)image{
    return [self scaleImage:image toKb:400];
}

+ (BOOL )contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return YES;
        case 0x89:
            return YES;
        case 0x47:
            return YES;
        case 0x49:
        case 0x4D:
            return NO;
        case 0x52:
            if ([data length] < 12) {
                return NO;
            }
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return NO;
            }
            return NO;
    }
    return NO;
}
- (void)dealloc{
    [_timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
