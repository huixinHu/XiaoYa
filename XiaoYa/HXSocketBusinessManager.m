//
//  HXSocketBusinessManager.m
//  XiaoYa
//
//  Created by commet on 2017/8/21.
//  Copyright © 2017年 commet. All rights reserved.
//业务层

#import "HXSocketBusinessManager.h"
#import "HXSocketManager.h"
#import "GCDAsyncSocket.h"
//#import "ProtoMessage.pbobjc.h"

@interface HXSocketBusinessManager()<GCDAsyncSocketDelegate>
@property (nonatomic ,strong) HXSocketManager *socketManager;
@property (nonatomic ,strong) NSMutableDictionary *blockDic;//block管理字典

@end

@implementation HXSocketBusinessManager

static HXSocketBusinessManager *manager = nil;
+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.socketManager = [HXSocketManager shareInstance];
    }
    return self;
}

- (void)connectSocket{
    [self.socketManager connectSocket:self];
}

//其实第一个cmdType参数好像不必要，封装好数据包再传进来的话
- (void)writeDataWithCmdtype:(HXCmdType)cmdType requestBody:(NSData *)requestData block:(HXSocketCallbackBlock)callback{
    //已连接或者正在连接的状态。什么时候会是正在连接？登录鉴权失败
    if (self.socketManager.connectStatus != HXSocketConnectStatusDisconnect) {
        NSString *blockID = [self randomBlockId];
        if (callback) {
            [self.blockDic setObject:callback forKey:blockID];
        }
        
        [self.socketManager socketWriteData:requestData];
    }else{
        NSLog(@"socket 未连接");
        if (callback) {
            callback();
        }
    }
}

#pragma mark socketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"连接成功---socket:%p ，Host:%@ ，port:%hu", socket, host, port);

    //连接成功后，首先进行登录鉴权（token？或其他，目前是直接账号登录），向服务器发送一条信息。
    //数据需要封包，但目前协议没定。
//    ProtoMessage* s1 = [[ProtoMessage alloc]init];
//    s1.type = ProtoMessage_Type_Chat;
//    s1.from = @"胡卉馨(17)";
//    s1.to = @"";
//    s1.time = @"2017/7/27";
//    s1.body = @"";
//    [self.socketManager socketWriteData:[s1 data]];

}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"连接失败:%@",err);//如果是失败的话，error不为空
    //但是怎么区分是主动断开的（退出账号等，不需要重连），还是因为网络问题或其他原因断开的（需要重连）
    //重连处理
    [self.socketManager socketReconnect];
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    //目前没有反馈功能
    //这里需要做拆包、数据的处理
    
    NSError *error = nil;
//    ProtoMessage *receiveData = [[ProtoMessage alloc]initWithData:data error:&error];
    if (error) {
        NSLog(@"数据解析错误：%@",error);
        [self.socketManager socketReadData];
        return;
    }
    
    //取出BlockDic中存储的block
    //鉴权失败
    //其他错误
    
    //判断请求类型
//    switch (receiveData.type) {
//        case ProtoMessage_Type_Login:{
//            //开启心跳
//            NSData *heartBeatData = [NSData data];
//            [self.socketManager socketHeartBeatBegin:heartBeatData];
//        }
//            break;
//        case 10://随便写个值，heartBeatReply心跳响应
//            //收到心跳响应，就把心跳计数置0
//            [self.socketManager resetHeartBeatCount];
//            break;
//            
//        case ProtoMessage_Type_Chat:
//            //解析数据
//            //调用block
//            break;
//            
//        default:
//            break;
//    }
}

#pragma mark 私有方法
- (NSString *)randomBlockId{
    NSTimeInterval timeIn = [[NSDate date] timeIntervalSince1970];
    NSString *blockId = [NSString stringWithFormat:@"%f%d",timeIn,arc4random()%100];
    return blockId;
}


#pragma mark lazyload
- (NSMutableDictionary *)blockDic{
    if (_blockDic == nil) {
        _blockDic = [NSMutableDictionary dictionary];
    }
    return _blockDic;
}

@end
