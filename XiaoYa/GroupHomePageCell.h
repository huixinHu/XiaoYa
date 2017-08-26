//
//  GroupHomePageCell.h
//  XiaoYa
//
//  Created by commet on 2017/7/9.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupListModel;

@interface GroupHomePageCell : UITableViewCell
@property (nonatomic ,strong)GroupListModel *group;

+ (instancetype)groupHomePageCellWithTableView:(UITableView *)tableView;

@end
