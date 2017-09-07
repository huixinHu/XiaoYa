//
//  SingleChoiceCell.m
//  XiaoYa
//
//  Created by commet on 2017/9/7.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "SingleChoiceCell.h"
@interface SingleChoiceCell()
@property (nonatomic ,copy) singleSelectedBlock selectBlock;

@end

@implementation SingleChoiceCell

+ (instancetype)SingleChoiceCellWithTableView:(UITableView *)tableview selectBlock:(singleSelectedBlock)select {
    static NSString *ID = @"SingleChoiceCell";
    SingleChoiceCell *cell = [tableview dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[SingleChoiceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID selectBlock:[select copy]];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier selectBlock:(singleSelectedBlock)select {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectBlock = [select copy];
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
        if (self.selectBlock != nil) {
            self.selectBlock(indexPath);
        }
    }
}
@end
