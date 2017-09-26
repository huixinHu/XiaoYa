//
//  HXDBManager.h
//  XiaoYa
//
//  Created by commet on 2017/9/25.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GROUPINFO_TABLE groupinfoTable
#define MEMBER_TABLE memberTable
#define GROUPMESSAGE_TABLE messageTable
#define G_M_RELATIVE relativeTable

typedef NS_ENUM(NSInteger ,HXDBActionType) {
    HXDBSELECT = 0, //查询操作
    HXDBINSERT,     //插入操作
    HXDBUPDATE,     //更新操作
    HXDBDELETE,     //删除操作
    HXDBELSE,       //其他
};

@interface HXDBManager : NSObject

@end
