//
//  RemindCell.h
//  XiaoYa
//
//  Created by commet on 16/11/30.
//  Copyright © 2016年 commet. All rights reserved.
//

#import "PublicTemplateCell.h"
@class RemindCell;
@protocol RemindCellDelegate <NSObject>
//传回当前选中的indexpath
- (void)RemindCell:(RemindCell*)cell selectIndex:(NSIndexPath *)indexPath;
//传回当前撤销选中的IndexPath
- (void)RemindCell:(RemindCell*)cell deSelectIndex:(NSIndexPath *)indexPath;
@end

@interface RemindCell : PublicTemplateCell
@property (nonatomic , weak) id <RemindCellDelegate> delegate;

+(instancetype)RemindCellWithTableView:(UITableView *)tableview;
@end
