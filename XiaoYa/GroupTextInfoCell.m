//
//  GroupTextInfoCell.m
//  XiaoYa
//
//  Created by commet on 2017/11/14.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "GroupTextInfoCell.h"
#import "GroupInfoModel.h"
#import "Masonry.h"
#import "Utils.h"

@interface GroupTextInfoCell()
@property (nonatomic ,weak) UILabel *publishTime;
@property (nonatomic ,weak) UILabel *event;
@end

@implementation GroupTextInfoCell
- (void)setModel:(GroupInfoModel *)model{
    self.publishTime.text = [self publishTimeToFormatStr:model.publishTime];
    self.event.text = model.event;
}

//把发布时间转换为特定格式时间字符串
- (NSString *)publishTimeToFormatStr:(NSString *)publishTime{
    if (!publishTime) {
        return nil;
    }
    publishTime = [publishTime substringToIndex:publishTime.length-4];
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date = [df dateFromString:publishTime];
    [df setDateFormat:@"yyyy-MM-dd\nHH:mm"];
    return [df stringFromDate:date];
}

+ (instancetype)GroupTextInfoCellWithTableView:(UITableView *)tableView{
    static NSString *ID = @"GroupTextInfoCell";
    GroupTextInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[GroupTextInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    //时间轴
    UIView *verLine1 = [[UIView alloc]init];
    verLine1.backgroundColor = [Utils colorWithHexString:@"#d9d9d9"];
    [self.contentView addSubview:verLine1];
    [verLine1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(75);
        make.top.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(2, 15));
    }];
    UIView *circle = [[UIView alloc]init];
    circle.backgroundColor = [Utils colorWithHexString:@"#00a7fa"];
    circle.layer.cornerRadius = 5;
    [self.contentView addSubview:circle];
    [circle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(verLine1);
        make.top.equalTo(verLine1.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(10, 10));
    }];

    //信息部分
    UILabel *publishTime = [[UILabel alloc]init];
    _publishTime = publishTime;
    _publishTime.textColor = [Utils colorWithHexString:@"#333333"];
    _publishTime.font = [UIFont systemFontOfSize:11];
    _publishTime.lineBreakMode = NSLineBreakByWordWrapping;
    _publishTime.numberOfLines = 0;
    _publishTime.text = @"2016-8-20\n23:00";
    _publishTime.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_publishTime];
    [_publishTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(circle);
        make.right.equalTo(circle.mas_left).offset(-5);
    }];
    
    UILabel *event = [[UILabel alloc]init];
    _event = event;
    _event.text = @" ";
    _event.textColor = [Utils colorWithHexString:@"#666666"];
    _event.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:_event];
    [_event mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(circle.mas_right).offset(5);
        make.right.equalTo(self.contentView).offset(-10);
        make.centerY.equalTo(circle.mas_centerY);
    }];
}
@end
