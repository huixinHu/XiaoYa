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
#import "GroupHomePageCell.h"
#import "Utils.h"
#import "Masonry.h"
#import "TxAvatar.h"
#import "AppDelegate.h"
#import "HXNotifyConfig.h"
#import "HXDBManager.h"
#import "MBProgressHUD.h"

@interface GroupHomePageViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,weak)UIImageView *menu;
@property (nonatomic ,weak)UITableView *groupTable;
@property (nonatomic ,weak)UIButton *menuBtn;
@property (nonatomic ,strong)NSMutableArray <GroupListModel *> *groupModels;//群组模型数组
@property (nonatomic ,strong) HXDBManager *hxDB;
@property (nonatomic ,strong) MBProgressHUD *hud;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGroupInfo:) name:HXPublishGroupInfoNotification object:nil];//刷新群消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGroupList:) name:HXDismissExitGroupNotification object:nil];//刷新群消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserDetail:) name:HXRefreshUserDetailNotification object:nil];//刷新成员信息
}

- (void)dbSetting{
    self.hxDB = [HXDBManager shareInstance];
    [self.hxDB createTable:@"groupTable" colDict:@{@"groupId":@"TEXT",@"groupName":@"TEXT",@"groupAvatarId":@"TEXT",@"numberOfMembers":@"TEXT",@"groupManagerId":@"TEXT"} isPrimaryKey:YES primaryKeyIndex:0];
    [self.hxDB createTable:@"memberTable" colDict:@{@"memberId":@"TEXT",@"memberName":@"TEXT",@"memberphone":@"TEXT"} isPrimaryKey:YES primaryKeyIndex:0];

    [self.hxDB tableCreate:@"CREATE TABLE IF NOT EXISTS memberGroupRelation (memberId TEXT,groupId TEXT,FOREIGN KEY(groupId) REFERENCES groupTable(groupId) ON DELETE CASCADE);" table:@"memberGroupRelation"];
    [self.hxDB tableCreate:@"CREATE TABLE IF NOT EXISTS groupInfoTable(publishTime TEXT,publisher TEXT,eventDate TEXT,eventSection TEXT,event TEXT,deadlineIndex TEXT,groupId TEXT,FOREIGN KEY(groupId) REFERENCES groupTable(groupId) ON DELETE CASCADE);" table:@"groupInfoTable"];

//        [self.hxDB insertTable:@"groupTable" param:@{@"groupId":@"75",@"groupName":@"测试",@"groupAvatarId":@"0",@"numberOfMembers":@"2",@"groupManagerId":@"7"} callback:nil];
////        [self.hxDB insertTable:@"memberTable" param:@{@"memberId":@"7",@"memberName":@"彗星",@"memberphone":@"15918887876"} callback:nil];
//        [self.hxDB insertTable:@"memberTable" param:@{@"memberId":@"8",@"memberName":@"巫辉强",@"memberphone":@"13660259565"} callback:nil];
//        [self.hxDB insertTable:@"memberGroupRelation" param:@{@"memberId":@"7",@"groupId":@"75"} callback:nil];
//        [self.hxDB insertTable:@"memberGroupRelation" param:@{@"memberId":@"8",@"groupId":@"75"} callback:nil];
    
    NSArray *groupArr = [self.hxDB queryAll:@"groupTable" callback:^(NSError *error) {
        if (error) {
            NSLog(@"%@",error.userInfo[NSLocalizedDescriptionKey]);
        }
    }];
    for (NSDictionary *dict in groupArr) {
        GroupListModel *model = [GroupListModel groupWithDict:dict];
        [self.groupModels addObject:model];
    }
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
    [self.groupModels enumerateObjectsUsingBlock:^(GroupListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.groupId == refreshModel.groupId) {
            obj.groupMembers = [refreshModel.groupMembers mutableCopy];
            obj.groupName = refreshModel.groupName;
            obj.groupAvatarId = refreshModel.groupAvatarId;
            obj.numberOfMember = refreshModel.numberOfMember;
            *stop = YES;
        }
    }];
}

//自己发布了群消息
- (void)refreshGroupInfo:(NSNotification *)notification{
    GroupInfoModel *refreshModel = [[notification userInfo] objectForKey:HXNewGroupInfo];
    NSString *gid = [[notification userInfo] objectForKey:HXGroupID];
    [self.groupModels enumerateObjectsUsingBlock:^(GroupListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.groupId == gid) {
            if (obj.groupEvents) {//不为空
                [obj.groupEvents insertObject:refreshModel atIndex:0];
            } else{
                obj.groupEvents = [NSMutableArray arrayWithObject:refreshModel];
            }
        }
    }];
}

//解散群或者退出群
- (void)refreshGroupList:(NSNotification *)notification{
    NSString *groupId = [[notification userInfo] objectForKey:HXDismissExitGroupKey];
    __block NSInteger deleteIndex = 0;
    [self.groupModels enumerateObjectsUsingBlock:^(GroupListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.groupId == groupId) {
            deleteIndex = idx;
            *stop = YES;
        }
    }];
    [self.groupModels removeObjectAtIndex:deleteIndex];
}

//刷新成员信息
- (void)refreshUserDetail:(NSNotification *)notification{
    NSMutableArray <GroupMemberModel *> *membersModel =  [[notification userInfo] objectForKey:HXRefreshUserDetailKey];
    NSString *groupId = [[notification userInfo] objectForKey:@"groupId"];
    [self.groupModels enumerateObjectsUsingBlock:^(GroupListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.groupId == groupId) {
            obj.groupMembers = [membersModel mutableCopy];
            *stop = YES;
        }
    }];
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
    }];
    createVC.hidesBottomBarWhenPushed = YES;//从下级vc开始，tabbar都隐藏掉
    [self.navigationController pushViewController:createVC animated:YES];
    _menuBtn.selected = NO;
    _menu.hidden = YES;
}

- (void)join{
    __weak typeof(self) ws = self;
    JoinGroupViewController *joinVC = [[JoinGroupViewController alloc] initWithJoinSuccessBlock:^(GroupListModel *model) {
        [ws.groupModels insertObject:model atIndex:0];
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
//        NSString *path = [[NSBundle mainBundle]pathForResource:@"test.plist" ofType:nil];
//        NSArray *arrayDict = [NSArray arrayWithContentsOfFile:path];
//        NSMutableArray *arrModels = [NSMutableArray array];
//        for (NSDictionary *dict in arrayDict) {
//            GroupListModel *model = [GroupListModel groupWithDict:dict];
//            [arrModels addObject:model];
//        }
//        _groupModels = arrModels;
        _groupModels = [NSMutableArray array];
    }
    return _groupModels;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXEditGroupDetailNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXPublishGroupInfoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXDismissExitGroupNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXRefreshUserDetailNotification object:nil];
}
@end
