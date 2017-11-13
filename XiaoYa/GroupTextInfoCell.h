//
//  GroupTextInfoCell.h
//  XiaoYa
//
//  Created by commet on 2017/11/14.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupInfoModel;

@interface GroupTextInfoCell : UITableViewCell
@property (nonatomic ,strong) GroupInfoModel *model;

+ (instancetype)GroupTextInfoCellWithTableView:(UITableView *)tableView;
@end
