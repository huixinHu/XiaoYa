//
//  SingleChoiceCell.h
//  XiaoYa
//
//  Created by commet on 2017/9/7.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "PublicTemplateCell.h"

/**
 自定义选中block
 
 @param indexPath 当前选中项的indexPath
 */
typedef void(^singleSelectedBlock)(NSIndexPath * _Nullable indexPath);

@interface SingleChoiceCell : PublicTemplateCell

/**
 单选单元格初始化
 
 @param tableview tableview
 @param select 选中的block
 @return 多选单元格
 */
+ (nonnull instancetype)SingleChoiceCellWithTableView:(nonnull UITableView *)tableview selectBlock:(nullable singleSelectedBlock)select;
@end
