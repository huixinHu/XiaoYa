//
//  GroupInfoTableViewCell.h
//  XiaoYa
//
//  Created by commet on 2017/7/31.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupInfoTableViewCell;
@protocol GroupInfoCellDelegate <NSObject>
//传回当前选中的indexpath
- (void)GroupInfoCell:(GroupInfoTableViewCell *)cell selectIndex:(NSIndexPath *)indexPath;
@end

@interface GroupInfoTableViewCell : UITableViewCell
+ (instancetype)GroupInfoCellWithTableView:(UITableView *)tableView eventDetailBlock:(void(^)())block;

@property (nonatomic ,weak) id <GroupInfoCellDelegate> delegate;
@end
