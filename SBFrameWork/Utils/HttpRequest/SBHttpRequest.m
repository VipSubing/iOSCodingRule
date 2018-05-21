//
//  SBHttpRequest.m
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/7.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import "SBHttpRequest.h"


NSUInteger const SBRequestCancleCode = -15001;

//错误信息 desc
NSString *const SBRequestFailureErrorDescKey = @"SBRequestFailureErrorDescKey";

//正在执行的请求
static NSMutableDictionary *executingRequests;


@implementation SBHttpRequest
+ (NSMutableDictionary *)defaultParam{
    NSMutableDictionary *param = [NSMutableDictionary new];
    return param;
}
+ (void)initialize{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        executingRequests = [NSMutableDictionary new];
    });
}
#pragma mark - public
+ (SBHttpRequest *)defaultRequest{
    SBHttpRequest *request = [[SBHttpRequest alloc] init];
    return request;
}
- (void)sendRequestUrl:(NSString *)requestUrl
  requestParameter:(NSDictionary *)parameter
completionWithSuccess:(nullable SBRequestCompletionSuccessBlock)success
           failure:(nullable SBRequestCompletionFailureBlock)failure{
    
    [self sendRequestWithBaseUrl:SBBaseUrl requestUrl:requestUrl requestParameter:parameter completionWithSuccess:success failure:failure];
}
- (void)sendRequestWithBaseUrl:(NSString *)baseUrl
                requestUrl:(NSString *)requestUrl
          requestParameter:(NSDictionary *)parameter
     completionWithSuccess:(nullable SBRequestCompletionSuccessBlock)success
                   failure:(nullable SBRequestCompletionFailureBlock)failure{
    [self setBaseUrl:baseUrl requestUrl:requestUrl requestParameter:parameter];
    self.successCompletionBlock = ^(YTKRequest *request){
        if (success) {
            success(request,request.responseObject);
        }
    };
    self.failureCompletionBlock = ^(YTKRequest *request){
        if (failure) {
            failure(request,[SBHttpRequest _errorFromRequestError:request.error]);
        }
    };
    //如果self.cancleSameRequest == YES ,并且url相同,tag相同,userInfo相同 就取消前面的请求
    if (_cancleSameRequest) {
        SBHttpRequest *request = [executingRequests objectForKey:[self fullRequestUrl]];
        if (request && request.tag == self.tag && [request.userInfo isEqualToDictionary:self.userInfo]) {
            if (request.isExecuting) {
                [request stop];
                //取消后是否应该回调
                if (_needCallbackAsCancled && failure) {
                    failure(request,[NSError errorWithDomain:@"NSURLCocoaDomain" code:SBRequestCancleCode userInfo:@{@"url":[self fullRequestUrl],SBRequestFailureErrorDescKey:@"request is common so be cancle"}]);
                }
            }
        }
    }
    [self start];
}
#pragma mark -
- (instancetype)init{
    if (self = [super init]) {
        _requestTimeoutInterval = 5.f;
        _requestMethod = YTKRequestMethodPOST;
        _responseSerializerType = YTKResponseSerializerTypeJSON;
        _cacheInterval = -1;
        _cancleSameRequest = YES;
    }
    return self;
}
- (void)setBaseUrl:(NSString *)baseUrl
        requestUrl:(NSString *)requestUrl
  requestParameter:(NSDictionary *)parameter{

    self.baseUrl = baseUrl.length == 0?SBBaseUrl:baseUrl;
    self.requestUrl = requestUrl;
    self.requestArgument = parameter;
}
- (NSString *)fullRequestUrl{
    return [_baseUrl stringByAppendingPathComponent:_requestUrl];
}
#pragma mark - Override
- (void)start{
    [super start];
    //添加到运行队列
    [executingRequests setObject:self forKey:[self fullRequestUrl]];
}
- (void)stop{
    [super stop];
    //移除运行队列
    [executingRequests removeObjectForKey:[self fullRequestUrl]];
}
- (NSString *)baseUrl{
    return _baseUrl;
}
- (NSString *)requestUrl{
    return _requestUrl;
}

- (NSString *)cdnUrl{
    return [super cdnUrl];
}

- (NSTimeInterval)requestTimeoutInterval{
    return _requestTimeoutInterval;
}
- (id)requestArgument{
    return _requestArgument;
}
///  HTTP request method.
- (YTKRequestMethod)requestMethod{
    return _requestMethod;
}
///  Request serializer type.
- (YTKRequestSerializerType)requestSerializerType{
    return [super requestSerializerType];
}
///  Response serializer type. See also `responseObject`.
- (YTKResponseSerializerType)responseSerializerType{
    return [super responseSerializerType];
}
//请求完成
- (void)requestCompletePreprocessor{
    [super requestCompletePreprocessor];
    //移除运行队列
    [executingRequests removeObjectForKey:[self fullRequestUrl]];
}
//请求完成过滤
- (void)requestCompleteFilter{
    [super requestCompleteFilter];
}
//请求失败预处理
- (void)requestFailedPreprocessor{
    [super requestFailedPreprocessor];
    //移除运行队列
    [executingRequests removeObjectForKey:[self fullRequestUrl]];
}
//请求失败过滤
- (void)requestFailedFilter{
    [super requestFailedFilter];
}
///  Override this method to filter requests with certain arguments when caching.
- (id)cacheFileNameFilterForRequestArgument:(id)argument{
    return [super cacheFileNameFilterForRequestArgument:argument];
}
///  Username and password used for HTTP authorization. Should be formed as @[@"Username", @"Password"].
- (nullable NSArray<NSString *> *)requestAuthorizationHeaderFieldArray{
    return [super requestAuthorizationHeaderFieldArray];
}
///  Additional HTTP request header field.
- (nullable NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary{
    return [super requestHeaderFieldValueDictionary];
}
///  Use this to build custom request. If this method return non-nil value, `requestUrl`, `requestTimeoutInterval`,
///  `requestArgument`, `allowsCellularAccess`, `requestMethod` and `requestSerializerType` will all be ignored.
- (nullable NSURLRequest *)buildCustomUrlRequest{
    return [super buildCustomUrlRequest];
}
// default NO
- (BOOL)useCDN{
    return [super useCDN];
}
///  是否允许使用蜂窝移动 default YES
- (BOOL)allowsCellularAccess{
    return [super allowsCellularAccess];
}
///  The validator will be used to test if `responseJSONObject` is correctly formed.
- (nullable id)jsonValidator{
    return [super jsonValidator];
}
///  This validator will be used to test if `responseStatusCode` is valid.
- (BOOL)statusCodeValidator{
    return [super statusCodeValidator];
}
#pragma mark - cache
//  The max time duration that cache can stay in disk until it's considered expired.
///  Default is -1, which means response is not actually saved as cache.
- (NSInteger)cacheTimeInSeconds{
    return _cacheInterval;
}

- (long long)cacheVersion{
    return [super cacheVersion];
}

- (nullable id)cacheSensitiveData{
    return [super cacheSensitiveData];
}

- (BOOL)writeCacheAsynchronously{
    return [super writeCacheAsynchronously];
}
#pragma mark - error parse
+ (NSError *)_errorFromRequestError:(NSError *)error {
    //default
    NSString *errorDesc = @"网络异常，请稍后再试~";
    if ([error.domain isEqual:NSURLErrorDomain]) {
        switch (error.code) {
            case NSURLErrorTimedOut:{
#if defined(DEBUG)||defined(_DEBUG)
                errorDesc = @"请求超时，请稍后再试(-1001)~"; /// 调试模式
#else
                errorDesc = @"请求超时，请稍后再试~";        /// 发布模式
#endif
                break;
            }
            case NSURLErrorNotConnectedToInternet:{
#if defined(DEBUG)||defined(_DEBUG)
                errorDesc = @"网络开小差了，请稍后重试(-1009)~"; /// 调试模式
#else
                errorDesc = @"网络开小差了，请稍后重试~";        /// 发布模式
#endif
                break;
            }
            default:
                break;
        }
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
    userInfo[SBRequestFailureErrorDescKey] = errorDesc?:@"";
    
    return [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo.copy];
}
@end
