//
//  GroupHomePageCell.m
//  XiaoYa
//
//  Created by commet on 2017/7/9.
//  Copyright © 2017年 commet. All rights reserved.
//群组首页cell

#import "GroupHomePageCell.h"
#import "GroupListModel.h"
#import "GroupInfoModel.h"
#import "Masonry.h"
#import "Utils.h"
@interface GroupHomePageCell()
@property (nonatomic ,weak)UIImageView *avatar;
@property (nonatomic ,weak)UILabel *groupName;
@property (nonatomic ,weak)UILabel *groupMessage;
@property (nonatomic ,weak)UILabel *time;
@property (nonatomic ,weak)UILabel *badge;
@end

@implementation GroupHomePageCell

+ (instancetype)groupHomePageCellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"GroupHomePageCell";
    GroupHomePageCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[GroupHomePageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
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

- (void)setGroup:(GroupListModel *)group{
    _group = group;
    self.groupName.text = [NSString stringWithFormat:@"%@(%@人)",group.groupName,[NSNumber numberWithInteger:group.numberOfMember]];
    switch ([group.groupAvatarId intValue]) {
        case 0:
            self.avatar.image = [UIImage imageNamed:@"头像1"];
            break;
        case 1:
            self.avatar.image = [UIImage imageNamed:@"头像2"];
            break;
        case 2:
            self.avatar.image = [UIImage imageNamed:@"头像3"];
            break;
        default:
            break;
    }
    if (group.groupEvents && group.groupEvents.count > 0){
        self.groupMessage.text = group.groupEvents[0].event;
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyyMMddHHmmss"];
        NSString *publishTime = group.groupEvents[0].publishTime;
        NSDate *date = [df dateFromString:[publishTime substringToIndex:publishTime.length - 4]];
        [df setDateFormat:@"MM月dd日"];
        self.time.text = [df stringFromDate:date];
    }else {
        self.time.text = @" ";
        self.groupMessage.text = @"";
    }
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
    
    UILabel *groupMessage = [[UILabel alloc]init];
    _groupMessage = groupMessage;
    _groupMessage.text = @" ";
    _groupMessage.font = [UIFont systemFontOfSize:14];
    _groupMessage.backgroundColor = [UIColor whiteColor];
    _groupMessage.textColor = [Utils colorWithHexString:@"#999999"];
    [self.contentView addSubview:_groupMessage];
    [_groupMessage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_groupName.mas_left);
        make.top.equalTo(_groupName.mas_bottom).offset(12);
        make.right.equalTo(self.contentView.mas_right).offset(-60);
    }];
    
    UILabel *time = [[UILabel alloc]init];
    _time = time;
    _time.text = @" ";
    _time.font = [UIFont systemFontOfSize:8];
    _time.textAlignment = NSTextAlignmentRight;
    _time.backgroundColor = [UIColor whiteColor];
    _time.textColor = [Utils colorWithHexString:@"#999999"];
    [self.contentView addSubview:_time];
    [_time mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.right.equalTo(self.contentView).offset(-12);
        make.centerY.equalTo(_groupName.mas_centerY);
    }];
    
    UILabel *badge = [[UILabel alloc]init];
    _badge = badge;
    _badge.text = @"5";
    _badge.font = [UIFont systemFontOfSize:10];
    _badge.textColor = [UIColor whiteColor];
    _badge.textAlignment = NSTextAlignmentCenter;
    _badge.backgroundColor = [Utils colorWithHexString:@"#f74d31"];
    [self.contentView addSubview:_badge];
    [_badge mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(19);
        make.right.equalTo(_time.mas_right);
        make.bottom.equalTo(_groupMessage.mas_bottom);
    }];
    _badge.hidden = YES;
}

@end
