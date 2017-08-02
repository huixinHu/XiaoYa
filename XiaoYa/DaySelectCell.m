//
//  DaySelectCell.m
//  XiaoYa
//
//  Created by 曾凌峰 on 2017/2/26.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "DaySelectCell.h"
#import "Utils.h"
@implementation DaySelectCell
+ (instancetype)DaySelectCellWithTableView:(UITableView *)tableview{
    static NSString *ID = @"DaySelectCell";
    DaySelectCell *cell = [tableview dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[DaySelectCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.choiceBtn addTarget:self action:@selector(singleClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)singleClicked:(UIButton *)sender{
    UIView *view1 = [sender superview];
    UIView *view2 = [view1 superview];
    NSIndexPath *indexPath = [(UITableView *)[[view2 superview] superview] indexPathForCell:(UITableViewCell*)view2];
    
    if (!sender.isSelected) {
        sender.selected = YES;
        [self.delegate DaySelectCell:self selectIndex:indexPath];
    }
}
@end
