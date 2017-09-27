//
//  MemberCollectionViewCell.m
//  XiaoYa
//
//  Created by commet on 2017/7/11.
//  Copyright © 2017年 commet. All rights reserved.
//“添加成员”collectionview cell

#import "MemberCollectionViewCell.h"
#import "GroupMemberModel.h"
#import "Utils.h"
#import "Masonry.h"
@interface MemberCollectionViewCell()
@property (nonatomic ,weak)UIImageView *memberAvatar;
@property (nonatomic ,weak)UILabel *memberName;
@end

@implementation MemberCollectionViewCell

- (instancetype )initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    UIImageView *memberAvatar = [[UIImageView alloc]init];
    _memberAvatar = memberAvatar;
    _memberAvatar.image = [UIImage imageNamed:@"未登录头像"];
    [self.contentView addSubview:_memberAvatar];
    [_memberAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.centerX.top.equalTo(self.contentView);
    }];
    
    UILabel *memberName = [[UILabel alloc]init];
    _memberName = memberName;
    _memberName.textAlignment = NSTextAlignmentCenter;
    _memberName.font = [UIFont systemFontOfSize:14];
    _memberName.textColor = [Utils colorWithHexString:@"#333333"];
    [self.contentView addSubview:_memberName];
    [_memberName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_memberAvatar.mas_bottom).offset(8);
        make.centerX.equalTo(self.contentView);
    }];
    
    UIButton *deleteSelect = [[UIButton alloc]init];
    _deleteSelect = deleteSelect;
    [_deleteSelect setImage:[UIImage imageNamed:@"删除勾选"] forState:UIControlStateSelected];
    [_deleteSelect setImage:[UIImage imageNamed:@"删除不勾选"] forState:UIControlStateNormal];
    [_memberAvatar addSubview:_deleteSelect];
    [_deleteSelect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(22.5, 22.5));
        make.top.right.equalTo(_memberAvatar);
    }];
    _deleteSelect.hidden = YES;
}

- (void)setModel:(GroupMemberModel *)model{
    _model = model;
    self.memberAvatar.image = model.memberAvatar;
    self.memberName.text = model.memberName;
}
@end
