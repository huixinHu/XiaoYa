//
//  RemindCell.m
//  XiaoYa
//
//  Created by commet on 16/11/30.
//  Copyright © 2016年 commet. All rights reserved.
//

#import "RemindCell.h"

@implementation RemindCell

+(instancetype)RemindCellWithTableView:(UITableView *)tableview{
    static NSString *ID = @"RemindCell";
    RemindCell *cell = [tableview dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[RemindCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.choiceBtn addTarget:self action:@selector(mutipleClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)mutipleClicked:(UIButton *)sender{
    UIView *view1 = [sender superview];
    UIView *view2 = [view1 superview];
    NSIndexPath *indexPath = [(UITableView *)[[view2 superview] superview] indexPathForCell:(UITableViewCell*)view2];
    
    if (sender.isSelected) {//已经选中了
        sender.selected = NO;//置为未选中
        [self.delegate RemindCell:self deSelectIndex:indexPath];
    }else{
        sender.selected = YES;
        [self.delegate RemindCell:self selectIndex:indexPath];
    }
}

@end
