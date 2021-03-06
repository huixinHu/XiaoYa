//
//  PublicTemplateCell.m
//  XiaoYa
//
//  Created by commet on 16/11/29.
//  Copyright © 2016年 commet. All rights reserved.
//单选、多选列表弹窗公用的模板单元格

#import "PublicTemplateCell.h"
#import "Masonry.h"
#import "Utils.h"
@interface PublicTemplateCell()
@property (nonatomic , weak)UILabel *item;
@end

@implementation PublicTemplateCell

- (void)setModel:(NSString *)model{
    self.item.text = model;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubView];
    }
    return self;
}

- (void)initSubView{
    //底部分割线
    UIView *bottomSeparate = [[UIView alloc]init];
    bottomSeparate.backgroundColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.8 alpha:1.0];//系统分割线颜色
    [self.contentView addSubview:bottomSeparate];
    [bottomSeparate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.width.mas_equalTo(self.contentView.mas_width);
        make.left.bottom.equalTo(self.contentView);
    }];
    
    //事件描述
    UILabel *item = [[UILabel alloc]init];
    _item = item;
    _item.font = [UIFont systemFontOfSize:12];
    _item.text = @"事件描述";
    _item.textColor = [Utils colorWithHexString:@"#333333"];
    [self.contentView addSubview:_item];
    [_item mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(22);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    //按钮
    UIButton * choiceBtn = [[UIButton alloc]init];
    _choiceBtn = choiceBtn;
    [_choiceBtn setImage:[UIImage imageNamed:@"未选择星期"] forState:UIControlStateNormal];
    [_choiceBtn setImage:[UIImage imageNamed:@"选择星期"] forState:UIControlStateSelected];
    [self.contentView addSubview:_choiceBtn];
    [_choiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-5);
    }];
}

@end
