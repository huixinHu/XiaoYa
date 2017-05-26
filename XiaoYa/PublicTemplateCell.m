//
//  PublicTemplateCell.m
//  XiaoYa
//
//  Created by commet on 16/11/29.
//  Copyright © 2016年 commet. All rights reserved.
//公用的模板单元格

#import "PublicTemplateCell.h"
#import "Masonry.h"
#import "Utils.h"
@interface PublicTemplateCell()
@property (nonatomic , weak)UILabel *item;
//@property (nonatomic , weak)UIButton *choiceBtn;
@end

@implementation PublicTemplateCell

- (void)setModel:(NSString *)model{
    self.item.text = model;
}


//+(instancetype)PublicTemplateCellWithTableView:(UITableView *)tableview{
//    static NSString *ID = @"PublicTemplateCell";
//    PublicTemplateCell *cell = [tableview dequeueReusableCellWithIdentifier:ID];
//    if (cell == nil) {
//        cell = [[PublicTemplateCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
//    }
//    return cell;
//}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubView];
    }
    return self;
}

- (void)initSubView{
//    //底部分割线
    UIView *bottomSeparate = [[UIView alloc]init];
    bottomSeparate.backgroundColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.8 alpha:1.0];//系统分割线颜色
    [self.contentView addSubview:bottomSeparate];
    __weak typeof(self)weakself = self;
    [bottomSeparate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.width.mas_equalTo(weakself.contentView.mas_width);
        make.left.bottom.equalTo(weakself.contentView);
    }];
    
    //事件描述
    UILabel *item = [[UILabel alloc]init];
    _item = item;
    _item.font = [UIFont systemFontOfSize:12];
    _item.text = @"事件描述";
    _item.textColor = [Utils colorWithHexString:@"#333333"];
    [self.contentView addSubview:_item];
    [_item mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakself.contentView.mas_left).offset(22);
        make.centerY.equalTo(weakself.contentView.mas_centerY);
    }];
    //按钮
    UIButton * choiceBtn = [[UIButton alloc]init];
    _choiceBtn = choiceBtn;
    [_choiceBtn setImage:[UIImage imageNamed:@"未选择星期"] forState:UIControlStateNormal];
    [_choiceBtn setImage:[UIImage imageNamed:@"选择星期"] forState:UIControlStateSelected];
    [self.contentView addSubview:_choiceBtn];
    [_choiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.centerY.equalTo(weakself.contentView.mas_centerY);
        make.right.equalTo(weakself.contentView.mas_right).offset(-5);
    }];
}

@end
