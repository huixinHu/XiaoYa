//
//  MemberSearchTableViewCell.m
//  XiaoYa
//
//  Created by commet on 2017/7/25.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "MemberSearchTableViewCell.h"
#import "Utils.h"
#import "Masonry.h"
#import "GroupMemberModel.h"

@interface MemberSearchTableViewCell ()
@property (nonatomic ,weak) UIImageView *memberAvatar;
@property (nonatomic ,weak) UILabel *memberInfo;
@property (nonatomic ,strong) NSMutableArray *addedModels;
@end

@implementation MemberSearchTableViewCell

+ (instancetype)MemberSearchCellWithTableView:(UITableView *)tableView selectBlock:(selectedBlock)select deselectBlock:(deselectedBlock)deselect addedMembers:(NSMutableArray *)addedModels{
    static NSString *ID = @"MemberSearchTableViewCell";
    MemberSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[MemberSearchTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID selectBlock:[select copy] deselectBlock:[deselect copy] addedMembers:addedModels];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier selectBlock:(selectedBlock)select deselectBlock:(deselectedBlock)deselect addedMembers:(NSMutableArray *)addedModels{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectBlock = select;
        self.deselectBlock = deselect;
        self.addedModels = [addedModels mutableCopy];
        [self commonInit];
    }
    return self;
}

- (void)setMember:(GroupMemberModel *)member{
    _member = member;
    self.memberInfo.text = [NSString stringWithFormat:@"%@(%@)",member.memberName,member.memberPhone];
    self.memberAvatar.image = member.memberAvatar;
    for (GroupMemberModel *addedModel in self.addedModels) {
        if ([addedModel.memberPhone isEqualToString:member.memberPhone]) {
            self.selectBtn.enabled = NO;
            break;
        }else{
            self.selectBtn.enabled = YES;
        }
    }
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
    } else{
        sender.selected = YES;
        if (self.selectBlock != nil) {
            self.selectBlock(indexPath);
        }
    }
}

- (void)commonInit{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIButton * selectBtn = [[UIButton alloc]init];
    _selectBtn = selectBtn;
    [_selectBtn setImage:[UIImage imageNamed:@"添加新成员未勾选"] forState:UIControlStateNormal];
    [_selectBtn setImage:[UIImage imageNamed:@"添加新成员选中"] forState:UIControlStateSelected];
    [_selectBtn setImage:[UIImage imageNamed:@"删除不勾选"] forState:UIControlStateDisabled];
    [_selectBtn addTarget:self action:@selector(mutipleClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_selectBtn];
    [_selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(7);
    }];
    
    UIImageView *memberAvatar = [[UIImageView alloc]init];
    _memberAvatar = memberAvatar;
    [self.contentView addSubview:_memberAvatar];
    [_memberAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(35, 35));
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(_selectBtn.mas_right);
    }];
    
    UILabel * memberInfo = [[UILabel alloc]init];
    _memberInfo = memberInfo;
    _memberInfo.text = @" ";
    _memberInfo.font = [UIFont systemFontOfSize:14];
    _memberInfo.textColor = [Utils colorWithHexString:@"#333333"];
    [self.contentView addSubview:_memberInfo];
    [_memberInfo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(_memberAvatar.mas_right).offset(15);
    }];
    
    UIView *separatorLine = [[UIView alloc]init];
    separatorLine.backgroundColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.78 alpha:1.0];
    [self.contentView addSubview:separatorLine];
    [separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_memberInfo);
        make.bottom.right.equalTo(self.contentView);
        make.height.mas_equalTo(0.5);
    }];
}

- (NSMutableArray *)addedModels{
    if (_addedModels == nil) {
        _addedModels = [NSMutableArray array];
    }
    return _addedModels;
}
@end
