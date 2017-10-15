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
#import "HXTokenManager.h"
#import "MessageProtoBuf.pbobjc.h"

@interface HXSocketBusinessManager()<GCDAsyncSocketDelegate>
@property (nonatomic ,strong) HXSocketManager *socketManager;
@property (nonatomic ,strong) NSMutableDictionary *blockDic;//block管理字典
@property (nonatomic ,copy) HXSocketLoginCallback loginCallback;//鉴权回调
@property (nonatomic ,copy) HXSocketCallbackBlock testCallBack;//写回调 因为暂时未实现id对应block存储在字典
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

- (void)connectSocket:(NSDictionary *)token authAppraisalFailCallBack:(HXSocketLoginCallback)block{
    [HXTokenManager shareInstance].token = token;
    self.loginCallback = block;
    [self.socketManager connectSocket:self];
}

- (void)disconnectSocket{
    [self.socketManager disconnectSocket];
}

//其实第一个cmdType参数好像不必要，封装好数据包再传进来的话
//煦姐他们以前是把cmdType当做包头的一部分
- (void)writeDataWithCmdtype:(HXCmdType)cmdType requestBody:(NSData *)requestData block:(HXSocketCallbackBlock)callback{
    //已连接或者正在连接的状态。什么时候会是正在连接？登录鉴权中或失败
    if (self.socketManager.connectStatus != HXSocketConnectStatusDisconnect) {
        NSString *blockID = [self randomBlockId];
        if (callback) {
            [self.blockDic setObject:callback forKey:blockID];
            self.testCallBack = callback;
        }
        
        NSMutableData *packageData = [self wrapper:requestData];
        [self.socketManager socketWriteData:packageData];
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
    NSDictionary *token = [HXTokenManager shareInstance].token;
    ProtoMessage *msg = [[ProtoMessage alloc] init];
    msg.type = ProtoMessage_Type_Login;
    msg.from = [token objectForKey:@"from"];
    msg.to = @"";
    msg.time = @"";
    msg.body = @"";
    NSMutableData *data = [self wrapper:[msg data]];
    [self.socketManager socketWriteData:data];
    NSLog(@"socket:%p didConnectToHost:%@ port:%hu", socket, host, port);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"连接失败:%@",err);//如果是失败的话，error不为空
    //重连处理
    [self.socketManager socketReconnect];
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"readData......tag：%ld",tag);
    //目前没有反馈功能
    //这里需要做拆包、数据的处理
    
    NSError *error = nil;
    NSData *lengthData = [data subdataWithRange:NSMakeRange(0, 4)];//数据长度
    int length = CFSwapInt32BigToHost(*(int*)([lengthData bytes]));//转十进制
    NSData *protoData = [data subdataWithRange:NSMakeRange(4, data.length-4)];
    ProtoMessage *receiveData = [[ProtoMessage alloc]initWithData:protoData error:&error];
    if (length != protoData.length) {
        NSLog(@"长度校验错误，丢包");
    }
    if (error) {
        NSLog(@"数据解析错误：%@",error);
        [self.socketManager socketReadData];
        return;
    }
    
    //取出BlockDic中存储的block
    //鉴权失败
    //其他错误
    
    //判断请求类型
    switch (receiveData.type) {
        case ProtoMessage_Type_LoginResponse:{
            if ([receiveData.body isEqualToString:@"ok"]) {
                NSLog(@"登录成功");
                self.loginCallback(NO);
                //开启心跳
//                NSData *heartBeatData = [NSData data];//心跳包
//                [self.socketManager socketHeartBeatBegin:heartBeatData];
                self.socketManager.connectStatus = HXSocketConnectStatusConnected;//这句要在心跳实现时候去掉
                self.socketManager.reconnectionCount = 0;//这句要在心跳实现时候去掉
            } else {
                NSLog(@"登录失败");
                self.loginCallback(YES);
            }
        }
            break;
        case ProtoMessage_Type_Chat:
            NSLog(@"body:%@",receiveData.body);
            NSLog(@"from:%@",receiveData.from);
            NSLog(@"to:%@",receiveData.to);
            NSLog(@"time:%@",receiveData.time);
            break;
        case ProtoMessage_Type_ChatResponse:
            //解析数据
            //调用block
            if ([receiveData.body isEqualToString:@"ok"]) {
                self.testCallBack();
            }
            break;
        case ProtoMessage_Type_JoinGroupNotify:
            break;
        case ProtoMessage_Type_QuitGroupNotify:
            break;
        case ProtoMessage_Type_SomeoneJoinNotify:
            break;
        case ProtoMessage_Type_DismissGroupNotify:
            break;
        case ProtoMessage_Type_UpdateGroupNotify:
            break;
        case ProtoMessage_Type_NoGroupNotify:
            break;
            
        case 10://随便写个值，heartBeatReply心跳响应
            //收到心跳响应，就把心跳计数置0
            [self.socketManager resetHeartBeatCount];
            break;
            
        default:
            break;
    }
    if (receiveData.type != 10) {//不是心跳
        [sock readDataWithTimeout:-1 tag:0];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    [self.socketManager socketReadData];
}

#pragma mark 私有方法
- (NSString *)randomBlockId{
    NSTimeInterval timeIn = [[NSDate date] timeIntervalSince1970];
    NSString *blockId = [NSString stringWithFormat:@"%f%d",timeIn,arc4random()%100];
    return blockId;
}

- (NSData *)integerToHex4:(NSInteger)intNum {
    //用4个字节接收
    Byte bytes[4];
    bytes[0] = (Byte)(intNum>>24);
    bytes[1] = (Byte)(intNum>>16);
    bytes[2] = (Byte)(intNum>>8);
    bytes[3] = (Byte)(intNum);
    NSData *data = [NSData dataWithBytes:bytes length:4];
    return data;
}

- (NSMutableData *)wrapper:(NSData *)bodyData{
    NSData *dataLength = [self integerToHex4:[bodyData length]];
    NSMutableData *data = [NSMutableData data];
    [data appendData:dataLength];
    [data appendData:bodyData];
    return data;
}

#pragma mark lazyload
- (NSMutableDictionary *)blockDic{
    if (_blockDic == nil) {
        _blockDic = [NSMutableDictionary dictionary];
    }
    return _blockDic;
}

@end
