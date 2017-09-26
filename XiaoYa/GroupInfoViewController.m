//
//  GroupInfoViewController.m
//  XiaoYa
//
//  Created by commet on 2017/7/31.
//  Copyright © 2017年 commet. All rights reserved.
//群组消息页

#import "GroupInfoViewController.h"
#import "GroupInfoTableViewCell.h"
#import "GroupDetailViewController.h"
#import "EventDetailViewController.h"
#import "EventPublishViewController.h"
#import "Utils.h"
#import "Masonry.h"
#import "GroupInfoModel.h"
#import "GroupListModel.h"
#import "AppDelegate.h"
#import "HXNotifyConfig.h"

@interface GroupInfoViewController ()<UITableViewDelegate ,UITableViewDataSource >
@property (nonatomic ,weak) UITableView *infoList;
@property (nonatomic ,weak) UIButton *publish;

@property (nonatomic ,strong) NSMutableArray <GroupInfoModel *> *infoModels; //事件模型
@property (nonatomic ,strong) GroupListModel *detailmodel;
@end

@implementation GroupInfoViewController
- (instancetype)initWithGroupModel:(GroupListModel *)model{
    if (self = [super init]) {
        self.detailmodel = [model copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.detailmodel.groupEvents = self.infoModels;

    [self viewsSetting];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGroupDetail:) name:HXEditGroupDetailNotification object:nil];//刷新群
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.title = self.detailmodel.groupName;
}

//刷新群资料相关信息 自己是群主自己编辑了信息 刷新走viewWillAppear
- (void)refreshGroupDetail:(NSNotification *)notification{
    NSDictionary *refreshData = [notification userInfo];
    GroupListModel *refreshModel = [refreshData objectForKey:HXRefreshGroupDetail];
    self.detailmodel.groupMembers = [refreshModel.groupMembers mutableCopy];
    self.detailmodel.groupName = refreshModel.groupName;
    self.detailmodel.groupAvatarId = refreshModel.groupAvatarId;
    self.detailmodel.numberOfMember = refreshModel.numberOfMember;
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
    for (UIViewController *tempVC in self.navigationController.viewControllers) {
        if ([tempVC isKindOfClass:NSClassFromString(@"GroupHomePageViewController")]) {
            [self.navigationController popToViewController:tempVC animated:YES];
        }
    }
}

- (void)groupDetailData{
    GroupDetailViewController *groupDetailVC = [[GroupDetailViewController alloc] initWithGroupInfo:self.detailmodel];
    [self.navigationController pushViewController:groupDetailVC animated:YES];
}

//发布信息
- (void)publishEvent{
    __weak typeof(self) ws = self;
    GroupInfoModel *dfm = [GroupInfoModel defaultModel];
    EventPublishViewController *VC = [[EventPublishViewController alloc]initWithInfoModel:dfm groupId:self.detailmodel.groupId publishCompBlock:^(GroupInfoModel *newEvent) {
        if (ws.detailmodel.groupEvents) {//不为空
            [ws.detailmodel.groupEvents addObject:newEvent];
        } else{
            ws.detailmodel.groupEvents = [NSMutableArray arrayWithObject:newEvent];
        }
        [ws.infoList reloadData];
    }];
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark tableview datasource &delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.detailmodel.groupEvents.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 130;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) ws = self;
    GroupInfoTableViewCell *cell = [GroupInfoTableViewCell GroupInfoCellWithTableView:tableView eventDetailBlock:^(GroupInfoModel *model) {
        EventDetailViewController *VC =
        [[EventDetailViewController alloc]initWithInfoModel:ws.detailmodel.groupEvents[indexPath.row]
                                                    groupId:ws.detailmodel.groupId
                                              editCompBlock:^(GroupInfoModel *edittedModel) {
                                                  [ws.detailmodel.groupEvents replaceObjectAtIndex:indexPath.row withObject:edittedModel];
                                                  [ws.infoList reloadData];//reloadRowsAtIndexPaths ？
                                              }];
        [ws.navigationController pushViewController:VC animated:YES];
    }];
    cell.model = self.detailmodel.groupEvents[indexPath.row];
    return cell;
}

#pragma mark viewsSetting
- (void)viewsSetting{
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[Utils colorWithHexString:@"#333333"],NSFontAttributeName:[UIFont systemFontOfSize:17]};
    self.navigationItem.title = self.detailmodel.groupName;
    UIButton *groupData = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 40)];//群资料
    [groupData setTitle:@"群资料" forState:UIControlStateNormal];
    [groupData setTitleColor:[Utils colorWithHexString:@"#666666"] forState:UIControlStateNormal];
    groupData.titleLabel.font = [UIFont systemFontOfSize:15];
    [groupData addTarget:self action:@selector(groupDetailData) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:groupData];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"导航栏返回图标"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.view.backgroundColor = [Utils colorWithHexString:@"#F0F0F6"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = [Utils colorWithHexString:@"#d9d9d9"];
    [self.view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(2);
        make.top.bottom.equalTo(self.view);
        make.left.equalTo(self.view).offset(75);
    }];
    
    //设置群组消息table
    UITableView *infoList = [[UITableView alloc]init];
    _infoList = infoList;
    _infoList.delegate = self;
    _infoList.dataSource = self;
    _infoList.bounces = NO;
    _infoList.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_infoList];
    [_infoList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
    }];
    [_infoList setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    _infoList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIButton *publish = [[UIButton alloc]init];
    _publish = publish;
    [_publish setBackgroundImage:[UIImage imageNamed:@"自动导入"] forState:UIControlStateNormal];
    [_publish setTitle:@"发布" forState:UIControlStateNormal];
    _publish.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [_publish addTarget:self action:@selector(publishEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_publish];
    [_publish mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 60));
        make.right.equalTo(self.view.mas_right).offset(-24);
        make.bottom.equalTo(self.view.mas_bottom).offset(-50);
    }];
}

- (NSMutableArray *)infoModels{
    if (_infoModels == nil) {
        NSMutableArray *modelArr = [NSMutableArray array];
//        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        NSString *user = [[appDelegate.user componentsSeparatedByString:@"("]firstObject];
        NSDictionary *testDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"201709011200",@"publishTime",@"usertest",@"publisher",@"开会",@"event",@"20170910",@"eventTime",@",1,2,",@"eventSection",@"记得准时到",@"comment",@"1",@"dlIndex",nil];
        GroupInfoModel *model = [GroupInfoModel groupInfoWithDict:testDict];
        [modelArr addObject:model];
        _infoModels = modelArr;
    }
    return _infoModels;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXEditGroupDetailNotification object:nil];
}
@end
