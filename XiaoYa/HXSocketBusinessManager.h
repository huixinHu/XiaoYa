//
//  HXSocketBusinessManager.h
//  XiaoYa
//
//  Created by commet on 2017/8/21.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageProtoBuf.pbobjc.h"
/**
 *  业务类型
 */
typedef NS_ENUM(NSInteger, HXCmdType) {
//    HXCmdType_Beat = 1,                       //心跳
    HXCmdType_loginAuthentication = 0,      //连接鉴权
    HXCmdType_Chat,                     //获取会话列表
};

//typedef void (^HXSocketCallbackBlock)(NSError *__nullable error, id __nullable data);
typedef void(^HXSocketCallbackBlock)(NSError *error, ProtoMessage *data);
typedef void(^HXSocketLoginCallback)(NSError *error);

@protocol HXSocketDelegate <NSObject>

@optional
/**
 *  监听到服务器发送过来的消息
 *
 *  @param data 数据
 *  @param type 类型
 */
- (void)socketReadedData:(ProtoMessage *)data forType:(ProtoMessage_Type)type;

///**
// *  连上时
// */
//- (void)socketDidConnect;
//
///**
// *  建连时检测到token失效
// */
//- (void)connectionAuthAppraisalFailedWithErorr:(NSError *)error;

@end

@interface HXSocketBusinessManager : NSObject

@property (nonatomic, weak) id<HXSocketDelegate> socketDelegate;
/**
 单例创建对象

 @return 单例对象
 */
+ (instancetype)shareInstance;

/**
 socket初始化和建立连接

 @param token 登录令牌
 @param block 鉴权失败的回调
 */
- (void)connectSocket:(NSDictionary *)token  authAppraisalFailCallBack:(HXSocketLoginCallback)block;

- (void)writeDataWithCmdtype:(HXCmdType)cmdType requestBody:(NSData *)requestData blockId:(NSString *)bId block:(HXSocketCallbackBlock)callback;


/**
 主动断开socket。比如退出账号、app进入后台等等。
 */
- (void)disconnectSocket;
@end
