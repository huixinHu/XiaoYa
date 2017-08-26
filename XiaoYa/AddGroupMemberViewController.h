//
//  AddGroupMemberViewController.h
//  XiaoYa
//
//  Created by commet on 2017/7/12.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddGroupMemberViewController;
@protocol AddGroupMemberViewControllerDelegate <NSObject>
//传回添加的model
- (void)AddGroupMemberViewController:(AddGroupMemberViewController*)viewController addMembersFinish:(NSMutableArray *)modelArray;

@end

@interface AddGroupMemberViewController : UIViewController
@property (nonatomic , weak) id <AddGroupMemberViewControllerDelegate> delegate;

//传入已经添加过的成员模型数组
- (instancetype)initWithAddedMembers:(NSMutableArray *)addedMembers;
@end
