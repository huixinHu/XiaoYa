//
//  HXSocketBusinessManager.m
//  XiaoYa
//
//  Created by commet on 2017/8/21.
//  Copyright © 2017年 commet. All rights reserved.
//业务层

#import "HXSocketBusinessManager.h"
#import "HXSocketManager.h"
#import "HXErrorManager.h"
#import "GCDAsyncSocket.h"
#import "HXTokenManager.h"
#import "HXNotifyConfig.h"
#import "HXDBManager.h"
#import "GroupInfoModel.h"
#import "GroupListModel.h"

@interface HXSocketBusinessManager()<GCDAsyncSocketDelegate>
@property (nonatomic ,strong) HXSocketManager *socketManager;
@property (nonatomic ,strong) NSMutableDictionary *blockDic;//block管理字典
@property (nonatomic ,copy) HXSocketLoginCallback loginCallback;//鉴权回调
@property (nonatomic ,copy) HXSocketCallbackBlock testCallBack;//写回调 因为暂时未实现id对应block存储在字典
@property (nonatomic ,strong) HXDBManager *hxdb;
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
        if (callback) {
            callback([HXErrorManager errorWithErrorCode:3001] ,nil);
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
    NSDateFormatter *dfm = [[NSDateFormatter alloc] init];
    switch (receiveData.type) {
        case ProtoMessage_Type_LoginResponse:{
            if ([receiveData.body isEqualToString:@"ok"]) {
                NSLog(@"登录成功");
                self.loginCallback(nil);
                //开启心跳
//                NSData *heartBeatData = [NSData data];//心跳包
//                [self.socketManager socketHeartBeatBegin:heartBeatData];
                self.socketManager.connectStatus = HXSocketConnectStatusConnected;//这句要在心跳实现时候去掉
                self.socketManager.reconnectionCount = 0;//这句要在心跳实现时候去掉
            } else {
                self.loginCallback([HXErrorManager errorWithErrorCode:3000]);
            }
        } break;
            
        case ProtoMessage_Type_Chat:{//收到聊天消息
            NSString *groupId = receiveData.to;
            NSString *publisher = receiveData.from;
            [dfm setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *tempPublishDate = [dfm dateFromString:receiveData.time];
            [dfm setDateFormat:@"yyyyMMddHHmmss"];
            NSString *publishTime = [dfm stringFromDate:tempPublishDate];
            NSError *jsonError;
            NSData *jsonData = [receiveData.body dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
            if (jsonError) {
                NSLog(@"json 解析错误: --- error %@", jsonError);
            } else{
                NSString *event = [jsonDict objectForKey:@"description"];
                [dfm setDateFormat:@"yyyy-MM-dd"];
                NSDate *tempEventDate = [dfm dateFromString:[jsonDict objectForKey:@"date"]];
                [dfm setDateFormat:@"yyyyMMdd"];
                NSString *eventDate = [dfm stringFromDate:tempEventDate];
                NSString *eventSection = [NSString stringWithFormat:@",%@,",[jsonDict objectForKey:@"time"]];
//                NSString *deadlineIndex;
                NSString *comment = [jsonDict objectForKey:@"comment"];

                NSDictionary *paraDict = @{@"publishTime":publishTime ,@"publisher":publisher ,@"event":event ,@"eventDate":eventDate ,@"eventSection":eventSection ,@"deadlineIndex":@"1" ,@"groupId":groupId,@"comment":comment};
                //插入消息表
                [self.hxdb insertTable:groupInfoTable param:paraDict callback:^(NSError *error) {
                    if(error) NSLog(@"%@",error);
                }];
                //发送通知
                GroupInfoModel *infoModel = [GroupInfoModel groupInfoWithDict:paraDict];
                NSDictionary *dataDict = @{HXNotiFromServerKey:infoModel ,@"type":[NSNumber numberWithInt:ProtoMessage_Type_Chat] ,@"groupId":groupId};
                [[NSNotificationCenter defaultCenter] postNotificationName:HXNotiFromServerNotification object:nil userInfo:dataDict];
            }
        } break;
            
        case ProtoMessage_Type_ChatResponse:{//聊天回应
            //调用block
            if ([receiveData.body isEqualToString:@"ok"]) {
                self.testCallBack(nil ,receiveData);
            }
        } break;
            
        case ProtoMessage_Type_JoinGroupNotify:{//被拉入群
            NSError *jsonError;
            NSData *jsonData = [receiveData.body dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
            if (jsonError) {
                NSLog(@"json 解析错误: --- error %@", jsonError);
            } else{
                //要显式转成nsstring，[userDict objectForKey:@"id"]得到的是long
                NSString *groupId = [NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"id"]];
                NSString *groupName = [jsonDict objectForKey:@"groupName"];
                NSString *groupManagerId = [NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"managerId"]];
                NSString *groupAvatarId = [NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"picId"]];
                NSString *numberOfMember = [NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"amount"]];
                NSDictionary *paraDict = @{@"groupId":groupId ,@"groupName":groupName ,@"groupManagerId":groupManagerId ,@"groupAvatarId":groupAvatarId ,@"numberOfMember":numberOfMember};
                //插入群组表
                [self.hxdb insertTable:groupTable param:paraDict callback:^(NSError *error) {
                    if(error) NSLog(@"%@",error);
                }];
                //发送通知
                GroupListModel *groupModel = [GroupListModel groupWithDict:paraDict];
                NSDictionary *dataDict = @{HXNotiFromServerKey:groupModel ,@"type":[NSNumber numberWithInt:ProtoMessage_Type_JoinGroupNotify]};
                [[NSNotificationCenter defaultCenter] postNotificationName:HXNotiFromServerNotification object:nil userInfo:dataDict];
            }
        } break;
        case ProtoMessage_Type_DismissGroupNotify://群解散
        case ProtoMessage_Type_QuitGroupNotify:{//被踢出群
            NSString *groupId = receiveData.body;
            //删除群组表、关系表、消息表
            [self.hxdb deleteTable:groupTable whereDict:@{@"WHERE groupId = ?":@[groupId]} callback:^(NSError *error) {
                NSLog(@"%@",error);
            }];
            [self.hxdb deleteTable:memberGroupRelation whereDict:@{@"WHERE groupId = ?":@[groupId]} callback:^(NSError *error) {
                NSLog(@"%@",error);
            }];
            [self.hxdb deleteTable:groupInfoTable whereDict:@{@"WHERE groupId = ?":@[groupId]} callback:^(NSError *error) {
                NSLog(@"%@",error);
            }];
            //这里的交互？如果用户此时正在使用该群组相关功能...所以全部聊天界面都要收到这个通知？
            //群组首页、消息首页、发布页、事件详情页、群资料页
            NSNumber *type = [NSNumber numberWithInt:receiveData.type == ProtoMessage_Type_QuitGroupNotify ? ProtoMessage_Type_QuitGroupNotify : ProtoMessage_Type_DismissGroupNotify];
            NSDictionary *dataDict = @{@"groupId":groupId ,@"type":type};
            [[NSNotificationCenter defaultCenter] postNotificationName:HXNotiFromServerNotification object:nil userInfo:dataDict];
        } break;
            
        case ProtoMessage_Type_SomeoneJoinNotify:{//有人进群
            NSError *jsonError;
            NSData *jsonData = [receiveData.body dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
            if (jsonError) {
                NSLog(@"json 解析错误: --- error %@", jsonError);
            } else{
                //更新群组表
                NSString *groupId = [NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"groupId"]];
                NSString *numberOfMember = [NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"amount"]];
                [self.hxdb updateTable:groupTable param:@{@"numberOfMember":numberOfMember} whereDict:@{@"WHERE groupId = ?":@[groupId]} callback:^(NSError *error) {
                    NSLog(@"%@",error);
                }];
                //发送通知
                NSDictionary *dataDict = @{@"groupId":groupId ,@"numberOfMember":numberOfMember ,@"type":[NSNumber numberWithInt:ProtoMessage_Type_SomeoneJoinNotify]};
                [[NSNotificationCenter defaultCenter] postNotificationName:HXNotiFromServerNotification object:nil userInfo:dataDict];
            }
        } break;
            
        case ProtoMessage_Type_UpdateGroupNotify:{//更新群资料
            NSError *jsonError;
            NSData *jsonData = [receiveData.body dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
            if (jsonError) {
                NSLog(@"json 解析错误: --- error %@", jsonError);
            } else{
                //更新群组表
                NSString *groupId = [NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"id"]];
                NSString *groupName = [jsonDict objectForKey:@"groupName"];
                NSString *numberOfMember = [NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"amount"]];
                NSString *groupAvatarId = [NSString stringWithFormat:@"%@",[jsonDict objectForKey:@"picId"]];
                NSDictionary *paraDict = @{@"groupId":groupId ,@"groupAvatarId":groupAvatarId ,@"groupName":groupName, @"numberOfMember":numberOfMember};
                [self.hxdb updateTable:groupTable param:paraDict whereDict:@{@"WHERE groupId = ?":@[groupId]} callback:^(NSError *error) {
                    NSLog(@"%@",error);
                }];
                //发送通知
                NSDictionary *dataDict = @{HXNotiFromServerKey:paraDict ,@"type":[NSNumber numberWithInt:ProtoMessage_Type_UpdateGroupNotify]};
                [[NSNotificationCenter defaultCenter] postNotificationName:HXNotiFromServerNotification object:nil userInfo:dataDict];
            }
        } break;
            
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

- (HXDBManager *)hxdb{
    if (_hxdb == nil) {
        _hxdb = [HXDBManager shareDB];
    }
    return _hxdb;
}
@end
