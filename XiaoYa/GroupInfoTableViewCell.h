//
//  GroupInfoTableViewCell.h
//  XiaoYa
//
//  Created by commet on 2017/7/31.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupInfoModel;

typedef void(^GroupInfoDetail)(GroupInfoModel *model);

@interface GroupInfoTableViewCell : UITableViewCell
@property (nonatomic ,strong) GroupInfoModel *model;

+ (instancetype)GroupInfoCellWithTableView:(UITableView *)tableView eventDetailBlock:(GroupInfoDetail)block;

@end
