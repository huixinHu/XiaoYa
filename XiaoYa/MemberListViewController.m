//
//  MemberListViewController.m
//  XiaoYa
//
//  Created by commet on 2017/9/10.
//  Copyright © 2017年 commet. All rights reserved.
//成员列表页

#import "MemberListViewController.h"
#import "MemberCollectionViewCell.h"
#import "MemberDetailViewController.h"
#import "Utils.h"
#import "Masonry.h"
#import "GroupMemberModel.h"
#import "HXNotifyConfig.h"

static NSString *identifier = @"MemberListCollectionCell";
@interface MemberListViewController ()<UICollectionViewDelegate ,UICollectionViewDataSource>
@property (nonatomic ,weak) UICollectionView *collectionView;
@property (nonatomic ,strong) NSArray<GroupMemberModel *> *groupMembers;
@property (nonatomic ,assign) NSInteger totalCount;
@end

@implementation MemberListViewController

- (instancetype)initWithAllMembersModel:(NSArray <GroupMemberModel *>*)members totalMember:(NSInteger)memberCount{
    if (self = [super init]) {
        self.groupMembers = members;
        self.totalCount = memberCount;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self viewsSetting];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserDetail:) name:HXRefreshUserDetailNotification object:nil];//刷新用户信息
}

- (void)refreshUserDetail:(NSNotification *)notification{
    if (self.collectionView) {
        [self.collectionView reloadData];
    }
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark collectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    MemberDetailViewController *vc = [[MemberDetailViewController alloc] initWithMemberModel:self.groupMembers[indexPath.row] indexInGroup:indexPath.item];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark collectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.totalCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MemberCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    GroupMemberModel *memberModel = self.groupMembers[indexPath.item];
    if (memberModel) {
        cell.model = memberModel;
    }
    return cell;
}

#pragma mark viewsSetting
- (void)viewsSetting{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBg"] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[Utils colorWithHexString:@"#333333"],NSFontAttributeName:[UIFont systemFontOfSize:17]};
    self.navigationItem.title = @"群成员";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"导航栏返回图标"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.userInteractionEnabled = YES;
    
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
    [self.view addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.mas_equalTo(275);
        make.top.equalTo(self.view).offset(10);
        make.bottom.equalTo(self.view).offset(-10);
    }];
    _collectionView = collectionView;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXRefreshUserDetailNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
