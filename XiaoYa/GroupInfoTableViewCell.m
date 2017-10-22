//
//  GroupInfoTableViewCell.m
//  XiaoYa
//
//  Created by commet on 2017/7/31.
//  Copyright © 2017年 commet. All rights reserved.
//群组消息页的cell

#import "GroupInfoTableViewCell.h"
#import "Utils.h"
#import "DateUtils.h"
#import "NSDate+Calendar.h"
#import "Masonry.h"
#import "GroupInfoModel.h"
#import "AppDelegate.h"
@interface GroupInfoTableViewCell()
@property (nonatomic ,weak) UILabel *publishTime;
@property (nonatomic ,weak) UIButton *infoPresentBtn;
@property (nonatomic ,weak) UILabel *publisher;
@property (nonatomic ,weak) UILabel *event;
@property (nonatomic ,weak) UILabel *eventTime;
@property (nonatomic ,weak) UILabel *replyTag;
@property (nonatomic ,weak) UILabel *remainTime;
@property (nonatomic ,weak) UIButton *replyDetail;

@property (nonatomic ,copy) GroupInfoDetail detailBlock;
@property (nonatomic ,strong) NSDate *firstDateOfTerm;
@end

@implementation GroupInfoTableViewCell
- (void)setModel:(GroupInfoModel *)model{
    self.publishTime.text = [self publishTimeToFormatStr:model.publishTime];
    self.publisher.text = [NSString stringWithFormat:@"发布者：%@",[[model.publisher componentsSeparatedByString:@"("] firstObject]];
    self.event.text = [NSString stringWithFormat:@"事件：%@", model.event];
    self.eventTime.text = [NSString stringWithFormat:@"时间：%@", [self eventTimeToFormatStr:model.eventDate eventSection:model.eventSection]];
    self.remainTime.text = [NSString stringWithFormat:@"剩余回复时间：%@", [self dlTimeToFormatStr:model.deadlineTime]];
    //应有计时器刷新剩余回复时间界面的显示？
}

//把发布时间转换为特定格式时间字符串
-(NSString *)publishTimeToFormatStr:(NSDate *)date{
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd\nHH:mm"];
    return [df stringFromDate:date];
}

//把截止回复时间转换为剩余回复时间格式
- (NSString *)dlTimeToFormatStr:(NSString *)dlTimeStr{
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyyMMddHHmm"];
    int ti = [[df dateFromString:dlTimeStr] timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970];
    NSString *formatStr = [NSString string];
    if (ti < 0) {
        formatStr = @"0天0小时0分";
    } else{
        int day = ti / (24 * 3600);
        int hour = (ti%(24*3600))/3600;
        int minute = ((ti%(24*3600))%3600)/60;
        formatStr = [NSString stringWithFormat:@"%d天%d小时%d分", day, hour, minute];
    }
    return formatStr;
}

- (NSString *)eventTimeToFormatStr:(NSString *)eventTime eventSection:(NSMutableArray *)secArr{
    //这里基本照抄 事务管理 对应的逻辑
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyyMMdd"];
    NSDate * eventDate = [df dateFromString:eventTime];//日期 年月日
    NSString * dayStr = [eventDate dayOfCHNWeek];//周几
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *curDateComp = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:eventDate];
    NSInteger month = curDateComp.month;//月
    NSInteger day = curDateComp.day;//日
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger dateDistance = [DateUtils dateDistanceFromDate:eventDate toDate:appDelegate.firstDateOfTerm];
    NSInteger week = dateDistance / 7 + 1;
    if (week < 1 || week > 24){
        return [NSString stringWithFormat:@"第 周 周%@ %@月%@日 %@节",dayStr,[NSNumber numberWithInteger:month],[NSNumber numberWithInteger:day],[Utils sectionArrToFormatStr:secArr]];
    }else{
        return [NSString stringWithFormat:@"第%@周 周%@ %@月%@日 %@节",[NSNumber numberWithInteger:week],dayStr,[NSNumber numberWithInteger:month],[NSNumber numberWithInteger:day],[Utils sectionArrToFormatStr:secArr]];
    }
}

+ (instancetype)GroupInfoCellWithTableView:(UITableView *)tableView eventDetailBlock:(GroupInfoDetail)block{
    static NSString *ID = @"GroupInfoTableViewCell";
    GroupInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[GroupInfoTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID eventDetailBlock:[block copy]];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier eventDetailBlock:(GroupInfoDetail)block{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.detailBlock = [block copy];
        [self commonInit];
    }
    return self;
}

- (void)eventDetail:(UIButton *)sender{
    self.detailBlock(self.model);
}

#pragma mark viewsSetting
- (void)commonInit{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    self.backgroundColor = [Utils colorWithHexString:@"#f0f0f6"];
    self.backgroundColor = [UIColor clearColor];
    //时间轴
    UIView *verLine1 = [[UIView alloc]init];
    verLine1.backgroundColor = [Utils colorWithHexString:@"#d9d9d9"];
    [self.contentView addSubview:verLine1];
    [verLine1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(75);
        make.top.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(2, 20));
    }];
    UIView *circle = [[UIView alloc]init];
    circle.backgroundColor = [Utils colorWithHexString:@"#00a7fa"];
    circle.layer.cornerRadius = 5;
    [self.contentView addSubview:circle];
    [circle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(verLine1);
        make.top.equalTo(verLine1.mas_bottom).offset(3);
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
    
    UIButton *infoPresentBtn = [[UIButton alloc]init];
    _infoPresentBtn = infoPresentBtn;
    [_infoPresentBtn setBackgroundImage:[[UIImage imageNamed:@"信息框"] resizableImageWithCapInsets:UIEdgeInsetsMake(10 ,10 ,10 ,10)] forState:UIControlStateNormal];
    [_infoPresentBtn addTarget:self action:@selector(eventDetail:) forControlEvents:UIControlEventTouchUpInside];//查看详情
    [self.contentView addSubview:_infoPresentBtn];
    [_infoPresentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(8.5);
        make.left.equalTo(verLine1.mas_right).offset(12);
        make.right.equalTo(self.contentView).offset(-12);
        make.height.mas_equalTo(95.5);
    }];
    
    UILabel *publisher = [[UILabel alloc]init];
    _publisher = publisher;
    _publisher.text = @"发布者：";
    _publisher.textColor = [Utils colorWithHexString:@"#333333"];
    _publisher.font = [UIFont systemFontOfSize:15];
    [self.infoPresentBtn addSubview:_publisher];
    [_publisher mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_infoPresentBtn).offset(11);
        make.left.equalTo(_infoPresentBtn).offset(17);
        make.right.equalTo(_infoPresentBtn).offset(-50);
    }];
    
    UILabel *replyTag = [[UILabel alloc]init];
    _replyTag = replyTag;
    _replyTag.text = @"未回复";
    _replyTag.textColor = [Utils colorWithHexString:@"#666666"];
    _replyTag.font = [UIFont systemFontOfSize:13];
    [self.infoPresentBtn addSubview:_replyTag];
    [_replyTag mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_publisher);
        make.right.equalTo(_infoPresentBtn).offset(-14);
    }];
    
    UILabel *event = [[UILabel alloc]init];
    _event = event;
    _event.text = @"事件：";
    _event.textColor = [Utils colorWithHexString:@"#333333"];
    _event.font = [UIFont systemFontOfSize:13];
    [self.infoPresentBtn addSubview:_event];
    [_event mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_publisher);
        make.top.equalTo(_publisher.mas_bottom).offset(15);
        make.right.equalTo(_replyTag);
    }];
    
    UILabel *eventTime = [[UILabel alloc]init];
    _eventTime = eventTime;
    _eventTime.text = @"时间：";
    _eventTime.textColor = [Utils colorWithHexString:@"#333333"];
    _eventTime.font = [UIFont systemFontOfSize:13];
    [self.infoPresentBtn addSubview:_eventTime];
    [_eventTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_publisher);
        make.top.equalTo(_event.mas_bottom).offset(5);
        make.right.equalTo(_replyTag);
    }];
    
    UIButton *replyDetail = [[UIButton alloc]init];
    _replyDetail = replyDetail;
    _replyDetail.backgroundColor = [Utils colorWithHexString:@"00a7fa"];
    _replyDetail.titleLabel.font = [UIFont systemFontOfSize:11];
    _replyDetail.layer.cornerRadius = 2.5;
    [_replyDetail setTitle:@"查看回执" forState:UIControlStateNormal];
    [self.contentView addSubview:_replyDetail];
    [_replyDetail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 22));
        make.right.equalTo(_infoPresentBtn).offset(-4);
        make.top.equalTo(_infoPresentBtn.mas_bottom).offset(2);
    }];
    
    UILabel *remainTime = [[UILabel alloc]init];
    _remainTime = remainTime;
    _remainTime.text = @"剩余回复时间：";
    _remainTime.textColor = [Utils colorWithHexString:@"#666666"];
    _remainTime.font = [UIFont systemFontOfSize:11];
    [self.contentView addSubview:_remainTime];
    [_remainTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(verLine1.mas_right).offset(20);
        make.right.equalTo(_replyDetail.mas_left).offset(-4);
        make.top.equalTo(_infoPresentBtn.mas_bottom).offset(2);
    }];
}

@end
