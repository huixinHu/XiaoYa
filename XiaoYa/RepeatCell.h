//
//  RepeatCell.h
//  XiaoYa
//
//  Created by commet on 16/11/30.
//  Copyright © 2016年 commet. All rights reserved.
//

#import "PublicTemplateCell.h"
@class RepeatCell;
@protocol RepeatCellDelegate <NSObject>
//传回当前选中的indexpath
- (void)RepeatCell:(RepeatCell*)cell selectIndex:(NSIndexPath *)indexPath;
@end

@interface RepeatCell : PublicTemplateCell
@property (nonatomic , weak) id <RepeatCellDelegate> delegate;

+(instancetype)RepeatCellWithTableView:(UITableView *)tableview;
@end
