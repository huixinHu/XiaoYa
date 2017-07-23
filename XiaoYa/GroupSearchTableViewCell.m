//
//  GroupSearchTableViewCell.m
//  XiaoYa
//
//  Created by commet on 2017/7/13.
//  Copyright © 2017年 commet. All rights reserved.
//查找群组 搜索结果cell

#import "GroupSearchTableViewCell.h"
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

//- (void)setGroup:(GroupListModel *)group{
//    _group = group;
//    self.groupName.text = group.groupName;
//    self.groupMessage.text = group.groupMessage;
//    self.time.text = group.time;
//}

- (void)initSubView{
    __weak typeof(self)weakself = self;
    UIImageView *avatar = [[UIImageView alloc]init];
    _avatar = avatar;
    _avatar.backgroundColor = [UIColor yellowColor];
    [self.contentView addSubview:_avatar];
    [_avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.centerY.equalTo(weakself.contentView.mas_centerY);
        make.left.equalTo(weakself.contentView.mas_left).offset(10);
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
        make.top.equalTo(weakself.contentView).offset(13);
        make.right.equalTo(weakself.contentView.mas_right).offset(-60);
    }];
    
    UILabel *groupManager = [[UILabel alloc]init];
    _groupManager = groupManager;
    _groupManager.text = @" ";
    _groupManager.font = [UIFont systemFontOfSize:14];
    _groupManager.backgroundColor = [UIColor whiteColor];
    _groupManager.textColor = [Utils colorWithHexString:@"#999999"];
    [self.contentView addSubview:_groupManager];
    [_groupManager mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_groupName.mas_left);
        make.top.equalTo(_groupName.mas_bottom).offset(12);
        make.right.equalTo(weakself.contentView.mas_right).offset(-60);
    }];
    
    UIButton *joinBtn = [[UIButton alloc]init];
    _joinBtn = joinBtn;
    _joinBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [_joinBtn setTitle:@"加入" forState:UIControlStateNormal];
    [_joinBtn setTitleColor:[Utils colorWithHexString:@"#7df3fc"] forState:UIControlStateNormal];
    [self.contentView addSubview:_joinBtn];
    [_joinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.right.equalTo(weakself.contentView).offset(-13);
        make.centerY.equalTo(weakself.contentView);
    }];
}

@end
