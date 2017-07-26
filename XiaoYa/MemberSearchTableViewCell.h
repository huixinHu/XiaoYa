//
//  MemberSearchTableViewCell.h
//  XiaoYa
//
//  Created by commet on 2017/7/25.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupMemberModel;
@class MemberSearchTableViewCell;
@protocol MemberSearchCellDelegate <NSObject>
//传回当前选中的indexpath
- (void)memberSearchCell:(MemberSearchTableViewCell *)cell selectIndex:(NSIndexPath *)indexPath;
//传回当前撤销选中的IndexPath
- (void)memberSearchCell:(MemberSearchTableViewCell *)cell deSelectIndex:(NSIndexPath *)indexPath;
@end

@interface MemberSearchTableViewCell : UITableViewCell
@property (nonatomic ,strong) GroupMemberModel *member;
@property (nonatomic ,weak) id <MemberSearchCellDelegate> delegate;
@property (nonatomic ,weak) UIButton *selectBtn;

+ (instancetype)MemberSearchCellWithTableView:(UITableView *)tableView;

@end
