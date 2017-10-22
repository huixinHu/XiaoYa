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
//#import "ProtoMessage.pbobjc.h"
#import "NSTimer+Addition.h"


@interface HXSocketManager()
@property (nonatomic ,strong) GCDAsyncSocket *socket;   //socket
//@property (nonatomic ,assign) NSInteger reconnectionCount;//重连次数
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
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("socket_concurrent", DISPATCH_QUEUE_CONCURRENT);
    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc]initWithDelegate:delegate delegateQueue:concurrentQueue];
    NSError *error = nil;
    if (![socket connectToHost:HOST onPort:PORT withTimeout:CONNECT_TIMEOUT error:&error]) {
        self.connectStatus = HXSocketConnectStatusDisconnect;//连接状态-未连接
        NSLog(@"连接失败--执行代理？%@",error);
    }
    self.socket = socket;
    
}

//手动断开socket
- (void)disconnectSocket{
    [self.socket disconnect];
    self.reconnectionCount = -1;
    [self.heartBeatTimer invalidate];
    self.heartBeatTimer = nil;
}

- (void)socketWriteData:(NSData *)data timeout:(NSTimeInterval)ti{
    
}

- (void)socketWriteData:(NSData *)data{
    [self.socket writeData:data withTimeout:-1 tag:0];
}

- (void)socketReadData{
    [self.socket readDataWithTimeout:-1 tag:0];//读取超时会触发socket失败的代理
//     [self.socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:10 maxLength:0 tag:0];
}

- (void)socketReconnect{
    //连接状态-未连接
    self.connectStatus = HXSocketConnectStatusDisconnect;
    
    if (self.reconnectionCount >= 0 && self.reconnectionCount <= RECONNECT_LIMIT) {
        self.reconnectionCount++;
        NSLog(@"重连次数：%@",[NSNumber numberWithInteger:self.reconnectionCount]);
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
    else{//当手动断开socket时（退出账号、进入后台等），reconnectCount<0
        [self.reconnectTimer invalidate];
        self.reconnectTimer = nil;
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
//                self.reconnectionCount = -1; ？？心跳失败后还需不需要重连？不需要就设-1
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
