//
//  GroupDetailViewController.h
//  XiaoYa
//
//  Created by commet on 2017/8/1.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupListModel;
@interface GroupDetailViewController : UIViewController

- (instancetype)initWithGroupInfo:(GroupListModel *)model;
//- (instancetype)init NS_UNAVAILABLE;
@end
