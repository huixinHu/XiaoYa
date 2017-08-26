//
//  HXSocketBusinessManager.h
//  XiaoYa
//
//  Created by commet on 2017/8/21.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  业务类型
 */
typedef NS_ENUM(NSInteger, HXCmdType) {
//    HXCmdType_Beat = 1,                       //心跳
    HXCmdType_loginAuthentication = 0,      //连接鉴权
    HXCmdType_Chat,                     //获取会话列表
};

//typedef void (^HXSocketCallbackBlock)(NSError *__nullable error, id __nullable data);
typedef void(^HXSocketCallbackBlock)(void);

@interface HXSocketBusinessManager : NSObject

/**
 单例创建对象

 @return 单例对象
 */
+ (instancetype)shareInstance;


/**
 socket初始化和建立连接
 */
- (void)connectSocket;
@end
