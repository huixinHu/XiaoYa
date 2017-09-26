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
static NSString * const HXRefreshGroupDetail = @"hxRefreshGroupDetail";

//发布信息
static NSString * const HXPublishGroupInfoNotification = @"hxPublishGroupInfo";
static NSString * const HXNewGroupInfo = @"hxNewGroupInfo";
static NSString * const HXGroupID = @"hxGroupID";

static NSString * const httpUrl = @"http://139.199.170.95:80/moyuzaiServer/Controller";
#endif /* HXNotifyConfig_h */
