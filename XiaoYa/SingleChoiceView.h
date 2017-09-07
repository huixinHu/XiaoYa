//
//  SingleChoiceView.h
//  XiaoYa
//
//  Created by commet on 2017/9/7.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 自定义确认block类型
 
 @param selectIndexs 选中项的数组
 */
typedef void(^singleConfirmBlock)(NSInteger selectedIndex);

/**
 自定义取消block类型
 */
typedef void(^singleCancelBlock)();

@interface SingleChoiceView : UIView

@property (nonatomic ,copy ,nullable) singleConfirmBlock confirmBlock;
@property (nonatomic ,copy ,nullable) singleCancelBlock cancelBlock;

/**
 多选列表初始化
 
 @param items 列表内容项
 @param indexsArray 列表已选项
 @param width 视图宽
 @param rowHeight 列表单元格高度
 @param btnHeight 底部确认、取消按钮高度
 @param confirm 确认block
 @param cancel 取消block
 @return 多选列表
 */
- (nonnull instancetype)initWithItems:(nonnull NSArray *) items
                        selectedIndex:(NSInteger) index
                            viewWidth:(CGFloat) width
                           cellHeight:(CGFloat) rowHeight
               confirmCancelBtnHeight:(CGFloat) btnHeight
                         confirmBlock:(nullable singleConfirmBlock) confirm
                          cancelBlock:(nullable singleCancelBlock) cancel;
@end
