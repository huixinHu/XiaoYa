//
//  GroupDetailViewController.m
//  XiaoYa
//
//  Created by commet on 2017/8/1.
//  Copyright © 2017年 commet. All rights reserved.
//查看群资料

#import "GroupDetailViewController.h"
#import "MemberCollectionViewCell.h"
#import "MemberDetailViewController.h"
#import "MemberListViewController.h"
#import "EditGroupDetailViewController.h"
#import "GroupListModel.h"
#import "GroupMemberModel.h"
#import "Utils.h"
#import "Masonry.h"
#import "BgView.h"
#import "AppDelegate.h"
#import "UIAlertController+Appearance.h"
#import "HXNetworking.h"
#import "HXNotifyConfig.h"

static NSString *identifier = @"groupDetailCollectionCell";

@interface GroupDetailViewController () <UICollectionViewDataSource ,UICollectionViewDelegate>
@property (nonatomic ,weak) UIImageView *avatarImage;
@property (nonatomic ,weak) UILabel *groupName;
@property (nonatomic ,weak) UICollectionView *collectionView;
@property (nonatomic ,weak) UIButton *editBtn;
@property (nonatomic ,weak) UIButton *moreBtn;

@property (nonatomic ,strong) GroupListModel *groupModel;

@end

@implementation GroupDetailViewController
- (instancetype)initWithGroupInfo:(GroupListModel *)model{
    if (self = [super init]) {
        self.groupModel = [model copy];
        NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"GETUSERS",@"type",model.groupId,@"groupId",nil];
        __weak typeof(self) ws = self;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [HXNetworking postWithUrl:httpUrl params:paraDict cache:NO success:^(NSURLSessionDataTask *task, id response) {
                __strong typeof(ws) ss = ws;
                if ([[response objectForKey:@"state"]boolValue] == 0) {
                    NSLog(@"获取群组用户信息失败");
                } else{
                    NSArray *users = [response objectForKey:@"identity"];
                    NSMutableArray <GroupMemberModel *>*groupMembers = [NSMutableArray array];
                    [users enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSDictionary *userDict = (NSDictionary *)obj;
                        GroupMemberModel *model = [GroupMemberModel memberModelWithOneOfAllUserDict:userDict];
                        [groupMembers addObject:model];
                        ss.groupModel.groupMembers = groupMembers;
                    }];
                    [NSThread sleepForTimeInterval:1];//模拟网络延时
                    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:groupMembers forKey:HXRefreshUserDetailKey];
                    [[NSNotificationCenter defaultCenter] postNotificationName:HXRefreshUserDetailNotification object:nil userInfo:dataDict];
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog(@"Error: %@", error);
            } refresh:NO];
        });
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewsSetting];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserDetail:) name:HXRefreshUserDetailNotification object:nil];//刷新用户信息
}

//调用这个通知方法时，有可能控制器还没加载出来（没调viewDidLoad）
- (void)refreshUserDetail:(NSNotification *)notification{
    if (self.collectionView) {
        [self.collectionView reloadData];
    }
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)edit{
    __weak typeof(self) ws = self;
    EditGroupDetailViewController *vc = [[EditGroupDetailViewController alloc] initWithGroupModel:self.groupModel successBlock:^(GroupListModel *model) {
        ws.groupModel = model;
        [ws settingImage:[model.groupAvatarId integerValue]];
        ws.groupName.text = model.groupName;
        [ws.collectionView reloadData];
        if (model.groupMembers.count > 4) {
            ws.moreBtn.hidden = NO;
        } else{
            ws.moreBtn.hidden = YES;
        }
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)allMembers{
    MemberListViewController *memberListVC = [[MemberListViewController alloc] initWithAllMembersModel:self.groupModel.groupMembers totalMember:self.groupModel.numberOfMember];
    [self.navigationController pushViewController:memberListVC animated:YES];
}

- (void)exit{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    __weak typeof(self) ws = self;
    if (appDelegate.userid.intValue == self.groupModel.managerId.intValue) {//解散群
        void (^otherBlock)(UIAlertAction *action) = ^(UIAlertAction *action){
            __strong typeof(ws) ss = ws;
            NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"DISMISSGROUP",@"type",ss.groupModel.groupId,@"groupId",appDelegate.userid,@"managerId",nil];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                __strong typeof(ws) ss = ws;
                [HXNetworking postWithUrl:httpUrl params:paraDict cache:NO success:^(NSURLSessionDataTask *task, id response) {
                    if ([[response objectForKey:@"state"]boolValue] == 0){
                        NSLog(@"解散群组失败");
                    }else {
                        NSDictionary *dataDict = [NSDictionary dictionaryWithObject:ss.groupModel.groupId forKey:HXDismissExitGroupKey];
                        [[NSNotificationCenter defaultCenter] postNotificationName:HXDismissExitGroupNotification object:nil userInfo:dataDict];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            for (UIViewController *tempVC in ss.navigationController.viewControllers) {
                                if ([tempVC isKindOfClass:NSClassFromString(@"GroupHomePageViewController")]) {
                                    [ss.navigationController popToViewController:tempVC animated:YES];
                                }
                            }
                        });
                    }
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    NSLog(@"Error: %@", error);
                } refresh:NO];
            });
        };
        NSArray *otherBlocks = @[otherBlock];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"解散群组" message:@"是否确定解散？" preferredStyle:UIAlertControllerStyleAlert cancelTitle:@"取消" cancelBlock:nil otherTitles:@[@"确定"] otherBlocks:otherBlocks];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    } else {//退出群
        void (^otherBlock)(UIAlertAction *action) = ^(UIAlertAction *action){
            __strong typeof(ws) ss = ws;
            NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"SIGNOUTGROUP",@"type",appDelegate.userid,@"userId",ss.groupModel.groupId,@"groupId",nil];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [HXNetworking postWithUrl:httpUrl params:paraDict cache:NO success:^(NSURLSessionDataTask *task, id response) {
                    if ([[response objectForKey:@"state"]boolValue] == 0){
                        NSLog(@"退出群组失败");
                    }else {
                        NSDictionary *dataDict = [NSDictionary dictionaryWithObject:ss.groupModel.groupId forKey:HXDismissExitGroupKey];
                        [[NSNotificationCenter defaultCenter] postNotificationName:HXDismissExitGroupNotification object:nil userInfo:dataDict];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            for (UIViewController *tempVC in ws.navigationController.viewControllers) {
                                if ([tempVC isKindOfClass:NSClassFromString(@"GroupHomePageViewController")]) {
                                    [ws.navigationController popToViewController:tempVC animated:YES];
                                }
                            }
                        });
                    }
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    NSLog(@"Error: %@", error);
                } refresh:NO];
            });
        };
        NSArray *otherBlocks = @[otherBlock];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"退出群组" message:@"是否确定退出？" preferredStyle:UIAlertControllerStyleAlert cancelTitle:@"取消" cancelBlock:nil otherTitles:@[@"确定"] otherBlocks:otherBlocks];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
}

#pragma mark collectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    MemberDetailViewController *vc = [[MemberDetailViewController alloc] initWithMemberModel:self.groupModel.groupMembers[indexPath.row] indexInGroup:indexPath.item];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark collectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.groupModel.numberOfMember >= 4) {
        return 4;
    }else{
        return self.groupModel.numberOfMember;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MemberCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    GroupMemberModel *memberModel = self.groupModel.groupMembers[indexPath.item];
    if (memberModel) {
        cell.model = memberModel;
    }
    return cell;
}

#pragma mark viewsSetting
- (void)viewsSetting{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBg"] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[Utils colorWithHexString:@"#333333"],NSFontAttributeName:[UIFont systemFontOfSize:17]};
    self.navigationItem.title = @"群资料";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"导航栏返回图标"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    
    UIButton *editBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [editBtn setTitleColor:[Utils colorWithHexString:@"#00a7fa"] forState:UIControlStateNormal];
    editBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    _editBtn = editBtn;//要判断是否群主
    [editBtn addTarget:self action:@selector(edit) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:editBtn];
    
    self.view.backgroundColor = [Utils colorWithHexString:@"#F0F0F6"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.userInteractionEnabled = YES;

    [self avatarAndNameSetting];
    [self memberListSetting];
}

- (void)avatarAndNameSetting{
    BgView *bg = [[BgView alloc]init];
    bg.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bg];
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(180);
        make.width.centerX.top.equalTo(self.view);
    }];
    
    UIImageView *avatar = [[UIImageView alloc]init];
    _avatarImage = avatar;
    [self settingImage:[self.groupModel.groupAvatarId integerValue]];
    [bg addSubview:_avatarImage];
    [_avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 100));
        make.centerX.equalTo(bg);
        make.top.equalTo(bg).offset(19);
    }];
    
    UILabel *groupName = [[UILabel alloc]init];
    _groupName = groupName;
    _groupName.text = self.groupModel.groupName;
    _groupName.textColor = [Utils colorWithHexString:@"#333333"];
    _groupName.font = [UIFont systemFontOfSize:15];
    [bg addSubview:_groupName];
    [_groupName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bg);
        make.top.equalTo(_avatarImage.mas_bottom).offset(24);
    }];
}

- (void)memberListSetting{
    BgView *bg2 = [[BgView alloc]init];
    bg2.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bg2];
    [bg2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.centerX.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(190);
    }];
    
    UILabel *lab = [[UILabel alloc]init];
    lab.text = @"添加成员";
    lab.textColor = [Utils colorWithHexString:@"#999999"];
    lab.font = [UIFont systemFontOfSize:15];
    [bg2 addSubview:lab];
    [lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bg2).offset(12);
        make.left.equalTo(bg2).offset(12);
    }];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(50, 75);
    flowLayout.minimumInteritemSpacing = 25;
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.bounces = NO;
    [collectionView registerClass:[MemberCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    [bg2 addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(275, 75));
        make.centerX.equalTo(bg2);
        make.top.equalTo(lab.mas_bottom).offset(20);
    }];
    _collectionView = collectionView;
    
    UIButton *moreBtn = [[UIButton alloc] init];
    moreBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [moreBtn setTitle:@"查看全部成员" forState:UIControlStateNormal];
    [moreBtn setTitleColor:[Utils colorWithHexString:@"#00a7fa"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(allMembers) forControlEvents:UIControlEventTouchUpInside];
    [bg2 addSubview:moreBtn];
    [moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(collectionView);
        make.top.equalTo(collectionView.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(100, 30));
    }];
    if (self.groupModel.numberOfMember > 4) {
        moreBtn.hidden = NO;
    } else{
        moreBtn.hidden = YES;
    }
    _moreBtn = moreBtn;
    
    UIButton *exit = [[UIButton alloc]init];
    exit.titleLabel.font = [UIFont systemFontOfSize:15];
    exit.backgroundColor = [Utils colorWithHexString:@"#00a7fa"];
    exit.layer.cornerRadius = 5;
    [exit addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
    [bg2 addSubview:exit];
    [exit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(125, 40));
        make.top.equalTo(collectionView.mas_bottom).offset(50);
        make.centerX.equalTo(self.view);
    }];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.userid.intValue == self.groupModel.managerId.intValue) {
        self.editBtn.hidden = NO;
        [exit setTitle:@"解散该群" forState:UIControlStateNormal];
    } else{
        self.editBtn.hidden = YES;
        [exit setTitle:@"退出群组" forState:UIControlStateNormal];
    }
}

- (void)settingImage:(NSInteger)imageId{
    switch (imageId) {
        case 0:
            _avatarImage.image = [UIImage imageNamed:@"头像1"];
            break;
        case 1:
            _avatarImage.image = [UIImage imageNamed:@"头像2"];
            break;
        case 2:
            _avatarImage.image = [UIImage imageNamed:@"头像3"];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXRefreshUserDetailNotification object:nil];
}

@end
