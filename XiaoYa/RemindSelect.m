//
//  RemindSelect.m
//  XiaoYa
//
//  Created by commet on 16/11/30.
//  Copyright © 2016年 commet. All rights reserved.
//提醒选择

#import "RemindSelect.h"
//#import "PublicTemplateCell.h"
#import "RemindCell.h"
#import "Utils.h"

@interface RemindSelect()<UITableViewDelegate,UITableViewDataSource,RemindCellDelegate>
@property (nonatomic , weak) UIButton *confirm;
@property (nonatomic , weak) UIButton *cancel;
@property (nonatomic , weak) UITableView *multipleChoiceTable;
@property (nonatomic , weak) UIView *line1;//横灰线
@property (nonatomic , weak) UIView *line2;//竖灰线

@property (nonatomic ,strong) NSArray *itemData;//单元格文字内容
@property (strong, nonatomic) NSMutableArray *selectIndexs;//多选选中的行
@end

@implementation RemindSelect
- (instancetype)initWithFrame:(CGRect)frame selectedIndex:(NSArray *)indexsArray
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10.0;
        self.layer.masksToBounds = YES;

        self.selectIndexs = [indexsArray mutableCopy];
        self.itemData = @[@"当事件发生时",@"5分钟前",@"15分钟前",@"30分钟前",@"1小时前",@"1天前",@"不提醒"];
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    UIButton *confirm = [[UIButton alloc]init];
    _confirm = confirm;
    [_confirm setTitle:@"确认" forState:UIControlStateNormal];
    [_confirm setTitleColor:[Utils colorWithHexString:@"#39b9f8"] forState:UIControlStateNormal];
    _confirm.titleLabel.font = [UIFont systemFontOfSize:13.0];
    _confirm.backgroundColor = [UIColor whiteColor];
    [_confirm addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_confirm];
    
    UIButton *cancel = [[UIButton alloc]init];
    _cancel = cancel;
    [_cancel setTitle:@"取消" forState:UIControlStateNormal];
    [_cancel setTitleColor:[Utils colorWithHexString:@"#39b9f8"] forState:UIControlStateNormal];
    _cancel.titleLabel.font = [UIFont systemFontOfSize:13.0];
    _cancel.backgroundColor = [UIColor whiteColor];
    [_cancel addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancel];
    
    UIView *line1 = [[UIView alloc]init];
    _line1 = line1;
    _line1.backgroundColor = [Utils colorWithHexString:@"#d9d9d9"];
    [self addSubview:_line1];
    
    UIView *line2 = [[UIView alloc]init];
    _line2 = line2;
    _line2.backgroundColor = [Utils colorWithHexString:@"#d9d9d9"];
    [self addSubview:_line2];
    
    //单元格固定高度40；7行
    UITableView *multipleChoiceTable = [[UITableView alloc]init];
    _multipleChoiceTable = multipleChoiceTable;
    _multipleChoiceTable.delegate = self;
    _multipleChoiceTable.dataSource = self;
    _multipleChoiceTable.separatorStyle = UITableViewCellSeparatorStyleNone;//去掉原生分割线
    _multipleChoiceTable.bounces = NO;
    [self addSubview:_multipleChoiceTable];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RemindCell *cell = [RemindCell RemindCellWithTableView:tableView];
    cell.model = self.itemData[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    if ([_selectIndexs containsObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:indexPath.row]]]) {
        [cell.choiceBtn setSelected:YES];
    }else{
        [cell.choiceBtn setSelected:NO];
    }
    return cell;
}

#pragma mark RemindCellDelegate
- (void)RemindCell:(RemindCell*)cell selectIndex:(NSIndexPath *)indexPath{
    if(indexPath.row == 6){
        [self.selectIndexs removeAllObjects];
        [self.selectIndexs addObject:@"6"];
        [_multipleChoiceTable reloadData];
    }else{
        [self.selectIndexs addObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:indexPath.row]]];
        if ([self.selectIndexs containsObject:@"6"]) {
            [self.selectIndexs removeObject:@"6"];
            [_multipleChoiceTable reloadData];
        }
    }
}

- (void)RemindCell:(RemindCell*)cell deSelectIndex:(NSIndexPath *)indexPath{
    [self.selectIndexs removeObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:indexPath.row]]];
}

//确定
- (void)confirmAction{
    [self removeFromSuperview];
    [self.delegate RemindSelectComfirmAction:self indexArr:self.selectIndexs];
}

//取消,移除视图，什么也不做
- (void)cancelAction{
    [self removeFromSuperview];
    [self.delegate RemindSelectCancelAction:self];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    _confirm.frame = CGRectMake(self.frame.size.width / 2, self.frame.size.height - 38, self.frame.size.width / 2, 38);
    _cancel.frame = CGRectMake(0, self.frame.size.height - 38, self.frame.size.width / 2, 38);
    _line1.frame = CGRectMake(0, self.frame.size.height - 38, self.frame.size.width, 0.5);
    _line2.frame = CGRectMake(self.frame.size.width / 2, self.frame.size.height - 38, 0.5, 38);
    
    _multipleChoiceTable.frame = CGRectMake(0, 0, self.frame.size.width, 40 * 7);
    CGPoint center =  _multipleChoiceTable.center;
    center.x = self.frame.size.width/2;
    _multipleChoiceTable.center = center;
}


@end
