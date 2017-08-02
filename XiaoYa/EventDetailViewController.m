//
//  EventDetailViewController.m
//  XiaoYa
//
//  Created by commet on 2017/7/31.
//  Copyright © 2017年 commet. All rights reserved.
//事件详情

#import "EventDetailViewController.h"
#import "Utils.h"
#import "Masonry.h"
#import "ReasonView.h"
#import "AppDelegate.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define kScreenHeight [UIApplication sharedApplication].keyWindow.bounds.size.height
@interface EventDetailViewController () <ReasonViewDelegate>
@property (nonatomic ,weak) UILabel *publishTime;
@property (nonatomic ,weak) UILabel *publisher;
@property (nonatomic ,weak) UILabel *event;
@property (nonatomic ,weak) UILabel *eventTime;
@property (nonatomic ,weak) UILabel *replyTag;
@property (nonatomic ,weak) UILabel *comment;
@property (nonatomic ,weak) UIButton *schedule;
@property (nonatomic ,weak) UILabel *replyState;
@property (nonatomic ,weak) UIButton *participate;
@property (nonatomic ,weak) UIButton *notParticipate;
@property (nonatomic ,weak) UIButton *modify;
@property (nonatomic ,weak) UIView *coverLayer;

@property (nonatomic ,copy) NSString *notPartiReason;

@end

@implementation EventDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self viewsSetting];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark ReasonViewDelegate
- (void)reasonViewCancelAction:(ReasonView *)reasonView{
    [self.coverLayer removeFromSuperview];
}

-(void)reasonViewConfirmAction:(ReasonView *)reasonView notParticipateReason:(NSString *)reason{
    [self.coverLayer removeFromSuperview];
    self.notPartiReason = reason;
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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:edit];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"导航栏返回图标"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.view.backgroundColor = [Utils colorWithHexString:@"#F0F0F6"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UILabel *publishTime = [[UILabel alloc]init];
    _publishTime = publishTime;
    _publishTime.text = @"2016-8-20 19:00";
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
//    bg.layer.shadowColor = [UIColor blackColor].CGColor;
//    bg.layer.shadowOffset = CGSizeMake(4, 4);
//    bg.layer.shadowRadius = 4;
//    bg.layer.opaque = 1;
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
    _publisher.text = @"发布者：";
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
    _event.text = @"事件：";
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
    _eventTime.text = @"时间：";
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
    _comment.text = @"备注：";
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
    [self.view addSubview:_schedule];
    [_schedule mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(80, 40));
        make.right.equalTo(self.view).offset(-12);
        make.top.equalTo(bg.mas_bottom).offset(5);
    }];
    
    UILabel *replyState = [[UILabel alloc]init];
    _replyState = replyState;
    _replyState.text = @"回复状态：已参加";
    _replyState.textColor = [Utils colorWithHexString:@"#333333"];
    _replyState.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:_replyState];
    [_replyState mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bg.mas_bottom).offset(100);
        make.centerX.equalTo(self.view);
    }];
    
    UIButton *modify = [[UIButton alloc]init];
    _modify = modify;
    _modify.titleLabel.font = [UIFont systemFontOfSize:15];
    [_modify setTitleColor:[Utils colorWithHexString:@"#00a7fa"] forState:UIControlStateNormal];
    [_modify setTitle:@"修改" forState:UIControlStateNormal];
    [self.view addSubview:_modify];
    [_modify mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.left.equalTo(_replyState.mas_right).offset(55);
        make.centerY.equalTo(_replyState);
    }];
    
    UIButton *notParticipate = [[UIButton alloc]init];
    _notParticipate = notParticipate;
    _notParticipate.backgroundColor = [Utils colorWithHexString:@"00a7fa"];
    _notParticipate.titleLabel.font = [UIFont systemFontOfSize:14];
    _notParticipate.layer.cornerRadius = 5;
    [_notParticipate setTitle:@"不参加" forState:UIControlStateNormal];
    [_notParticipate addTarget:self action:@selector(editReason) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_notParticipate];
    [_notParticipate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(90, 40));
        make.top.equalTo(_replyState.mas_bottom).offset(18);
        make.right.equalTo(self.view.mas_centerX).offset(-15);
    }];
    
    UIButton *participate = [[UIButton alloc]init];
    _participate = participate;
    _participate.backgroundColor = [Utils colorWithHexString:@"00a7fa"];
    _participate.titleLabel.font = [UIFont systemFontOfSize:14];
    _participate.layer.cornerRadius = 5;
    [_participate setTitle:@"参加" forState:UIControlStateNormal];
    [self.view addSubview:_participate];
    [_participate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(90, 40));
        make.top.equalTo(_replyState.mas_bottom).offset(18);
        make.left.equalTo(self.view.mas_centerX).offset(15);
    }];
}

//输入不参加的原因
- (void)editReason{
    UIView *coverLayer = [self coverLayerInit];
    self.coverLayer = coverLayer;
    AppDelegate *app = (AppDelegate *)[[UIApplication  sharedApplication] delegate];
    [app.window addSubview:_coverLayer];
    
    ReasonView *reasonView = [[ReasonView alloc]init];
    reasonView.delegate = self;
    CGPoint center =  reasonView.center;
    center.x = self.view.frame.size.width/2;
    center.y = self.view.frame.size.height/2;
    reasonView.center = center;
    [_coverLayer addSubview:reasonView];
}

- (UIView *)coverLayerInit{
    UIView *coverLayer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    coverLayer.backgroundColor = [UIColor colorWithRed:88/255.0 green:88/255.0  blue:88/255.0  alpha:0.5];
    return coverLayer;
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

@end
