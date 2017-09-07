//
//  MutipleChoiceCell.m
//  XiaoYa
//
//  Created by commet on 2017/9/4.
//  Copyright © 2017年 commet. All rights reserved.
//多选列表弹窗的单元格

#import "MutipleChoiceCell.h"
@interface MutipleChoiceCell ()
@property (nonatomic ,copy) selectedBlock selectBlock;
@property (nonatomic ,copy) deselectedBlock deselectBlock;
@end

@implementation MutipleChoiceCell

+ (instancetype)MutipleChoiceCellWithTableView:(UITableView *)tableview selectBlock:(selectedBlock)select deselectBlock:(deselectedBlock)deselect {
    static NSString *ID = @"MutipleChoiceCell";
    MutipleChoiceCell *cell = [tableview dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[MutipleChoiceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID selectBlock:[select copy] deselectBlock:[deselect copy]];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier selectBlock:(selectedBlock)select deselectBlock:(deselectedBlock)deselect {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectBlock = [select copy];
        self.deselectBlock = [deselect copy];
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
        if (self.deselectBlock != nil) {
            self.deselectBlock(indexPath);
        }
    }else{
        sender.selected = YES;
        if (self.selectBlock != nil) {
            self.selectBlock(indexPath);
        }
    }
}
@end
