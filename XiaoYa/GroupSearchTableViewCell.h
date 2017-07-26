//
//  GroupSearchTableViewCell.h
//  XiaoYa
//
//  Created by commet on 2017/7/13.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupSearchModel;
@class GroupSearchTableViewCell;
@protocol GroupSearchCellDelegate <NSObject>
//传回当前选中的indexpath
- (void)groupSearchCell:(GroupSearchTableViewCell *)cell selectIndex:(NSIndexPath *)indexPath;

@end

@interface GroupSearchTableViewCell : UITableViewCell
@property (nonatomic ,strong) GroupSearchModel *model;
@property (nonatomic ,weak) id <GroupSearchCellDelegate> delegate;

+ (instancetype)GroupSearchCellWithTableView:(UITableView *)tableView;
@end
