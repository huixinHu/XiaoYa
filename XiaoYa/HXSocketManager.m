//
//  HXSocketManager.m
//  XiaoYa
//
//  Created by commet on 2017/8/21.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "HXSocketManager.h"
#import "HXSocketConfig.h"
#import "GCDAsyncSocket.h"
#import "ProtoMessage.pbobjc.h"
#import "NSTimer+Addition.h"


@interface HXSocketManager()
@property (nonatomic ,strong) GCDAsyncSocket *socket;   //socket
@property (nonatomic ,assign) NSInteger reconnectionCount;//重连次数
@property (nonatomic ,assign) NSInteger heartBeatCount;//心跳计数
@property (nonatomic ,strong) NSTimer *reconnectTimer;//重连计时器
@property (nonatomic ,strong) NSTimer *heartBeatTimer;//心跳计时器

@end

@implementation HXSocketManager

static HXSocketManager *manager = nil;
+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        //设置连接状态
        self.connectStatus = HXSocketConnectStatusDisconnect;
        
        self.reconnectionCount = 0;//重连次数
        self.heartBeatCount = 0;
    }
    return self;
}

//参数：业务层的类作为代理完成回调
- (void)connectSocket:(id)delegate{
    if (self.connectStatus != HXSocketConnectStatusDisconnect) {
        NSLog(@"Socket 正在连接/已连接");
        return;
    }
    //连接状态-正在连接
    self.connectStatus = HXSocketConnectStatusConnecting;
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrent", DISPATCH_QUEUE_CONCURRENT);
    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc]initWithDelegate:delegate delegateQueue:concurrentQueue];
    //回调线程-globalQueue除了处理socket可能还有其他类的事件？
//    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc]initWithDelegate:delegate delegateQueue:dispatch_get_global_queue(0, 0)];
    NSError *error = nil;
    if (![socket connectToHost:HOST onPort:PORT withTimeout:CONNECT_TIMEOUT error:&error]) {
        self.connectStatus = HXSocketConnectStatusDisconnect;//连接状态-未连接
        NSLog(@"连接失败--执行代理？%@",error);
    }
    self.socket = socket;
    
}

- (void)disconnectSocket{
    
}

- (void)socketWriteData:(NSData *)data{
    [self.socket writeData:data withTimeout:-1 tag:0];
    [self socketReadData];
}

- (void)socketReadData{
    [self.socket readDataWithTimeout:READ_TIMEOUT tag:0];
//     [self.socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:10 maxLength:0 tag:0];
}

- (void)socketReconnect{
    //连接状态-未连接
    self.connectStatus = HXSocketConnectStatusDisconnect;
    
    self.reconnectionCount++;
    if (self.reconnectionCount >= 0 && self.reconnectionCount <= RECONNECT_LIMIT) {
        NSLog(@"重连次数：%ld",self.reconnectionCount);
        NSTimeInterval ti = pow(2, self.reconnectionCount);
        __weak typeof(self) weakself = self;
        self.reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:ti block:^(NSTimer *timer) {
            NSError *error = nil;
            if (![weakself.socket connectToHost:HOST onPort:PORT withTimeout:CONNECT_TIMEOUT error:&error]) {
                weakself.connectStatus = HXSocketConnectStatusDisconnect;//连接状态-未连接
            }
            [timer invalidate];
            timer = nil;
        } repeats:NO];//repeat参数为NO,timer执行完自动invalidate，但是timer != nil;
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        
    }
    else{
//        [self.reconnectTimer invalidate];
//        self.reconnectTimer = nil;
        self.reconnectionCount = 0;
    }
    
}

- (void)socketHeartBeatBegin:(NSData *)heartBeatData{
    //登录鉴权成功后才设置已经连接
    //连接状态-已连接.在此之前是“正在连接状态”
    self.connectStatus = HXSocketConnectStatusConnected;
    //已经连接成功了，重置参数。
    self.reconnectionCount = 0;
    self.heartBeatCount = 0;
    
    if (!self.heartBeatTimer) {
        __weak typeof(self) weakself = self;
        self.heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:HEARTBEAT_INTERVAL block:^(NSTimer *timer) {
            __strong typeof(weakself) strongself = weakself;
            //如果连续三次心跳都没有收到响应，就断开socket
            if (strongself.heartBeatCount >= HEARTBEAT_LIMIT) {
                [strongself.socket disconnect];
                [timer invalidate];
                timer = nil;
            }else{
                strongself.heartBeatCount++;
                [strongself socketWriteData:heartBeatData];
            }
        } repeats:YES];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

- (void)resetHeartBeatCount{
    self.heartBeatCount = 0;
}
@end
