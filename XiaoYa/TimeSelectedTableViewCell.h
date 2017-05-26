//
//  TimeSelectedTableViewCell.h
//  XiaoYa
//
//  Created by commet on 17/3/10.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TimeSelectedTableViewCell;
@protocol TimeSelectedTableViewCellDelegate <NSObject>
//传回当前选中的indexpath
- (void)TimeSelectedTableViewCell:(TimeSelectedTableViewCell*)cell selectIndex:(NSIndexPath *)indexPath;
//传回当前撤销选中的IndexPath
- (void)TimeSelectedTableViewCell:(TimeSelectedTableViewCell*)cell deSelectIndex:(NSIndexPath *)indexPath;
@end

@interface TimeSelectedTableViewCell : UITableViewCell
@property (nonatomic , weak)UIButton *conflict;
@property (nonatomic , weak) id <TimeSelectedTableViewCellDelegate> delegate;

//类初始化方法
+(instancetype)TimeSelectCellWithTableView:(UITableView *)tableview;
//参数1：数组：时间段、节数、课程内容；参数2：现选择的行；参数3：现选择星期几；参数4：原选择的行；参数5：原选择星期几 参数6：indexpath row
- (void)itemData:(NSMutableArray *)timeData selectIndexs:(NSMutableArray* )selectIndexs selectedWeekday:(NSInteger)weekday originIndexs:(NSMutableArray*)originIndexs originWeekday:(NSInteger)originWeekday indexPathRow:(NSInteger)row;
@end
