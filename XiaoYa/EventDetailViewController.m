//
//  EventDetailViewController.m
//  XiaoYa
//
//  Created by commet on 2017/7/31.
//  Copyright © 2017年 commet. All rights reserved.
//事件详情

#import "EventDetailViewController.h"
#import "EventPublishViewController.h"
#import "Utils.h"
#import "DateUtils.h"
#import "NSDate+Calendar.h"
#import "Masonry.h"
#import "ReasonView.h"
#import "AppDelegate.h"
#import "SectionSchedule.h"
#import "GroupInfoModel.h"
#import "UIAlertController+Appearance.h"
#import "MessageProtoBuf.pbobjc.h"
#import "HXNotifyConfig.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define kScreenHeight [UIApplication sharedApplication].keyWindow.bounds.size.height
typedef NS_ENUM(NSInteger, HXReplyStatus) {
    HXReplyStatusNotReply = 0,          // 未回复
    HXReplyStatusParticipate = 1,       // 参加
    HXReplyStatusNotParticipate = 2       // 不参加
};

@interface EventDetailViewController ()
@property (nonatomic ,weak) UILabel *publishTime;//发布时间
@property (nonatomic ,weak) UILabel *publisher;//发布者
@property (nonatomic ,weak) UILabel *event;//事件
@property (nonatomic ,weak) UILabel *eventTime;//事件时间
@property (nonatomic ,weak) UILabel *replyTag;//右上角标签
@property (nonatomic ,weak) UILabel *comment;//备注
@property (nonatomic ,weak) UIButton *schedule;//当日日程
@property (nonatomic ,weak) UILabel *replyStateLab;//回复状态
@property (nonatomic ,weak) UIButton *participate;//参加
@property (nonatomic ,weak) UIButton *notParticipate;//不参加
@property (nonatomic ,weak) UIButton *modify;//修改
@property (nonatomic ,weak) UIView *coverLayer;

@property (nonatomic ,copy) NSString *notPartiReason;//不参加的理由
@property (nonatomic ,assign) HXReplyStatus state;
@property (nonatomic ,strong) GroupInfoModel *infoModel;
@property (nonatomic ,strong) editCompBlock editCompBlock;
@property (nonatomic ,copy) NSString *groupId;
@end

@implementation EventDetailViewController
- (instancetype)initWithInfoModel:(GroupInfoModel *)model groupId:(NSString *)gid editCompBlock:(editCompBlock)block{
    if (self = [super init]) {
        self.infoModel = model;
        self.editCompBlock = [block copy];
        self.groupId = gid;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiFromServer:) name:HXNotiFromServerNotification object:nil];//收到来自服务器的通知
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(state)) options:NSKeyValueObservingOptionNew context:nil];
    [self viewsSetting];

    //此处获取回复状态
    self.state = HXReplyStatusNotReply;//测试
}

//接收到服务器的通知
- (void)notiFromServer:(NSNotification *)notification{
    int type = [[[notification userInfo] objectForKey:@"type"] intValue];
    switch (type) {
        case ProtoMessage_Type_QuitGroupNotify:{//被踢出群
            NSString *groupId = [[notification userInfo] objectForKey:@"groupId"];
            if ([self.groupId isEqualToString:groupId]) {
                UIViewController *presentVC = [Utils obtainPresentVC];
                if ([presentVC isMemberOfClass:[self class]]) {
                    __weak typeof(self) weakself = self;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        void (^otherBlock)(UIAlertAction *action) = ^(UIAlertAction *action){
                            for (UIViewController *tempVC in self.navigationController.viewControllers) {
                                if ([tempVC isKindOfClass:NSClassFromString(@"GroupHomePageViewController")]) {
                                    [self.navigationController popToViewController:tempVC animated:YES];
                                }
                            }
                        };
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"通知" message:@"你已被移除出该群组" preferredStyle:UIAlertControllerStyleAlert cancelTitle:nil cancelBlock:nil otherTitles:@[@"确定"] otherBlocks:@[otherBlock]];
                        [weakself presentViewController:alert animated:YES completion:nil];
                    });
                }
            }
        } break;
        default:
            break;
    }
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ui相关
//重新编辑事务,只有时间发布者能看到这个按钮
- (void)editEvent{
    __weak typeof(self) ws = self;
    EventPublishViewController *vc = [[EventPublishViewController alloc]initWithInfoModel:self.infoModel groupId:self.groupId publishCompBlock:^(GroupInfoModel *newEvent) {
        ws.editCompBlock(newEvent);
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)curDateScuedule{
    self.coverLayer = [Utils coverLayerAddToWindow];
    CGFloat width = 650 / 750.0 * kScreenWidth -50;
    CGFloat height = (178 + 76)/2 + 245;
    __weak typeof(self) ws = self;
    SectionSchedule *scheduleView = [[SectionSchedule alloc]initWithFrame:CGRectMake(0, 0, width, height) selectedDate:[NSDate date] confirmBlock:^{
        [ws.coverLayer removeFromSuperview];
    }];
    [Utils putViewOnCenter:scheduleView superView:self.view];
    [_coverLayer addSubview:scheduleView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    int state = [change[NSKeyValueChangeNewKey] intValue];
    if (state == HXReplyStatusNotReply) {
        self.replyTag.text = @"未回复";
        self.replyStateLab.text = @"回复状态：未回复";
        self.participate.hidden = NO;
        self.notParticipate.hidden = NO;
        self.modify.hidden = YES;
    }else{
        self.replyTag.text = @"已回复";
        self.participate.hidden = YES;
        self.notParticipate.hidden = YES;
        self.modify.hidden = NO;
        if (state == HXReplyStatusParticipate) {
            self.replyStateLab.text = @"回复状态：已参加";
        } else{
            self.replyStateLab.text = @"回复状态：不参加";
        }
    }
}

//修改回复状态。参加、不参加
- (void)modifyState:(UIButton *)sender{
    sender.hidden = YES;
    self.participate.hidden = NO;
    self.notParticipate.hidden = NO;
    self.replyTag.text = @"未回复";
}

//输入不参加的原因
- (void)notPartiAction{
    self.coverLayer = [Utils coverLayerAddToWindow];
    __weak typeof(self) ws = self;
    ReasonView *reasonView = [[ReasonView alloc]initWithCancelBlock:^{
        [ws.coverLayer removeFromSuperview];
    } confirmBlock:^(NSString *reason) {
        ws.notPartiReason = [reason copy];
        ws.state = HXReplyStatusNotParticipate;
        NSLog(@"%@",ws.notPartiReason);
        [ws.coverLayer removeFromSuperview];
    }];
    reasonView = (ReasonView *)[Utils putViewOnCenter:reasonView superView:self.view];
    [_coverLayer addSubview:reasonView];
}

//参加
- (void)partiAction{
    self.state = HXReplyStatusParticipate;
}

#pragma mark 其他
//发布时间格式化
- (NSString *)publishTimeToFormatStr:(NSDate *)date{
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [df stringFromDate:date];
}

//时间时间格式化
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

#pragma mark viewsSetting
- (void)viewsSetting{
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[Utils colorWithHexString:@"#333333"],NSFontAttributeName:[UIFont systemFontOfSize:17]};
    self.navigationItem.title = @"事务详情";
    UIButton *edit = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [edit setTitle:@"编辑" forState:UIControlStateNormal];
    [edit setTitleColor:[Utils colorWithHexString:@"#666666"] forState:UIControlStateNormal];
    edit.titleLabel.font = [UIFont systemFontOfSize:15];
    [edit addTarget:self action:@selector(editEvent) forControlEvents:UIControlEventTouchUpInside];
    edit.hidden = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:edit];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"导航栏返回图标"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.view.backgroundColor = [Utils colorWithHexString:@"#F0F0F6"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //只有发布者才能看到编辑按钮
    NSString *publisherId = [[[[self.infoModel.publisher componentsSeparatedByString:@"("] lastObject] componentsSeparatedByString:@")"] firstObject];
    AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([apd.userid isEqualToString:publisherId]) {
        edit.hidden = NO;
    }
    
    UILabel *publishTime = [[UILabel alloc]init];
    _publishTime = publishTime;
    _publishTime.text = [self publishTimeToFormatStr:self.infoModel.publishTime];
    _publishTime.textColor = [Utils colorWithHexString:@"#999999"];
    _publishTime.font = [UIFont systemFontOfSize:11];
    [self.view addSubview:_publishTime];
    [_publishTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(13);
        make.centerX.equalTo(self.view);
    }];
    
    UIView *bg = [[UIView alloc]init];
    bg.backgroundColor = [UIColor whiteColor];
    bg.layer.cornerRadius = 5.0;
    [self.view addSubview:bg];
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(12);
        make.right.equalTo(self.view).offset(-12);
        make.top.equalTo(_publishTime.mas_bottom).offset(13);
        make.height.mas_equalTo(140);
    }];
    
    UILabel *replyTag = [[UILabel alloc]init];
    _replyTag = replyTag;
    _replyTag.text = @"未回复";
    _replyTag.textColor = [Utils colorWithHexString:@"#666666"];
    _replyTag.font = [UIFont systemFontOfSize:13];
    [bg addSubview:_replyTag];
    [_replyTag mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(bg).offset(-22);
        make.top.equalTo(bg).offset(15);
    }];
    
    UILabel *publisher = [[UILabel alloc]init];
    _publisher = publisher;
    _publisher.text = [NSString stringWithFormat:@"发布者：%@", [[self.infoModel.publisher componentsSeparatedByString:@"("]firstObject]];
    _publisher.textColor = [Utils colorWithHexString:@"#333333"];
    _publisher.font = [UIFont systemFontOfSize:15];
    [bg addSubview:_publisher];
    [_publisher mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_replyTag);
        make.left.equalTo(bg).offset(22);
        make.right.equalTo(bg).offset(-60);
    }];
    
    UILabel *event = [[UILabel alloc]init];
    _event = event;
    _event.text = [NSString stringWithFormat:@"事件：%@", self.infoModel.event];
    _event.textColor = [Utils colorWithHexString:@"#333333"];
    _event.font = [UIFont systemFontOfSize:13];
    [bg addSubview:_event];
    [_event mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_publisher);
        make.top.equalTo(_publisher.mas_bottom).offset(15);
        make.right.equalTo(_replyTag);
    }];
    
    UILabel *eventTime = [[UILabel alloc]init];
    _eventTime = eventTime;
    _eventTime.text = [NSString stringWithFormat:@"时间：%@", [self eventTimeToFormatStr:self.infoModel.eventDate eventSection:self.infoModel.eventSection]];
    _eventTime.textColor = [Utils colorWithHexString:@"#333333"];
    _eventTime.font = [UIFont systemFontOfSize:13];
    [bg addSubview:_eventTime];
    [_eventTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_publisher);
        make.top.equalTo(_event.mas_bottom).offset(10);
        make.right.equalTo(_replyTag);
    }];
    
    UILabel *comment = [[UILabel alloc]init];
    _comment = comment;
    _comment.text = [NSString stringWithFormat:@"备注：%@", self.infoModel.comment];
    _comment.numberOfLines = 0;
    _comment.textColor = [Utils colorWithHexString:@"#333333"];
    _comment.font = [UIFont systemFontOfSize:13];
    [bg addSubview:_comment];
    [_comment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_publisher);
        make.top.equalTo(_eventTime.mas_bottom).offset(10);
        make.right.equalTo(_replyTag);
        make.bottom.equalTo(bg).offset(-15);
    }];
    
    UIButton *schedule = [[UIButton alloc]init];
    _schedule = schedule;
    _schedule.titleLabel.font = [UIFont systemFontOfSize:12];
    [_schedule setTitleColor:[Utils colorWithHexString:@"#00a7fa"] forState:UIControlStateNormal];
    [_schedule setTitle:@"查看当日行程" forState:UIControlStateNormal];
    [_schedule addTarget:self action:@selector(curDateScuedule) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_schedule];
    [_schedule mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(80, 40));
        make.right.equalTo(self.view).offset(-12);
        make.top.equalTo(bg.mas_bottom).offset(5);
    }];
    
    UILabel *replyState = [[UILabel alloc]init];
    _replyStateLab = replyState;
    _replyStateLab.text = @"回复状态：未回复";
    _replyStateLab.textColor = [Utils colorWithHexString:@"#333333"];
    _replyStateLab.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:_replyStateLab];
    [_replyStateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bg.mas_bottom).offset(100);
        make.centerX.equalTo(self.view);
    }];
    
    UIButton *modify = [[UIButton alloc]init];
    _modify = modify;
    _modify.titleLabel.font = [UIFont systemFontOfSize:15];
    [_modify setTitleColor:[Utils colorWithHexString:@"#00a7fa"] forState:UIControlStateNormal];
    [_modify setTitle:@"修改" forState:UIControlStateNormal];
    [_modify addTarget:self action:@selector(modifyState:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_modify];
    [_modify mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.left.equalTo(_replyStateLab.mas_right).offset(55);
        make.centerY.equalTo(_replyStateLab);
    }];
    
    UIButton *notParticipate = [[UIButton alloc]init];
    _notParticipate = notParticipate;
    _notParticipate.backgroundColor = [Utils colorWithHexString:@"00a7fa"];
    _notParticipate.titleLabel.font = [UIFont systemFontOfSize:14];
    _notParticipate.layer.cornerRadius = 5;
    [_notParticipate setTitle:@"不参加" forState:UIControlStateNormal];
    [_notParticipate addTarget:self action:@selector(notPartiAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_notParticipate];
    [_notParticipate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(90, 40));
        make.top.equalTo(_replyStateLab.mas_bottom).offset(18);
        make.right.equalTo(self.view.mas_centerX).offset(-15);
    }];
    
    UIButton *participate = [[UIButton alloc]init];
    _participate = participate;
    _participate.backgroundColor = [Utils colorWithHexString:@"00a7fa"];
    _participate.titleLabel.font = [UIFont systemFontOfSize:14];
    _participate.layer.cornerRadius = 5;
    [_participate setTitle:@"参加" forState:UIControlStateNormal];
    [_participate addTarget:self action:@selector(partiAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_participate];
    [_participate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(90, 40));
        make.top.equalTo(_replyStateLab.mas_bottom).offset(18);
        make.left.equalTo(self.view.mas_centerX).offset(15);
    }];
}

#pragma mark lazy
- (NSString *)notPartiReason{
    if (_notPartiReason == nil) {
        _notPartiReason = [NSString string];
    }
    return _notPartiReason;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(state))];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXNotiFromServerNotification object:nil];

}
@end
