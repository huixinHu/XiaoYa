//
//  RepeatCell.m
//  XiaoYa
//
//  Created by commet on 16/11/30.
//  Copyright © 2016年 commet. All rights reserved.
//

#import "RepeatCell.h"

@implementation RepeatCell

+(instancetype)RepeatCellWithTableView:(UITableView *)tableview{
    static NSString *ID = @"RepeatCell";
    RepeatCell *cell = [tableview dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[RepeatCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
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
        [self.delegate RepeatCell:self selectIndex:indexPath];
    }
}
@end
