//
//  GroupCreateViewController.h
//  XiaoYa
//
//  Created by commet on 2017/7/11.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupMemberModel;
@class GroupListModel;
typedef void(^gCreateSucBlock)(GroupListModel *model);

@interface GroupCreateViewController : UIViewController
@property (nonatomic ,weak ,readonly) UITextField *groupName;
@property (nonatomic ,weak ,readonly) UIButton *createGroup;

@property (nonatomic ,strong ,readonly) NSMutableArray <GroupMemberModel *> *dataArray;//存储数据(模型) 第一个一定是群主
@property (nonatomic ,strong ,readonly) GroupListModel *groupModel;
@property (nonatomic ,assign ,readonly) NSInteger avatarID;

- (instancetype)initWithGroupModel:(GroupListModel *)model successBlock:(gCreateSucBlock)block;
- (instancetype)init NS_UNAVAILABLE;
@end
