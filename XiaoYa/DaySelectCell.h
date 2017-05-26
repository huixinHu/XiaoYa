//
//  DaySelectCell.h
//  XiaoYa
//
//  Created by 曾凌峰 on 2017/2/26.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "PublicTemplateCell.h"
@class DaySelectCell;
@protocol DaySelectCellDelegate <NSObject>
//传回当前选中的indexpath
- (void)DaySelectCell:(DaySelectCell*)cell selectIndex:(NSIndexPath *)indexPath;
@end

@interface DaySelectCell : PublicTemplateCell
@property (nonatomic , weak) id <DaySelectCellDelegate> delegate;

+ (instancetype)DaySelectCellWithTableView:(UITableView *)tableview;

@end
