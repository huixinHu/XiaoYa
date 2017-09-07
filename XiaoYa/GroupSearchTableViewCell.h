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
- (void)groupSearchCell:(nonnull GroupSearchTableViewCell *)cell selectIndex:(nonnull NSIndexPath *)indexPath;

@end

@interface GroupSearchTableViewCell : UITableViewCell
@property (nonatomic ,strong ,nonnull) GroupSearchModel *model;
@property (nonatomic ,weak ,nullable) id <GroupSearchCellDelegate> delegate;

+ (nonnull instancetype)GroupSearchCellWithTableView:(nonnull UITableView *)tableView;
@end
