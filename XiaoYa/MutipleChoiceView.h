//
//  MutipleChoiceView.h
//  XiaoYa
//
//  Created by commet on 2017/9/4.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 自定义确认block类型

 @param selectIndexs 选中项的数组
 */
typedef void(^confirmBlock)(NSMutableArray * _Nonnull selectIndexs);

/**
 自定义取消block类型
 */
typedef void(^cancelBlock)();

/**
 自定义选中block类型

 @param tableView 列表table
 @param selectIndexs 选中项的数组
 @param indexPath 当前选中项的indexPath
 */
typedef void(^cellSelectBlock)(UITableView * _Nonnull tableView ,NSMutableArray * _Nonnull selectIndexs, NSIndexPath * _Nonnull indexPath);

@interface MutipleChoiceView : UIView

@property (nonatomic ,copy ,nullable) confirmBlock confirmBlock;
@property (nonatomic ,copy ,nullable) cancelBlock cancelBlock;
@property (nonatomic ,copy ,nullable) cellSelectBlock selectBlock;

/**
 多选列表初始化

 @param items 列表内容项
 @param indexsArray 列表已选项
 @param width 视图宽
 @param rowHeight 列表单元格高度
 @param btnHeight 底部确认、取消按钮高度
 @param confirm 确认block
 @param cancel 取消block
 @param select 选择Block
 @return 多选列表
 */
- (nonnull instancetype)initWithItems:(nonnull NSArray *) items
                        selectedIndex:(nonnull NSArray *) indexsArray
                            viewWidth:(CGFloat) width
                           cellHeight:(CGFloat) rowHeight
               confirmCancelBtnHeight:(CGFloat) btnHeight
                         confirmBlock:(nullable confirmBlock) confirm
                          cancelBlock:(nullable cancelBlock) cancel
                      selectCellBlock:(nullable cellSelectBlock) select;

@end
