//
//  SBHttpRequest.h
//  MVVMFrameWork
//
//  Created by qyb on 2017/12/7.
//  Copyright © 2017年 qyb. All rights reserved.
//

#import <YTKNetwork/YTKNetwork.h>
NS_ASSUME_NONNULL_BEGIN

extern NSUInteger const SBRequestCancleCode;

extern NSString *const SBRequestFailureErrorDescKey;

typedef void(^SBRequestCompletionSuccessBlock)(YTKRequest *request,id responseObject);
typedef void(^SBRequestCompletionFailureBlock)(YTKRequest *request,NSError * error);

@interface SBHttpRequest : YTKRequest
//缓存时间 默认 -1 不缓存
@property (assign,nonatomic) NSInteger cacheInterval;
//请求域名 如:http://www.baidu.com
@property (copy,nonatomic) NSString *baseUrl;
//请求目录 如: /login/beginLogin
@property (copy,nonatomic) NSString *requestUrl;
//请求参数
@property (copy,nonatomic) NSDictionary *requestArgument;
//请求超时 时间  default 5.s
@property (assign,nonatomic) NSTimeInterval requestTimeoutInterval;
//请求方式  默认 post 
@property (assign,nonatomic) YTKRequestMethod requestMethod;
//响应数据类型 default json
@property (assign,nonatomic) YTKResponseSerializerType responseSerializerType;
//当有相同的请求 取消前面未执行完成的  default YES   前提：url相同，tag相同，userinfo相同
@property (assign,nonatomic) BOOL cancleSameRequest;
//手动取消网络请求后是否需要回调 默认 NO
@property (assign,nonatomic) BOOL needCallbackAsCancled;
/**
 默认配置request

 @return SBHttpRequest
 */
+ (SBHttpRequest *)defaultRequest;

/**
 默认请求参数
 
 @return param
 */
+ (NSMutableDictionary *)defaultParam;

/**
 开始请求

 @param requestUrl 请求的路径名  如 : login/beginLogin  不包含 baseUrl
 @param parameter 参数  可以为空
 @param success 成功回调
 @param failure 失败回调
 */
- (void)sendRequestUrl:(NSString *)requestUrl
      requestParameter:(NSDictionary *)parameter
 completionWithSuccess:(nullable SBRequestCompletionSuccessBlock)success
               failure:(nullable SBRequestCompletionFailureBlock)failure;

/**
 开始请求

 @param baseUrl 请求域名 如: http://www.baidu.com  不包含后面的路径
 @param requestUrl 请求的路径名  如 : login/beginLogin  不包含 baseUrl
 @param parameter 参数  可以为空
 @param success 成功回调
 @param failure 失败回调
 */
- (void)sendRequestWithBaseUrl:(NSString *)baseUrl
                    requestUrl:(NSString *)requestUrl
              requestParameter:(NSDictionary *)parameter
         completionWithSuccess:(nullable SBRequestCompletionSuccessBlock)success
                       failure:(nullable SBRequestCompletionFailureBlock)failure;
/**
 设置请求基本配置

 @param baseUrl host
 @param requestUrl url
 @param parameter 参数
 */
- (void)setBaseUrl:(NSString *)baseUrl
        requestUrl:(NSString *)requestUrl
  requestParameter:(NSDictionary *)parameter;

NS_ASSUME_NONNULL_END
@end
