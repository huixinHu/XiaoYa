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

@interface GroupInfoViewController ()<UITableViewDelegate ,UITableViewDataSource >
@property (nonatomic ,weak) UITableView *infoList;
@property (nonatomic ,weak) UIButton *publish;

@property (nonatomic ,copy) NSString *groupName;
@property (nonatomic ,strong) NSMutableArray *infoModels;
@end

@implementation GroupInfoViewController
- (instancetype)initWithGroupName:(NSString *)groupName{
    if (self = [super init]) {
        if (groupName != nil) {
            self.groupName = groupName;
        }else{
            self.groupName = @"";
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self viewsSetting];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)groupDetailData{
    GroupDetailViewController *groupDetailVC = [[GroupDetailViewController alloc] init];
    [self.navigationController pushViewController:groupDetailVC animated:YES];
}

#pragma mark tableview datasource &delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.infoModels.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 130;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) ws = self;
    GroupInfoTableViewCell *cell = [GroupInfoTableViewCell GroupInfoCellWithTableView:tableView eventDetailBlock:^(GroupInfoModel *model) {
        EventDetailViewController *VC = [[EventDetailViewController alloc]initWithInfoModel:ws.infoModels[indexPath.row]];
        [ws.navigationController pushViewController:VC animated:YES];
    }];
    cell.model = self.infoModels[indexPath.row];
    return cell;
}

#pragma mark viewsSetting
- (void)viewsSetting{
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[Utils colorWithHexString:@"#333333"],NSFontAttributeName:[UIFont systemFontOfSize:17]};
    self.navigationItem.title = self.groupName;
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

- (void)publishEvent{
    GroupInfoModel *dfm = [GroupInfoModel defaultModel];
    EventPublishViewController *VC = [[EventPublishViewController alloc]initWithInfoModel:dfm];
    [self.navigationController pushViewController:VC animated:YES];
}

- (NSMutableArray *)infoModels{
    if (_infoModels == nil) {
        NSMutableArray *modelArr = [NSMutableArray array];
        NSDictionary *testDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"201709011200",@"publishTime",@"张3",@"publisher",@"开会",@"event",@"20170910",@"eventTime",@",1,2,",@"eventSection",@"记得准时到",@"comment",@"201709091100",@"deadlineTime",nil];
        GroupInfoModel *model = [GroupInfoModel groupInfoWithDict:testDict];
        [modelArr addObject:model];
        _infoModels = modelArr;
    }
    return _infoModels;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
