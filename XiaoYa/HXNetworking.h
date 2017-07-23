//
//  HXNetworking.h
//  XiaoYa
//
//  Created by commet on 2017/6/11.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>


// 不要直接使用NSURLSessionDataTask,以减少对第三方的依赖
// 借口返回基类NSURLSessionTask，若要接收返回值且处理，转换成对应的子类类型
typedef NSURLSessionTask HXURLSessionTask;
//响应成功block
typedef void(^HXSuccessBlock)(NSURLSessionDataTask *task, id response);
//响应失败block
typedef void(^HXFailureBlock)(NSURLSessionDataTask *task, NSError *error);
//progressblock 待实现
typedef void(^HXProgress)(NSProgress * Progress);

typedef NS_ENUM(NSInteger ,HXRequestType) {
    requestTypeData = 1,
    requestTypeJson = 2,
    requestTypePlist = 3
};

typedef NS_ENUM(NSInteger ,HXResponseType) {
    responseTypeData = 1,
    responseTypeJson = 2,
    responseTypeXML = 3
};


@interface HXNetworking : NSObject
+ (HXURLSessionTask *)postWithUrl:(NSString *)url params:(NSDictionary *)params success:(HXSuccessBlock)success failure:(HXFailureBlock)failure refresh:(BOOL)refresh;
@end
