//
//  SectionSelectTableViewCell.h
//  XiaoYa
//
//  Created by commet on 16/11/28.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SectionSelectTableViewCell;
@protocol SectionSelectTableViewCellDelegate <NSObject>
//传回当前选中的indexpath
- (void)SectionSelectTableViewCell:(SectionSelectTableViewCell*)cell selectIndex:(NSIndexPath *)indexPath;
//传回当前撤销选中的IndexPath
- (void)SectionSelectTableViewCell:(SectionSelectTableViewCell*)cell deSelectIndex:(NSIndexPath *)indexPath;
@end

@interface SectionSelectTableViewCell : UITableViewCell
@property (nonatomic , weak)UIButton *mutipleChoice;//复选按钮
@property (nonatomic , weak)UIButton *conflict;
@property (nonatomic , strong)NSArray *model;//模型
@property (nonatomic , weak) id <SectionSelectTableViewCellDelegate> delegate;
//类初始化方法
+(instancetype)SectionCellWithTableView:(UITableView *)tableview;
@end
