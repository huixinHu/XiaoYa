//
//  GroupInfoViewController.m
//  XiaoYa
//
//  Created by commet on 2017/7/31.
//  Copyright © 2017年 commet. All rights reserved.
//群组消息页

#import "GroupInfoViewController.h"
#import "GroupInfoTableViewCell.h"
#import "GroupTextInfoCell.h"
#import "GroupDetailViewController.h"
#import "EventDetailViewController.h"
#import "EventPublishViewController.h"
#import "Utils.h"
#import "Masonry.h"
#import "GroupInfoModel.h"
#import "GroupListModel.h"
#import "AppDelegate.h"
#import "HXNotifyConfig.h"
#import "MessageProtoBuf.pbobjc.h"
#import "UIAlertController+Appearance.h"

@interface GroupInfoViewController ()<UITableViewDelegate ,UITableViewDataSource>
@property (nonatomic ,weak) UITableView *infoList;
@property (nonatomic ,weak) UIButton *publish;

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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGroupDetail:) name:HXEditGroupDetailNotification object:nil];//刷新群
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiFromServer:) name:HXNotiFromServerNotification object:nil];//收到来自服务器的通知
    [self viewsSetting];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.title = self.detailmodel.groupName;
    [self.infoList reloadData];
}

//刷新群资料相关信息 自己是群主自己编辑了信息 刷新走viewWillAppear
- (void)refreshGroupDetail:(NSNotification *)notification{
    NSDictionary *refreshData = [notification userInfo];
    GroupListModel *refreshModel = [refreshData objectForKey:HXEditGroupDetailKey];
    self.detailmodel.groupMembers = [refreshModel.groupMembers mutableCopy];
    self.detailmodel.groupName = refreshModel.groupName;
    self.detailmodel.groupAvatarId = refreshModel.groupAvatarId;
    self.detailmodel.numberOfMember = refreshModel.numberOfMember;
    
    NSArray *newInfo = [[notification userInfo] objectForKey:@"insertMegList"];//由于修改群资料产生的新消息
    if (newInfo.count > 0) {//有因为群资料修改而产生的新群组消息
        NSMutableArray *newGroupEvents = [NSMutableArray arrayWithArray:newInfo];
        if (self.detailmodel.groupEvents) {
            [newGroupEvents addObjectsFromArray:self.detailmodel.groupEvents];
        }
        self.detailmodel.groupEvents = newGroupEvents;
    }
}

//接收到服务器的通知
- (void)notiFromServer:(NSNotification *)notification{
    int type = [[[notification userInfo] objectForKey:@"type"] intValue];
    //收到聊天消息、群解散、被踢、有人进群都是可以整合在一起写的逻辑
    switch (type) {
        case ProtoMessage_Type_Chat://收到群消息
        case ProtoMessage_Type_DismissGroupNotify://群解散
        case ProtoMessage_Type_QuitGroupNotify://被踢出群
        case ProtoMessage_Type_SomeoneJoinNotify:{//有人进群
            GroupInfoModel *infoModel = [[notification userInfo] objectForKey:HXNotiFromServerKey];
            NSString *numberOfMember = [[notification userInfo] objectForKey:@"numberOfMember"];
            if ([self.detailmodel.groupId isEqualToString:infoModel.groupId]) {
                if (self.detailmodel.groupEvents) {//不为空
                    [self.detailmodel.groupEvents insertObject:infoModel atIndex:0];
                } else{
                    self.detailmodel.groupEvents = [NSMutableArray arrayWithObject:infoModel];
                }
                if (numberOfMember) {
                    self.detailmodel.numberOfMember = numberOfMember.integerValue;
                }
                __weak typeof(self) ws = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(ws) ss = ws;
                    if ([[Utils obtainPresentVC] isMemberOfClass:[ss class]]) {
                        [ss.infoList reloadData];
                    }
                });
            }
        } break;
        
        case ProtoMessage_Type_UpdateGroupNotify:{//群资料更新
            NSDictionary *detailDict = [[notification userInfo] objectForKey:HXNotiFromServerKey];
            if ([self.detailmodel.groupId isEqualToString:[detailDict objectForKey:@"groupId"]]) {
                NSArray *newInfo = [[notification userInfo] objectForKey:@"insertMegList"];//由于修改群资料产生的新消息
                self.detailmodel.groupAvatarId = [detailDict objectForKey:@"groupAvatarId"];
                self.detailmodel.numberOfMember = [[detailDict objectForKey:@"numberOfMember"] integerValue];
                self.detailmodel.groupName = [detailDict objectForKey:@"groupName"];
                if (newInfo.count > 0) {//有因为群资料修改而产生的新群组消息
                    NSMutableArray *newGroupEvents = [NSMutableArray arrayWithArray:newInfo];
                    if (self.detailmodel.groupEvents) {
                        [newGroupEvents addObjectsFromArray:self.detailmodel.groupEvents];
                    }
                    self.detailmodel.groupEvents = newGroupEvents;
                }
                __weak typeof(self) weakself = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(weakself) ss = weakself;
                    if ([[Utils obtainPresentVC] isMemberOfClass:[ss class]]) {
                        ss.navigationItem.title = self.detailmodel.groupName;
                        if (newInfo.count > 0) {//有因为群资料修改而产生的新群组消息
                            [ss.infoList reloadData];
                        }
                    }
                });
            }

        } break;
            
        case ProtoMessage_Type_SomeoneQuitNotify:{//有人退群
            NSDictionary *detailDict = [[notification userInfo] objectForKey:HXNotiFromServerKey];
            GroupInfoModel *infoModel = [detailDict objectForKey:@"insertMsg"];
            if ([self.detailmodel.groupId isEqualToString:[detailDict objectForKey:@"groupId"]]) {
                if ([detailDict objectForKey:@"numberOfMember"]) {
                    self.detailmodel.numberOfMember = [[detailDict objectForKey:@"numberOfMember"] integerValue];
                }
                if (infoModel) {
                    if (self.detailmodel.groupEvents) {//不为空
                        [self.detailmodel.groupEvents insertObject:infoModel atIndex:0];
                    } else{
                        self.detailmodel.groupEvents = [NSMutableArray arrayWithObject:infoModel];
                    }
                }
            }
            __weak typeof(self) ws = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(ws) ss = ws;
                if (infoModel && [[Utils obtainPresentVC] isMemberOfClass:[ss class]]) {
                    [ss.infoList reloadData];
                }
            });
        } break;
        default:
            break;
    }
}

- (void)back{
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
    dfm.groupId = self.detailmodel.groupId;
    EventPublishViewController *VC = [[EventPublishViewController alloc]initWithInfoModel:dfm publishCompBlock:^(GroupInfoModel *newEvent) {
        __strong typeof(ws) ss = ws;
        if (ss.detailmodel.groupEvents) {//不为空
            [ss.detailmodel.groupEvents insertObject:newEvent atIndex:0];
        } else{
            ss.detailmodel.groupEvents = [NSMutableArray arrayWithObject:newEvent];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[Utils obtainPresentVC] isMemberOfClass:[self class]]) {
                [ss.infoList reloadData];
            }
        });
    }];
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark tableview datasource &delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.detailmodel.groupEvents.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    GroupInfoModel *cellModel = self.detailmodel.groupEvents[indexPath.row];
    if (!cellModel.publisher) {
        return 40;
    } else{
        return 130;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GroupInfoModel *cellModel = self.detailmodel.groupEvents[indexPath.row];
    if (!cellModel.publisher) {
        GroupTextInfoCell *cell = [GroupTextInfoCell GroupTextInfoCellWithTableView:tableView];
        cell.model = cellModel;
        return cell;
    } else{
        __weak typeof(self) ws = self;
        GroupInfoTableViewCell *cell = [GroupInfoTableViewCell GroupInfoCellWithTableView:tableView eventDetailBlock:^(GroupInfoModel *model) {
            EventDetailViewController *VC =
            [[EventDetailViewController alloc]initWithInfoModel:ws.detailmodel.groupEvents[indexPath.row]
                                                  editCompBlock:^(GroupInfoModel *edittedModel) {
                                                      [ws.detailmodel.groupEvents replaceObjectAtIndex:indexPath.row withObject:edittedModel];
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [ws.infoList reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                                      });
                                                  }];
            [ws.navigationController pushViewController:VC animated:YES];
        }];
        cell.model = cellModel;
        if (self.detailmodel.deleteFlag == 1) {
            cell.enableFlag = NO;
        }
        return cell;
    }
}

#pragma mark viewsSetting
- (void)viewsSetting{
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[Utils colorWithHexString:@"#333333"],NSFontAttributeName:[UIFont systemFontOfSize:17]};
    self.navigationItem.title = self.detailmodel.groupName;
    UIButton *groupData = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 40)];//群资料
    [groupData setTitle:@"群资料" forState:UIControlStateNormal];
    [groupData setTitleColor:[Utils colorWithHexString:@"#666666"] forState:UIControlStateNormal];
    [groupData setTitleColor:[Utils colorWithHexString:@"#999999"] forState:UIControlStateDisabled];
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
    
    if (self.detailmodel.deleteFlag == 1) {
        _publish.hidden = YES;
        groupData.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXEditGroupDetailNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXNotiFromServerNotification object:nil];
}
@end
