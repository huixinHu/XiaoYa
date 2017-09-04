//
//  MutipleChoiceCell.h
//  XiaoYa
//
//  Created by commet on 2017/9/4.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "PublicTemplateCell.h"

/**
 自定义选中block

 @param indexPath 当前选中项的indexPath
 */
typedef void(^selectedBlock)(NSIndexPath * _Nullable indexPath);

/**
 自定义取消选中block

 @param indexPath 当前取消选中项的indexPath
 */
typedef void(^deselectedBlock)(NSIndexPath * _Nullable indexPath);

@interface MutipleChoiceCell : PublicTemplateCell

/**
 多选单元格初始化

 @param tableview tableview
 @param select 选中的block
 @param deselect 取消选中的block
 @return 多选单元格
 */
+ (nonnull instancetype)MutipleChoiceCellWithTableView:(nonnull UITableView *)tableview selectBlock:(nullable selectedBlock)select deselectBlock:(nullable deselectedBlock)deselect;
@end
