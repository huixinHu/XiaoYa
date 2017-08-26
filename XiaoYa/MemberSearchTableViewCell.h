//
//  MemberSearchTableViewCell.h
//  XiaoYa
//
//  Created by commet on 2017/7/25.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupMemberModel;

typedef void(^selectedBlock)(NSIndexPath *indexPath);
typedef void(^deselectedBlock)(NSIndexPath *indexPath);

@interface MemberSearchTableViewCell : UITableViewCell
@property (nonatomic ,strong) GroupMemberModel *member;
@property (nonatomic ,weak) UIButton *selectBtn;

+ (instancetype)MemberSearchCellWithTableView:(UITableView *)tableView selectBlock:(selectedBlock)select deselectBlock:(deselectedBlock)deselect addedMembers:(NSMutableArray *)addedModels;

@end
