//
//  MutipleChoiceView.m
//  XiaoYa
//
//  Created by commet on 2017/9/4.
//  Copyright © 2017年 commet. All rights reserved.
//多选列表弹窗

#import "MutipleChoiceView.h"
#import "Utils.h"
#import "Masonry.h"
#import "MutipleChoiceCell.h"

@interface MutipleChoiceView() <UITableViewDelegate ,UITableViewDataSource>
@property (nonatomic , weak) UIButton *confirmBtn;
@property (nonatomic , weak) UIButton *cancelBtn;
@property (nonatomic , weak) UITableView *multipleChoiceTable;
@property (nonatomic , weak) UIView *line1;//横灰线
@property (nonatomic , weak) UIView *line2;//竖灰线

@property (nonatomic ,strong) NSArray *itemData;//单元格内容
@property (strong, nonatomic) NSMutableArray *selectIndexs;//多选选中的行
@property (nonatomic ,assign) CGFloat cellRowHeight;
@end

@implementation MutipleChoiceView
- (instancetype)initWithItems:(NSArray *) items
                selectedIndex:(NSArray *) indexsArray
                    viewWidth:(CGFloat) width
                   cellHeight:(CGFloat) rowHeight
       confirmCancelBtnHeight:(CGFloat) btnHeight
                 confirmBlock:(confirmBlock) confirm
                  cancelBlock:(cancelBlock) cancel
              selectCellBlock:(cellSelectBlock) select
{
    CGFloat height = (items.count>7?7:items.count) * rowHeight + btnHeight;//设置最多显示7行选项
    if (self = [super initWithFrame:CGRectMake(0, 0, width, height)]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10.0;
        self.layer.masksToBounds = YES;
        
        self.itemData = [items copy];
        self.selectIndexs = [indexsArray mutableCopy];
        self.cellRowHeight = rowHeight;
        self.confirmBlock = [confirm copy];
        self.cancelBlock = [cancel copy];
        self.selectBlock = select;
        [self commonInit];
    }
    return self;
}

//确定
- (void)confirmAction{
    [self removeFromSuperview];
    if (self.confirmBlock != nil) {
        self.confirmBlock(self.selectIndexs);
    }
}

//取消,移除视图，什么也不做
- (void)cancelAction{
    [self removeFromSuperview];
    if (self.cancelBlock != nil) {
        self.cancelBlock();
    }
}

#pragma mark viewsetting
- (void)commonInit{
    //单元格固定高度40；7行
    UITableView *multipleChoiceTable = [[UITableView alloc]init];
    _multipleChoiceTable = multipleChoiceTable;
    _multipleChoiceTable.delegate = self;
    _multipleChoiceTable.dataSource = self;
    _multipleChoiceTable.separatorStyle = UITableViewCellSeparatorStyleNone;//去掉原生分割线
    _multipleChoiceTable.bounces = NO;
    [self addSubview:_multipleChoiceTable];
    [_multipleChoiceTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(self.frame.size.width, 280));
        make.centerX.top.equalTo(self);
    }];
    
    UIButton *cancelBtn = [[UIButton alloc]init];
    _cancelBtn = cancelBtn;
    [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:[Utils colorWithHexString:@"#39b9f8"] forState:UIControlStateNormal];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [_cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancelBtn];
    [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(self.frame.size.width/2, 40));
        make.left.bottom.equalTo(self);
    }];
    
    UIButton *confirmBtn = [[UIButton alloc]init];
    _confirmBtn = confirmBtn;
    [_confirmBtn setTitle:@"确认" forState:UIControlStateNormal];
    [_confirmBtn setTitleColor:[Utils colorWithHexString:@"#39b9f8"] forState:UIControlStateNormal];
    _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [_confirmBtn addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_confirmBtn];
    [_confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(self.frame.size.width/2, 40));
        make.right.bottom.equalTo(self);
    }];
    
    UIView *line1 = [[UIView alloc]init];
    _line1 = line1;
    _line1.backgroundColor = [Utils colorWithHexString:@"#d9d9d9"];
    [self addSubview:_line1];
    [_line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_cancelBtn.mas_top);
        make.size.mas_equalTo(CGSizeMake(self.frame.size.width, 0.5));
        make.centerX.equalTo(self);
    }];
    
    UIView *line2 = [[UIView alloc]init];
    _line2 = line2;
    _line2.backgroundColor = [Utils colorWithHexString:@"#d9d9d9"];
    [self addSubview:_line2];
    [_line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(0.5, 40));
        make.centerX.bottom.equalTo(self);
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.cellRowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.itemData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) ws = self;
    MutipleChoiceCell *cell = [MutipleChoiceCell MutipleChoiceCellWithTableView:tableView selectBlock:^(NSIndexPath * indexPath) {
        if (ws.selectBlock != nil) {
            ws.selectBlock(tableView ,ws.selectIndexs ,indexPath);
        }
    } deselectBlock:^(NSIndexPath * indexPath) {
        [ws.selectIndexs removeObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:indexPath.row]]];
    }];
    
    cell.model = self.itemData[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([_selectIndexs containsObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:indexPath.row]]]) {
        [cell.choiceBtn setSelected:YES];
    }else{
        [cell.choiceBtn setSelected:NO];
    }
    return cell;
}

@end
