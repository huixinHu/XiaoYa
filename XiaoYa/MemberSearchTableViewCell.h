//
//  MemberSearchTableViewCell.h
//  XiaoYa
//
//  Created by commet on 2017/7/25.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupMemberModel;

typedef void(^selectedBlock)(NSIndexPath * _Nullable indexPath);
typedef void(^deselectedBlock)(NSIndexPath * _Nullable indexPath);

@interface MemberSearchTableViewCell : UITableViewCell
@property (nonatomic ,strong ,nonnull) GroupMemberModel *member;
@property (nonatomic ,weak) UIButton * _Nullable selectBtn;
@property (nonatomic ,copy ,nullable) selectedBlock selectBlock;
@property (nonatomic ,copy ,nullable) deselectedBlock deselectBlock;

+ (nonnull instancetype)MemberSearchCellWithTableView:(nonnull UITableView *)tableView selectBlock:(nullable selectedBlock)select deselectBlock:(nullable deselectedBlock)deselect addedMembers:(nullable NSMutableArray *)addedModels;

@end
