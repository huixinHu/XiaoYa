//
//  HXSocketConfig.h
//  XiaoYa
//
//  Created by commet on 2017/8/21.
//  Copyright © 2017年 commet. All rights reserved.
//

#ifndef HXSocketConfig_h
#define HXSocketConfig_h

static NSString *HOST = @"139.199.170.95";
static const int PORT = 8989;

static const int CONNECT_TIMEOUT = 30;
static const int READ_TIMEOUT = 5;
//心跳
static const int HEARTBEAT_LIMIT = 3;//心跳没有响应的上限次数
static const int HEARTBEAT_INTERVAL = 60;
//重连
static const int RECONNECT_LIMIT = 5;

//网络状态
typedef NS_ENUM(NSInteger ,HXNetWorkStatus) {
    HXNetWorkStatusUnknown          = -1,
    HXNetWorkStatusNotReachable     = 0,
    HXNetWorkStatusWWAN = 1,
    HXNetWorkStatusWiFi = 2,
};
#endif /* HXSocketConfig_h */
