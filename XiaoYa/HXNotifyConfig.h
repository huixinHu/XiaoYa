//
//  HXNotifyConfig.h
//  XiaoYa
//
//  Created by commet on 2017/9/14.
//  Copyright © 2017年 commet. All rights reserved.
//

#ifndef HXNotifyConfig_h
#define HXNotifyConfig_h

//登录界面管理
static NSString * const HXPushViewControllerNotification = @"hxPushViewController";
static NSString * const HXDismissViewControllerNotification = @"hxDismissViewController";

//编辑群资料 自己是群主，自己编辑后在本机的刷新，不是通过后台发消息过来通知要刷新
static NSString * const HXEditGroupDetailNotification = @"hxEditGroupDetail";
static NSString * const HXEditGroupDetailKey = @"hxEditGroupDetailKey";

//发布信息
static NSString * const HXPublishGroupInfoNotification = @"hxPublishGroupInfo";
static NSString * const HXNewGroupInfo = @"hxNewGroupInfo";
static NSString * const HXGroupID = @"hxGroupID";

//解散群或者退出群
static NSString * const HXDismissExitGroupNotification = @"hxDismissExitGroup";
//static NSString * const HXDismissExitGroupKey = @"hxDismissExitGroupKey";

//查看群资料 从数据库或者后台获取到返回的用户信息，通知刷新
static NSString * const HXRefreshUserDetailNotification = @"hxRefreshUserDetail";
static NSString * const HXRefreshUserDetailKey = @"hxRefreshUserDetailKey";

//接收到来自服务器主动发送的消息（不是对客户端的响应）。聊天信息、某用户被拉入群组、某组被解散等等
static NSString * const HXNotiFromServerNotification = @"hxNotiFromServer";
static NSString * const HXNotiFromServerKey = @"hxNotiFromServerKeyy";

#endif /* HXNotifyConfig_h */
