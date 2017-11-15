//
//  GroupHomePageViewController.m
//  XiaoYa
//
//  Created by commet on 2017/7/7.
//  Copyright © 2017年 commet. All rights reserved.
//群组首页

#import "GroupHomePageViewController.h"
#import "GroupCreateViewController.h"
#import "JoinGroupViewController.h"
#import "GroupInfoViewController.h"
#import "GroupListModel.h"
#import "GroupMemberModel.h"
#import "GroupInfoModel.h"
#import "GroupHomePageCell.h"
#import "Utils.h"
#import "Masonry.h"
#import "TxAvatar.h"
#import "AppDelegate.h"
#import "HXNotifyConfig.h"
#import "HXDBManager.h"
#import "FMDB.h"
#import "MBProgressHUD.h"
#import "MessageProtoBuf.pbobjc.h"
#import "UIAlertController+Appearance.h"

@interface GroupHomePageViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,weak)UIImageView *menu;
@property (nonatomic ,weak)UITableView *groupTable;
@property (nonatomic ,weak)UIButton *menuBtn;
@property (nonatomic ,weak) UIButton *joinNow;
@property (nonatomic ,weak) UILabel *hint;

@property (nonatomic ,strong)NSMutableArray <GroupListModel *> *groupModels;//群组模型数组
@property (nonatomic ,strong) HXDBManager *hxDB;
@property (nonatomic ,weak) MBProgressHUD *hud;
@end

@implementation GroupHomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;//一定要先设，不然使用了MBProgressHUD会导致tableView移位
    __weak typeof(self) ws = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __strong typeof(ws) ss = ws;
        dispatch_async(dispatch_get_main_queue(), ^{
            ss.hud = [MBProgressHUD showHUDAddedTo:ss.view animated:YES];
            ss.hud.label.text = @"请稍等";
        });
        
        [ss dbSetting];
        dispatch_async(dispatch_get_main_queue(), ^{
            [ss viewsSetting];
            [ss.hud hideAnimated:YES];
        });
    });
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGroupDetail:) name:HXEditGroupDetailNotification object:nil];//刷新群资料
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGroupInfo:) name:HXPublishGroupInfoNotification object:nil];//发布事务-刷新群消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGroupInfo:) name:HXDismissExitGroupNotification object:nil];//解散、退群-刷新群消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserDetail:) name:HXRefreshUserDetailNotification object:nil];//刷新成员信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiFromServer:) name:HXNotiFromServerNotification object:nil];//收到来自服务器的通知
}

- (void)dbSetting{
    self.hxDB = [HXDBManager shareDB];

    NSArray *groupArr = [self.hxDB queryTable:groupTable modelClass:[GroupListModel class] excludeProperty:nil whereDict:@{@"WHERE deleteFlag = ?":@[@0]} callback:^(NSError *error) {
        if (error) {
            NSLog(@"%@",error.userInfo[NSLocalizedDescriptionKey]);
        }
    }];//这里暂时有一个问题，numberOfmember 数据库和模型的类型不一致
    
    //删掉已解散群、已退出群的数据
    [self.hxDB deleteTable:groupTable whereDict:@{@"WHERE deleteFlag = ?" : @[@1]} callback:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    
    //群组放置的先后顺序？
    [self.hxDB.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [groupArr enumerateObjectsUsingBlock:^(NSMutableDictionary *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GroupListModel *lModel = [GroupListModel groupWithDict:obj];
            NSString *groupId = [obj objectForKey:@"groupId"];
            NSMutableArray *groupInfoArr = [NSMutableArray array];//消息数组
            //查找群消息
            FMResultSet *rs = [db executeQuery:@"SELECT * FROM groupInfoTable WHERE groupId = ? ORDER BY publishTime DESC" withArgumentsInArray:@[groupId]];
            while ([rs next]) {
                int count = [rs columnCount];
                NSMutableDictionary *modelDic = [NSMutableDictionary dictionary];
                for (int i = 0 ; i < count ; i++) {
                    NSString *key = [rs columnNameForIndex:i];
                    NSString *value = [rs stringForColumnIndex:i];
                    [modelDic setValue:value forKey:key];
                }
                //转模型
                GroupInfoModel *iModel = [GroupInfoModel groupInfoWithDict:modelDic];
                [groupInfoArr addObject:iModel];
            }
            //查找出错
            if (rs == nil) {
                NSLog(@"%@",[db lastError]);
                [rs close];
                return;
            }
            [rs close];
            lModel.groupEvents = [groupInfoArr mutableCopy];
            [self.groupModels addObject:lModel];
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.groupTable) {
        [self.groupTable reloadData];
    }
}

//刷新群资料相关信息 自己是群主自己编辑了信息 刷新走viewWillAppear
- (void)refreshGroupDetail:(NSNotification *)notification{
    GroupListModel *refreshModel = [[notification userInfo] objectForKey:HXEditGroupDetailKey];
    __block NSInteger indexMoveToTop = -1;//需要被顶置的群组index
    __block GroupListModel *model;
    [self.groupModels enumerateObjectsUsingBlock:^(GroupListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.groupId.intValue == refreshModel.groupId.intValue) {
            obj.groupMembers = [refreshModel.groupMembers mutableCopy];
            obj.groupName = refreshModel.groupName;
            obj.groupAvatarId = refreshModel.groupAvatarId;
            obj.numberOfMember = refreshModel.numberOfMember;
            
            NSArray *newInfo = [[notification userInfo] objectForKey:@"insertMegList"];//由于修改群资料产生的新消息
            if (newInfo.count > 0) {//有因为群资料修改而产生的新群组消息
                NSMutableArray *newGroupEvents = [NSMutableArray arrayWithArray:newInfo];
                if (obj.groupEvents) {
                    [newGroupEvents addObjectsFromArray:obj.groupEvents];
                }
                obj.groupEvents = newGroupEvents;
            }
            indexMoveToTop = idx;
            model = [obj copy];
            *stop = YES;
        }
    }];
    [self.groupModels removeObjectAtIndex:indexMoveToTop];
    [self.groupModels insertObject:model atIndex:0];
}

//自己解散群或者退出群或者发布了群消息
- (void)refreshGroupInfo:(NSNotification *)notification{
    GroupInfoModel *infoModel = [[notification userInfo] objectForKey:HXNewGroupInfo];
    NSString *groupId = infoModel.groupId;
    NSNumber *memberCount = [[notification userInfo] objectForKey:@"numberOfMember"];
    __block NSInteger indexMoveToTop = -1;//需要被顶置的群组index
    __block GroupListModel *model;
    [self.groupModels enumerateObjectsUsingBlock:^(GroupListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.groupId.intValue == groupId.intValue) {
            if (obj.groupEvents) {//不为空
                [obj.groupEvents insertObject:infoModel atIndex:0];
            } else{
                obj.groupEvents = [NSMutableArray arrayWithObject:infoModel];
            }
            
            if (memberCount) {
                obj.numberOfMember = memberCount.integerValue;
            }
            //自己解散群或者退出群
            int deleteFlag = [[[notification userInfo] objectForKey:@"deleteFlag"] intValue];
            if (deleteFlag == 1) {
                obj.deleteFlag = YES;
            }

            indexMoveToTop = idx;
            model = [obj copy];
            *stop = YES;
        }
    }];
    [self.groupModels removeObjectAtIndex:indexMoveToTop];
    [self.groupModels insertObject:model atIndex:0];
}

//刷新成员信息
- (void)refreshUserDetail:(NSNotification *)notification{
    NSMutableArray <GroupMemberModel *> *membersModel = [[notification userInfo] objectForKey:HXRefreshUserDetailKey];
    NSString *groupId = [[notification userInfo] objectForKey:@"groupId"];
    [self.groupModels enumerateObjectsUsingBlock:^(GroupListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.groupId.intValue == groupId.intValue) {
            obj.groupMembers = [membersModel mutableCopy];
            obj.numberOfMember = membersModel.count;
            *stop = YES;
        }
    }];
}

//接收到服务器的通知
//会出现这样一种情况:刚刚登陆完，就收到离线消息，此时群组页还没加载出来，所以这个通知方法不会被调用到
//所以应该在收到消息时就把数据保存进数据库
- (void)notiFromServer:(NSNotification *)notification{
    int type = [[[notification userInfo] objectForKey:@"type"] intValue];
    switch (type) {
        case ProtoMessage_Type_JoinGroupNotify:{//被拉入群
            __block NSInteger removeIndex = -1;
            GroupListModel *groupModel = [[notification userInfo] objectForKey:HXNotiFromServerKey];
            //是否存在退出、被踢的旧群（同一个群）数据
            [self.groupModels enumerateObjectsUsingBlock:^(GroupListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.groupId isEqualToString:groupModel.groupId]) {
                    removeIndex = idx;
                    *stop = YES;
                }
            }];
            if (removeIndex >= 0) [self.groupModels removeObjectAtIndex:removeIndex];
            [self.groupModels insertObject:groupModel atIndex:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[Utils obtainPresentVC] isMemberOfClass:[self class]]) {
                    [self.groupTable reloadData];
                }
            });
        } break;
        
        case ProtoMessage_Type_Chat://收到新消息
        case ProtoMessage_Type_DismissGroupNotify://群解散
        case ProtoMessage_Type_QuitGroupNotify://被踢出群
        case ProtoMessage_Type_SomeoneJoinNotify:{//有人进群
            __block NSInteger indexMoveToTop = -1;//需要被顶置的群组index
            __block GroupListModel *model;
            GroupInfoModel *infoModel = [[notification userInfo] objectForKey:HXNotiFromServerKey];
            NSString *numberOfMember = [[notification userInfo] objectForKey:@"numberOfMember"];
            [self.groupModels enumerateObjectsUsingBlock:^(GroupListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.groupId isEqualToString:infoModel.groupId]) {
                    if (obj.groupEvents) {//不为空
                        [obj.groupEvents insertObject:infoModel atIndex:0];
                    } else{
                        obj.groupEvents = [NSMutableArray arrayWithObject:infoModel];
                    }
                    if (numberOfMember) {//有人进群
                        obj.numberOfMember = numberOfMember.integerValue;
                    }
                    if (type == ProtoMessage_Type_DismissGroupNotify || type == ProtoMessage_Type_QuitGroupNotify) {
                        obj.deleteFlag = 1;
                    }
                    indexMoveToTop = idx;
                    model = [obj copy];
                    *stop = YES;
                }
            }];
            if (indexMoveToTop >= 0) {
                [self.groupModels removeObjectAtIndex:indexMoveToTop];
                [self.groupModels insertObject:model atIndex:0];
                __weak typeof(self) ws = self;
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(ws) ss = ws;
                    if ([[Utils obtainPresentVC] isMemberOfClass:[ss class]]) {
                        [ss.groupTable reloadData];
                    }
                });
            }
        } break;
            
        case ProtoMessage_Type_UpdateGroupNotify:{//群资料更新
            NSDictionary *detailDict = [[notification userInfo] objectForKey:HXNotiFromServerKey];
            __block NSInteger indexMoveToTop = -1;//需要被顶置的群组index
            __block GroupListModel *model;
            NSArray *newInfo = [[notification userInfo] objectForKey:@"insertMegList"];//由于修改群资料产生的新消息
            NSString *groupId = [detailDict objectForKey:@"groupId"];
            [self.groupModels enumerateObjectsUsingBlock:^(GroupListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.groupId isEqualToString:groupId]) {
                    obj.groupAvatarId = [detailDict objectForKey:@"groupAvatarId"];
                    obj.numberOfMember = [[detailDict objectForKey:@"numberOfMember"] integerValue];
                    if (newInfo.count > 0) {//有因为群资料修改而产生的新群组消息
                        NSMutableArray *newGroupEvents = [NSMutableArray arrayWithArray:newInfo];
                        if (obj.groupEvents) {
                            [newGroupEvents addObjectsFromArray:obj.groupEvents];
                        }
                        obj.groupEvents = newGroupEvents;
                        obj.groupName = [detailDict objectForKey:@"groupName"];
                        model = [obj copy];
                    }
                    indexMoveToTop = idx;
                    *stop = YES;
                }
            }];
//                [self.groupModels removeObjectAtIndex:indexMoveToTop];
//                [self.groupModels insertObject:model atIndex:0];
            __weak typeof(self) ws = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(ws) ss = ws;
                if ([[Utils obtainPresentVC] isMemberOfClass:[ss class]]) {
                    if (newInfo.count > 0) { //如果修改了群名、增加了人数
                        [self.groupModels removeObjectAtIndex:indexMoveToTop];
                        [self.groupModels insertObject:model atIndex:0];
                        [ss.groupTable reloadData];
                    } else {//如果修改了头像或者踢了人
                        NSIndexPath *refreshPath = [NSIndexPath indexPathForRow:indexMoveToTop inSection:0];
                        [ss.groupTable reloadRowsAtIndexPaths:@[refreshPath] withRowAnimation:UITableViewRowAnimationNone];
                    }
                }
            });
        } break;
            
        case ProtoMessage_Type_NoGroupNotify:{//没有加入任何群
            _hint.hidden = NO;
            _joinNow.hidden = NO;
        } break;
            
        case ProtoMessage_Type_SomeoneQuitNotify:{//有人退群
            __block NSInteger indexMoveToTop = -1;//需要被顶置的群组index
            __block GroupListModel *model;
            NSDictionary *dict = [[notification userInfo] objectForKey:HXNotiFromServerKey];
            NSString *groupId = [dict objectForKey:@"groupId"];
            GroupInfoModel *infoModel = [dict objectForKey:@"insertMsg"];
            [self.groupModels enumerateObjectsUsingBlock:^(GroupListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.groupId isEqualToString:groupId]) {
                    if ([dict objectForKey:@"numberOfMember"]) {
                        obj.numberOfMember = [[dict objectForKey:@"numberOfMember"] integerValue];
                    }
                    if (infoModel) {
                        if (obj.groupEvents) {//不为空
                            [obj.groupEvents insertObject:infoModel atIndex:0];
                        } else{
                            obj.groupEvents = [NSMutableArray arrayWithObject:infoModel];
                        }
                        model = [obj copy];
                    }
                    indexMoveToTop = idx;
                    *stop = YES;
                }
            }];
            __weak typeof(self) ws = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(ws) ss = ws;
                if ([[Utils obtainPresentVC] isMemberOfClass:[self class]]) {
                    if (infoModel) {
                        [ss.groupModels removeObjectAtIndex:indexMoveToTop];
                        [ss.groupModels insertObject:model atIndex:0];
                        [ss.groupTable reloadData];
                    }
                    if ([dict objectForKey:@"numberOfMember"]) {
                        NSIndexPath *refreshPath = [NSIndexPath indexPathForRow:indexMoveToTop inSection:0];
                        [ss.groupTable reloadRowsAtIndexPaths:@[refreshPath] withRowAnimation:UITableViewRowAnimationNone];
                    }
                }
            });
        } break;
        default:
            break;
    }
}

- (void)groupCreate{
    AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *userid = apd.userid;
    NSString *user = apd.userName;
    
    GroupMemberModel *managerModel = [GroupMemberModel memberModelWithMemberSearchDict:@{@"identity":[NSString stringWithFormat:@"%@,%@,%@",userid,user,apd.phone]}];
    NSMutableArray *membersArr = [NSMutableArray arrayWithObject:managerModel];
    GroupListModel *groupModel = [[GroupListModel alloc]init];
    groupModel.groupMembers = membersArr;//只有成员集（群主）
    __weak typeof(self) ws = self;
    GroupCreateViewController *createVC = [[GroupCreateViewController alloc]initWithGroupModel:groupModel successBlock:^(GroupListModel *model) {
        [ws.groupModels insertObject:model atIndex:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            ws.hint.hidden = YES;
            ws.joinNow.hidden = YES;
        });
    }];
    createVC.hidesBottomBarWhenPushed = YES;//从下级vc开始，tabbar都隐藏掉
    [self.navigationController pushViewController:createVC animated:YES];
    _menuBtn.selected = NO;
    _menu.hidden = YES;
}

- (void)join{
    __weak typeof(self) ws = self;
    JoinGroupViewController *joinVC = [[JoinGroupViewController alloc] initWithJoinSuccessBlock:^(GroupListModel *model) {
        //是否存在退出、被踢的旧群（同一个群）数据
        __block NSInteger removeIndex= -1;
        [ws.groupModels enumerateObjectsUsingBlock:^(GroupListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.groupId isEqualToString:model.groupId]) {
                removeIndex = idx;
                *stop = YES;
            }
        }];
        if (removeIndex >= 0) [ws.groupModels removeObjectAtIndex:removeIndex];
        
        [ws.groupModels insertObject:model atIndex:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            ws.hint.hidden = YES;
            ws.joinNow.hidden = YES;
        });
    }];
    joinVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:joinVC animated:YES];
    _menuBtn.selected = NO;
    _menu.hidden = YES;
}

#pragma mark tableview datasource &delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.groupModels.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 68;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GroupListModel *model = self.groupModels[indexPath.row];
    GroupHomePageCell *cell = [GroupHomePageCell groupHomePageCellWithTableView:tableView];
    cell.group = model;
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GroupListModel *model = self.groupModels[indexPath.row];
    GroupInfoViewController *groupInfoVC = [[GroupInfoViewController alloc]initWithGroupModel:model];
    groupInfoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:groupInfoVC animated:YES];
}

#pragma mark views setting
- (void)viewsSetting{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBg"] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[Utils colorWithHexString:@"#333333"],NSFontAttributeName:[UIFont systemFontOfSize:17]};
    self.navigationItem.title = @"群组";
    UIButton *menuBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    _menuBtn = menuBtn;
    [_menuBtn setImage:[UIImage imageNamed:@"点"] forState:UIControlStateNormal];
    [_menuBtn addTarget:self action:@selector(menuAppearAndHide:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:_menuBtn];
    self.view.backgroundColor = [Utils colorWithHexString:@"#F0F0F6"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    singleTap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:singleTap];
    [self grouplistSetting];
    [self menuSetting];
    [self noGroupSetting];
}

- (void)menuAppearAndHide:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        _menu.hidden = NO;
    }else{
        _menu.hidden = YES;
    }
}

-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer{
    _menu.hidden = YES;
    _menuBtn.selected = NO;
}

- (void)menuSetting{
    UIImageView *menu = [[UIImageView alloc] init];
    _menu = menu;
    _menu.image = [self drawMenu];
    [self.view addSubview:_menu];
    [_menu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(113, 106));
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(self.view);
    }];
    _menu.userInteractionEnabled = YES;
    _menu.hidden = YES;
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [Utils colorWithHexString:@"636363"];
    [_menu addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(88, 1));
        make.centerX.equalTo(_menu.mas_centerX);
        make.top.equalTo(_menu.mas_top).offset(56);
    }];
    
    UIButton *joinGroup = [[UIButton alloc]init];
    [joinGroup setImage:[UIImage imageNamed:@"加入群组"] forState:UIControlStateNormal];
    [joinGroup setTitle:@"加入群组" forState:UIControlStateNormal];
    joinGroup.titleLabel.font = [UIFont systemFontOfSize:14.0];
    joinGroup.titleEdgeInsets = UIEdgeInsetsMake(0, 13, 0, 0);
    [joinGroup addTarget:self action:@selector(join) forControlEvents:UIControlEventTouchUpInside];
    [_menu addSubview:joinGroup];
    [joinGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(113, 50));
        make.top.equalTo(_menu.mas_top).offset(6);
        make.centerX.equalTo(_menu.mas_centerX);
    }];
    
    UIButton *creatGroup = [[UIButton alloc]init];
    [creatGroup setImage:[UIImage imageNamed:@"创建群组"] forState:UIControlStateNormal];
    [creatGroup setTitle:@"创建群组" forState:UIControlStateNormal];
    creatGroup.titleLabel.font = [UIFont systemFontOfSize:14.0];
    creatGroup.titleEdgeInsets = UIEdgeInsetsMake(0, 13, 0, 0);
    [creatGroup addTarget:self action:@selector(groupCreate) forControlEvents:UIControlEventTouchUpInside];
    [_menu addSubview:creatGroup];
    [creatGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(113, 50));
        make.bottom.centerX.equalTo(_menu);
    }];
}

- (void)grouplistSetting{
    UITableView *groupTable = [[UITableView alloc]init];
    _groupTable = groupTable;
    _groupTable.delegate = self;
    _groupTable.dataSource = self;
    _groupTable.bounces = NO;
    _groupTable.backgroundColor = [Utils colorWithHexString:@"#F0F0F6"];
    [self.view addSubview:_groupTable];
    [_groupTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.top.centerX.equalTo(self.view);
        make.top.equalTo(self.navigationController.navigationBar.mas_bottom);
    }];
    
    [_groupTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)noGroupSetting{
    UIButton *joinNow = [[UIButton alloc] init];
    [joinNow setTitle:@"马上加入群组" forState:UIControlStateNormal];
    joinNow.backgroundColor = [Utils colorWithHexString:@"#00a7fa"];
    joinNow.titleLabel.font = [UIFont systemFontOfSize:15];
    joinNow.layer.cornerRadius = 5;
    [joinNow addTarget:self action:@selector(join) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:joinNow];
    [joinNow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(125, 40));
        make.center.equalTo(self.view);
    }];
    _joinNow = joinNow;
    
    UILabel *hint = [[UILabel alloc] init];
    hint.font = [UIFont systemFontOfSize:11];
    hint.textColor = [Utils colorWithHexString:@"#999999"];
    hint.text = @"暂未加入任何群组";
    [self.view addSubview:hint];
    [hint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(_joinNow.mas_top).offset(-20);
    }];
    _hint = hint;
    
    AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (apd.isNoGroup) {
        _joinNow.hidden = NO;
        _hint.hidden = NO;
    } else {
        _joinNow.hidden = YES;
        _hint.hidden = YES;
    }
}

- (UIImage *)drawMenu{
    CGFloat arrowHeight = 6.0 , arrowWidth = 6.0;
    CGFloat radius = 2.0;
    CGFloat width = 113 , height = 106;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath*path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(radius, radius + arrowHeight) radius:radius startAngle:M_PI endAngle:M_PI/2*3 clockwise:1];
    [path moveToPoint:CGPointMake(radius, arrowHeight)];
    [path addLineToPoint:CGPointMake(94, arrowHeight)];
    [path addLineToPoint:CGPointMake(94+arrowWidth/2, 0)];
    [path addLineToPoint:CGPointMake(94+arrowWidth , arrowHeight)];
    [path addLineToPoint:CGPointMake(width-radius , arrowHeight)];
    [path addArcWithCenter:CGPointMake(width - radius , radius + arrowHeight) radius:radius startAngle:M_PI*3/2 endAngle:M_PI*2 clockwise:1];
    [path addLineToPoint:CGPointMake(width, height - radius)];
    [path addArcWithCenter:CGPointMake(width - radius , height - radius) radius:radius startAngle:0 endAngle:M_PI/2.0 clockwise:1];
    [path addLineToPoint:CGPointMake(radius , height)];
    [path addArcWithCenter:CGPointMake(radius , height - radius) radius:radius startAngle:M_PI/2 endAngle:M_PI clockwise:1];
    [path addLineToPoint:CGPointMake(0, radius + arrowHeight)];
    [path closePath];
    UIColor *fillColor = [Utils colorWithHexString:@"#474747"];
    [fillColor set];
    [path fill];
    
    CGContextAddPath(ctx, path.CGPath);
    UIImage * getImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return getImage;
}

#pragma mark lazyload
- (NSMutableArray *)groupModels{
    if (_groupModels == nil) {
        _groupModels = [NSMutableArray array];
    }
    return _groupModels;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXEditGroupDetailNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXPublishGroupInfoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXDismissExitGroupNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXRefreshUserDetailNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXNotiFromServerNotification object:nil];
}
@end
