//
//  GroupSearchTableViewCell.m
//  XiaoYa
//
//  Created by commet on 2017/7/13.
//  Copyright © 2017年 commet. All rights reserved.
//查找群组 搜索结果cell

#import "GroupSearchTableViewCell.h"
#import "GroupSearchModel.h"
#import "Masonry.h"
#import "Utils.h"

@interface GroupSearchTableViewCell()
@property (nonatomic ,weak)UIImageView *avatar;
@property (nonatomic ,weak)UILabel *groupName;
@property (nonatomic ,weak)UILabel *groupManager;
@property (nonatomic ,weak)UIButton *joinBtn;
@end

@implementation GroupSearchTableViewCell

+ (instancetype)GroupSearchCellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"GroupSearchTableViewCell";
    GroupSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[GroupSearchTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubView];
    }
    return self;
}

- (void)setModel:(GroupSearchModel *)model{
    _model = model;
    self.groupName.text = model.groupName;
    self.groupManager.text = [NSString stringWithFormat:@"群主：%@",model.managerName];
    switch ([model.avatarId intValue]) {
        case 0:
            self.avatar.image = [UIImage imageNamed:@"删除勾选"];
           break;
        case 1:
            self.avatar.image = [UIImage imageNamed:@"删除圆"];
            break;
        case 2:
            self.avatar.image = [UIImage imageNamed:@"删除不勾选"];
            break;

        default:
            break;
    }
}

- (void)join:(UIButton *)sender{
    UIView *view1 = [sender superview];
    UIView *view2 = [view1 superview];
    NSIndexPath *indexPath = [(UITableView *)[[view2 superview] superview] indexPathForCell:(UITableViewCell*)view2];
    [self.delegate groupSearchCell:self selectIndex:indexPath];
}

- (void)initSubView{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *avatar = [[UIImageView alloc]init];
    _avatar = avatar;
    [self.contentView addSubview:_avatar];
    [_avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.contentView.mas_left).offset(10);
    }];
    
    UILabel *groupName = [[UILabel alloc]init];
    _groupName = groupName;
    _groupName.text = @" ";
    _groupName.font = [UIFont systemFontOfSize:16];
    _groupName.backgroundColor = [UIColor whiteColor];
    _groupName.textColor = [Utils colorWithHexString:@"#333333"];
    [self.contentView addSubview:_groupName];
    [_groupName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_avatar.mas_right).offset(13);
        make.top.equalTo(self.contentView).offset(13);
        make.right.equalTo(self.contentView.mas_right).offset(-60);
    }];
    
    UILabel *groupManager = [[UILabel alloc]init];
    _groupManager = groupManager;
    _groupManager.text = @" ";
    _groupManager.font = [UIFont systemFontOfSize:14];
    _groupManager.backgroundColor = [UIColor whiteColor];
    _groupManager.textColor = [Utils colorWithHexString:@"#999999"];
    [self.contentView addSubview:_groupManager];
    [_groupManager mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_groupName);
        make.top.equalTo(_groupName.mas_bottom).offset(8);
        make.right.equalTo(self.contentView.mas_right).offset(-60);
    }];
    
    UIButton *joinBtn = [[UIButton alloc]init];
    _joinBtn = joinBtn;
    _joinBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [_joinBtn setTitle:@"加入" forState:UIControlStateNormal];
    [_joinBtn setTitleColor:[Utils colorWithHexString:@"#00a7fa"] forState:UIControlStateNormal];
    [_joinBtn addTarget:self action:@selector(join:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_joinBtn];
    [_joinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.right.equalTo(self.contentView).offset(-13);
        make.centerY.equalTo(self.contentView);
    }];
    
    UIView *separatorLine = [[UIView alloc]init];
    separatorLine.backgroundColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.78 alpha:1.0];
    [self.contentView addSubview:separatorLine];
    [separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_groupName);
        make.bottom.right.equalTo(self.contentView);
        make.height.mas_equalTo(0.5);
    }];
}

@end
