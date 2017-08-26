//
//  HXNetworking.m
//  XiaoYa
//
//  Created by commet on 2017/6/11.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "HXNetworking.h"
#import "AFHTTPSessionManager.h"
//#import "AFNetworkActivityIndicatorManager.m"
#import "HXSocketConfig.h"

#define TIME_OUT 15

@interface NSURLRequest (compare)
- (BOOL)isTheSameRequest:(NSURLRequest *)request;
@end

@interface HXNetworking()
@end

//static AFHTTPSessionManager *_sharedManager = nil;
static NSString *_hBaseUrl = nil;                           //baseurl
static HXRequestType _hRequestType = requestTypeData;       //请求数据类型
static HXResponseType _hResponseType = responseTypeJson;    //接收数据类型
static NSDictionary * _hHttpHeaders = nil;                  //请求头
static NSTimeInterval _hTimeout = TIME_OUT;                 //超时
static NSMutableArray *_hTaskPool;                          //请求池
static BOOL _hCacheWhenNetworkDisconnect = NO;              //是否允许网络不佳时使用本地缓存
static HXNetWorkStatus _hNetworkStatus = HXNetWorkStatusUnknown;


@implementation HXNetworking

+ (HXURLSessionTask *)getWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                            cache:(BOOL)isCache
                          success:(HXSuccessBlock)success
                          failure:(HXFailureBlock)failure
                          refresh:(BOOL)refresh
{
    //判断一下url编码对不对
    
    //先判断网络状态
    if (isCache && _hCacheWhenNetworkDisconnect) {//允许网络不好时使用缓存
        if (_hNetworkStatus == HXNetWorkStatusUnknown || _hNetworkStatus == HXNetWorkStatusNotReachable) {
            //取出缓存
            
            //本地有缓存，成功取出就返回
            //            success();
            return nil;
        }
    }
    
    //发起网络请求
    AFHTTPSessionManager *manager = [self manager];
    HXURLSessionTask *sessionTask = [manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (isCache) {
            //保存缓存
        }
        if (success) { success(task, responseObject); }
        [[self allTasks] removeObject:task];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (isCache) {
            //取出缓存,可能还需要对数据做格式转换
            NSData *localCache = [NSData data];
            if (localCache) { //获取成功
                if (success) { success(task, localCache); }//将数据回调回去
            }else{
                if (failure) { failure(task ,error); }
            }
        }else{
            if (failure) { failure(task ,error); }
        }
        [[self allTasks] removeObject:task];
    }];
    
    if ([self isHaveSameRequestInTaskPool:sessionTask] && !refresh) {//重复的请求就取消
        [sessionTask cancel];
    } else{//刷新请求，或者是全新的请求
        [self cancelSameRunningRequest:sessionTask];
        [[self allTasks] addObject:sessionTask];
    }
    return sessionTask;
}


+ (HXURLSessionTask *)postWithUrl:(NSString *)url
                           params:(NSDictionary *)params
                            cache:(BOOL)isCache
                          success:(HXSuccessBlock)success
                          failure:(HXFailureBlock)failure
                          refresh:(BOOL)refresh
{
    //判断一下url编码对不对
    
    //先判断网络状态
    if (isCache && _hCacheWhenNetworkDisconnect) {//允许网络不好时使用缓存
        if (_hNetworkStatus == HXNetWorkStatusUnknown || _hNetworkStatus == HXNetWorkStatusNotReachable) {
            //取出缓存
            
            //本地有缓存，成功取出就返回
//            success();
            return nil;
        }
    }

    //发起网络请求
    AFHTTPSessionManager *manager = [self manager];
    HXURLSessionTask *sessionTask = [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (isCache) {
            //保存缓存
        }
        if (success) { success(task, responseObject); }
        [[self allTasks] removeObject:task];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (isCache) {
            //取出缓存,可能还需要对数据做格式转换
            NSData *localCache = [NSData data];
            if (localCache) { //获取成功
                if (success) { success(task, localCache); }//将数据回调回去
            }else{
                if (failure) { failure(task ,error); }
            }
        }else{
            if (failure) { failure(task ,error); }
        }
        [[self allTasks] removeObject:task];
    }];
    
    if ([self isHaveSameRequestInTaskPool:sessionTask] && !refresh) {//重复的请求就取消
        [sessionTask cancel];
    } else{//刷新请求，或者是全新的请求
        [self cancelSameRunningRequest:sessionTask];
        [[self allTasks] addObject:sessionTask];
    }
    return sessionTask;
}

+ (AFHTTPSessionManager *)manager{
    AFHTTPSessionManager *manager = nil;
//    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    if ([self baseUrl] != nil) {
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:_hBaseUrl]];
    }else{
        manager = [AFHTTPSessionManager manager];
    }
    
    switch (_hRequestType) {
        case requestTypeData:{
            manager.requestSerializer  = [AFHTTPRequestSerializer serializer];
            break;
        }
        case requestTypeJson:{
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        }
        case requestTypePlist:{
            manager.requestSerializer = [AFPropertyListRequestSerializer serializer];
            break;
        }
        default:
            break;
    }
    manager.requestSerializer.stringEncoding = kCFStringEncodingUTF8;
    manager.requestSerializer.timeoutInterval = _hTimeout;
    manager.requestSerializer.HTTPShouldHandleCookies = YES;
//    manager.requestSerializer.cachePolicy = cache
    NSArray *keys = [_hHttpHeaders allKeys];
    for (NSString *key in keys) {
        [manager.requestSerializer setValue:[_hHttpHeaders objectForKey:key] forHTTPHeaderField:key];
    }

    
    switch (_hResponseType) {
        case responseTypeData:{
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
        }
        case responseTypeJson:{
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
        }
        case responseTypeXML:{
            manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
        }
        default:
            break;
    }
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
    
    manager.operationQueue.maxConcurrentOperationCount = 3;//最大并发数
//    manager.requestSerializer.HTTPShouldHandleCookies
    return manager;
}

#pragma mark - AFHTTPSessionManager相关属性
+ (void)baseUrlSetting:(NSString *)newBaseUrl{
    _hBaseUrl = newBaseUrl;
}

+ (NSString *)baseUrl{
    return _hBaseUrl;
}

+ (void)configureTimeout:(NSTimeInterval)ti{
    _hTimeout = ti;
}

+ (void)configureRequsetType:(HXRequestType )requestType responseType:(HXResponseType )responseType{
    _hRequestType = requestType;
    _hResponseType = responseType;
}

+ (void)configureHttpHeader:(NSDictionary *)headers{
    _hHttpHeaders = headers;
}

+ (void)configureUseCacheWhenNetworkDisconnect:(BOOL)isUse{
    _hCacheWhenNetworkDisconnect = isUse;
}

#pragma mark 请求池
+ (NSMutableArray *)allTasks{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_hTaskPool == nil) {
            _hTaskPool = [NSMutableArray array];
        }
    });
    return _hTaskPool;
}

//是否已有相同的请求
+ (BOOL)isHaveSameRequestInTaskPool:(HXURLSessionTask *)task{
    __block BOOL isSame = NO;
    [[self allTasks] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        HXURLSessionTask *objTask = obj;
        if ([task.originalRequest isTheSameRequest:objTask.originalRequest]) {
            isSame = YES;
            *stop = YES;
        }
    }];
    return isSame;
}

#pragma mark 取消请求
//taskpool这块有多线程存取的问题，先暂时放一放
//移除正在运行的request
+ (void)cancelSameRunningRequest:(HXURLSessionTask *)task{
    @synchronized(self){
        __block HXURLSessionTask *runningTask = nil;
        [[self allTasks] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            HXURLSessionTask *objTask = obj;
            if ([task.originalRequest isTheSameRequest:objTask.originalRequest]) {
                if (task.state != NSURLSessionTaskStateCompleted) {
                    [objTask cancel];
                    runningTask = objTask;
                }
                *stop = YES;
            }
        }];
        [[self allTasks] removeObject:runningTask];
    }
}

+ (void)cancelRequestWithUrl:(NSString *)url{
    if (url != nil) {
        @synchronized(self){
            __block NSMutableArray *taskArr = [NSMutableArray array];
            //url全匹配
            [[self allTasks] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                HXURLSessionTask *objTask = obj;
                if ([objTask.originalRequest.URL.absoluteString isEqualToString:url]) {
                    [objTask cancel];
                    [taskArr addObject:objTask];
                }
            }];
            for (int i = 0 ; i < taskArr.count; i++) {
                if ([[self allTasks] containsObject:taskArr[i]]) {
                    [[self allTasks] removeObject:taskArr[i]];
                }
            }
        }
    }
}

+ (void)cancelAllRequest{
    @synchronized(self){
        [[self allTasks] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            HXURLSessionTask *objTask = obj;
            [objTask cancel];
        }];
        [[self allTasks] removeAllObjects];
    }
}
@end


@implementation NSURLRequest (compare)
//是不是相同的请求
- (BOOL)isTheSameRequest:(NSURLRequest *)request{
    if ([self.URL.absoluteString isEqualToString:request.URL.absoluteString]) {
        if ([self.HTTPMethod isEqualToString:request.HTTPMethod]) {
            if ([self.HTTPMethod isEqualToString:@"GET"] || [self.HTTPBody isEqualToData:request.HTTPBody]) {
                return YES;
            }
        }
    }
    return NO;
}

@end
