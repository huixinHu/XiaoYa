//
//  GroupDetailViewController.m
//  XiaoYa
//
//  Created by commet on 2017/8/1.
//  Copyright © 2017年 commet. All rights reserved.
//查看群资料

#import "GroupDetailViewController.h"
//#import "ProtoMessage.pbobjc.h"
//#import "GCDAsyncSocket.h"
#import "GroupListModel.h"
#import "GroupMemberModel.h"
#import "Utils.h"
#import "Masonry.h"
#import "BgView.h"
#import "MemberCollectionViewCell.h"
#import "MemberDetailViewController.h"
#import "MemberListViewController.h"

static NSString *identifier = @"groupDetailCollectionCell";

@interface GroupDetailViewController () <UICollectionViewDataSource ,UICollectionViewDelegate>
//@property (nonatomic)GCDAsyncSocket *socket;
@property (nonatomic ,strong) GroupListModel *info;
@property (nonatomic ,weak) UIImageView *avatarImage;
@property (nonatomic ,weak) UILabel *groupName;
@property (nonatomic ,weak) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray <GroupMemberModel *> *dataArray;//存储数据(模型)

@end

@implementation GroupDetailViewController
- (instancetype)initWithGroupInfo:(GroupListModel *)model{
    if (self = [super init]) {
        self.info = model;
        self.dataArray = model.groupMembers;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 50, 50)];
//    btn.backgroundColor = [UIColor redColor];
//    [self.view addSubview:btn];
//    [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
//
//    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
//    NSError *error = nil;
//    [socket connectToHost:@"139.199.170.95" onPort:8989 error:&error];
//    self.socket = socket;
    [self viewsSetting];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)allMembers{
    MemberListViewController *memberListVC = [[MemberListViewController alloc] initWithAllMembersModel:self.dataArray];
    [self.navigationController pushViewController:memberListVC animated:YES];
}

#pragma mark collectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    MemberDetailViewController *vc = [[MemberDetailViewController alloc] initWithMemberModel:self.dataArray[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark collectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.dataArray.count >= 4) {
        return 4;
    }else{
        return self.dataArray.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MemberCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    GroupMemberModel *memberModel = self.dataArray[indexPath.item];
    cell.model = memberModel;
    return cell;
}

#pragma mark viewsSetting
- (void)viewsSetting{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBg"] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[Utils colorWithHexString:@"#333333"],NSFontAttributeName:[UIFont systemFontOfSize:17]};
    self.navigationItem.title = @"群资料";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"导航栏返回图标"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
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
    switch (self.info.groupAvatarId) {
        case 101:
            _avatarImage.image = [UIImage imageNamed:@"头像1"];
            break;
        case 102:
            _avatarImage.image = [UIImage imageNamed:@"头像2"];
            break;
        case 103:
            _avatarImage.image = [UIImage imageNamed:@"头像3"];
            break;
        default:
            break;
    }
    [bg addSubview:_avatarImage];
    [_avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 100));
        make.centerX.equalTo(bg);
        make.top.equalTo(bg).offset(19);
    }];
    
    UILabel *groupName = [[UILabel alloc]init];
    _groupName = groupName;
    _groupName.text = self.info.groupName;
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
    if (self.dataArray.count > 4) {
        moreBtn.hidden = NO;
    } else{
        moreBtn.hidden = YES;
    }
}

//- (void)click{
//    ProtoMessage* s1 = [[ProtoMessage alloc]init];
//    s1.type = ProtoMessage_Type_Chat;
//    s1.from = @"胡卉馨(17)";
//    s1.to = @"13";
//    s1.time = @"2017/7/27";
//    s1.body = @"hello";
//    NSData *data = [s1 data];
//    NSLog(@"要发送的数据：%@",data);
//    Byte *byteArr = (Byte *)[data bytes];
//    [self.socket writeData:data withTimeout:-1 tag:100];
//}
//
//- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
//    NSLog(@"%@",data);
//    
//    ProtoMessage *s2 = [ProtoMessage parseFromData:data error:NULL];
//    NSLog(@"type:%d,from:%@,to:%@,time:%@,body:%@",s2.type,s2.from,s2.to,s2.time,s2.body);
//    
//    NSString *data2Str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"%@",data2Str);
//    
//
//    [sock readDataWithTimeout:-1 tag:100];
//}
//
//- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
//    NSLog(@"发送数据成功");
//}
//
//- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
//    NSLog(@"连接成功");
//    [self.socket readDataWithTimeout:-1 tag:100];
//    //心跳处理
//}
//
//- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
//    NSLog(@"连接失败:%@",err);
//    //重连处理
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
