//
//  HXSocketManager.h
//  XiaoYa
//
//  Created by commet on 2017/8/21.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  socket 连接状态
 */
typedef NS_ENUM(NSInteger, HXSocketConnectStatus) {
    HXSocketConnectStatusDisconnect = -1,  // 未连接
    HXSocketConnectStatusConnecting = 0,     // 连接中
    HXSocketConnectStatusConnected = 1       // 已连接
};

@interface HXSocketManager : NSObject

@property (nonatomic ,assign) HXSocketConnectStatus connectStatus;  //连接状态

/**
 单例创建对象
 
 @return 单例对象
 */
+ (nonnull instancetype)shareInstance;

/**
 连接socket

 @param delegate 代理对象
 */
- (void)connectSocket:(nonnull id)delegate;


/**
 向服务器写入数据

 @param data 二进制数据
 */
- (void)socketWriteData:(nonnull NSData *)data;

/**
 读取数据
 */
- (void)socketReadData;

/**
 连接失败后重连
 */
- (void)socketReconnect;

/**
 鉴权成功后开启心跳

 @param heartBeatData 心跳包
 */
- (void)socketHeartBeatBegin:(nonnull NSData *)heartBeatData;


/**
 重置心跳计数
 */
- (void)resetHeartBeatCount;

@end
