//
//  RepeatSetting.m
//  XiaoYa
//
//  Created by commet on 16/11/30.
//  Copyright © 2016年 commet. All rights reserved.
//

#import "RepeatSetting.h"
#import "RepeatCell.h"
#import "Utils.h"

@interface RepeatSetting()<UITableViewDelegate,UITableViewDataSource,RepeatCellDelegate>
@property (nonatomic , weak) UIButton *confirm;
@property (nonatomic , weak) UIButton *cancel;
@property (nonatomic , weak) UITableView *singleChoiceTable;
@property (nonatomic , weak) UIView *line1;//横灰线
@property (nonatomic , weak) UIView *line2;//竖灰线

@property (nonatomic ,strong) NSArray *itemData;//单元格文字内容
@property (nonatomic ,assign) NSInteger lastIndex;//上一个选中的行Index
@end

@implementation RepeatSetting

- (instancetype)initWithFrame:(CGRect)frame selectedIndex:(NSInteger)index
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10.0;
        self.layer.masksToBounds = YES;
        
        self.lastIndex = index;
        self.itemData = @[@"每天",@"每两天",@"每周",@"每月",@"每年",@"工作日",@"不重复"];
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
//    _confirm.backgroundColor = [UIColor whiteColor];
    [_confirm addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_confirm];
    
    UIButton *cancel = [[UIButton alloc]init];
    _cancel = cancel;
    [_cancel setTitle:@"取消" forState:UIControlStateNormal];
    [_cancel setTitleColor:[Utils colorWithHexString:@"#39b9f8"] forState:UIControlStateNormal];
    _cancel.titleLabel.font = [UIFont systemFontOfSize:13.0];
//    _cancel.backgroundColor = [UIColor whiteColor];
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
    UITableView *singleChoiceTable = [[UITableView alloc]init];
    _singleChoiceTable = singleChoiceTable;
    _singleChoiceTable.delegate = self;
    _singleChoiceTable.dataSource = self;
    _singleChoiceTable.separatorStyle = UITableViewCellSeparatorStyleNone;//去掉原生分割线
    _singleChoiceTable.bounces = NO;
    [self addSubview:_singleChoiceTable];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RepeatCell *cell = [RepeatCell RepeatCellWithTableView:tableView];
    cell.model = self.itemData[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == self.lastIndex) {
        cell.choiceBtn.selected = YES;
    }
    cell.delegate = self;
    return cell;
}

#pragma mark RepeatCellDelegate
- (void)RepeatCell:(RepeatCell *)cell selectIndex:(NSIndexPath *)indexPath{
    NSUInteger newIndex[] = {0, self.lastIndex};
    NSIndexPath *newPath = [[NSIndexPath alloc] initWithIndexes:newIndex length:2];
    RepeatCell *lastCell = [self.singleChoiceTable cellForRowAtIndexPath:newPath];
    lastCell.choiceBtn.selected = NO;
    self.lastIndex = indexPath.row;
}

//确定
- (void)confirmAction{
    [self removeFromSuperview];
    [self.delegate RepeatSettingComfirmAction:self selectedIndex:self.lastIndex];
}

//取消,移除视图，什么也不做
- (void)cancelAction{
    [self removeFromSuperview];
    [self.delegate RepeatSettingCancelAction:self];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    _confirm.frame = CGRectMake(self.frame.size.width / 2 , self.frame.size.height - 38, self.frame.size.width / 2, 38);
    _cancel.frame = CGRectMake(0, self.frame.size.height - 38, self.frame.size.width / 2, 38);
    _line1.frame = CGRectMake(0, self.frame.size.height - 38, self.frame.size.width, 0.5);
    _line2.frame = CGRectMake(self.frame.size.width / 2, self.frame.size.height - 38, 0.5, 38);
    
    _singleChoiceTable.frame = CGRectMake(0, 0, self.frame.size.width, 40 * 7);
    CGPoint center =  _singleChoiceTable.center;
    center.x = self.frame.size.width/2;
    _singleChoiceTable.center = center;
}

@end
