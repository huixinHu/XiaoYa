//
//  GroupDetailViewController.m
//  XiaoYa
//
//  Created by commet on 2017/8/1.
//  Copyright © 2017年 commet. All rights reserved.
//查看群资料

#import "GroupDetailViewController.h"
#import "ProtoMessage.pbobjc.h"
#import "GCDAsyncSocket.h"
@interface GroupDetailViewController () <GCDAsyncSocketDelegate>
@property (nonatomic)GCDAsyncSocket *socket;

@end

@implementation GroupDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 50, 50)];
    btn.backgroundColor = [UIColor redColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];

    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    NSError *error = nil;
    [socket connectToHost:@"139.199.170.95" onPort:8989 error:&error];
    self.socket = socket;

}

- (void)click{
    ProtoMessage* s1 = [[ProtoMessage alloc]init];
    s1.type = ProtoMessage_Type_Chat;
    s1.from = @"胡卉馨(17)";
    s1.to = @"13";
    s1.time = @"2017/7/27";
    s1.body = @"hello";
    NSData *data = [s1 data];
    NSLog(@"要发送的数据：%@",data);
    Byte *byteArr = (Byte *)[data bytes];
    [self.socket writeData:data withTimeout:-1 tag:100];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"%@",data);
    
    ProtoMessage *s2 = [ProtoMessage parseFromData:data error:NULL];
    NSLog(@"type:%d,from:%@,to:%@,time:%@,body:%@",s2.type,s2.from,s2.to,s2.time,s2.body);
    
    NSString *data2Str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@",data2Str);
    

    [sock readDataWithTimeout:-1 tag:100];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"发送数据成功");
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"连接成功");
    [self.socket readDataWithTimeout:-1 tag:100];
    //心跳处理
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"连接失败:%@",err);
    //重连处理
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
