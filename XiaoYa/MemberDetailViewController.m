//
//  MemberDetailViewController.m
//  XiaoYa
//
//  Created by commet on 2017/9/9.
//  Copyright © 2017年 commet. All rights reserved.
// 成员详情页

#import "MemberDetailViewController.h"
#import "GroupMemberModel.h"
#import "Utils.h"
#import "Masonry.h"
#import "HXNotifyConfig.h"

@interface MemberDetailViewController ()
@property (nonatomic ,strong) GroupMemberModel *model;
@property (nonatomic ,weak) UIImageView *avatar;
@property (nonatomic ,weak) UILabel *name;
@property (nonatomic ,weak) UILabel *phone;
@end

@implementation MemberDetailViewController
{
    NSInteger _index;
}
- (instancetype)initWithMemberModel:(GroupMemberModel *)model indexInGroup:(NSInteger)index{
    if (self = [super init]) {
        self.model = model;
        _index = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self viewsSetting];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserDetail:) name:HXRefreshUserDetailNotification object:nil];//刷新用户信息
}

- (void)refreshUserDetail:(NSNotification *)notification{
    NSDictionary *refreshInfo = [notification userInfo];
    NSMutableArray <GroupMemberModel *> *modelArr = [refreshInfo objectForKey:HXRefreshUserDetailKey];
    GroupMemberModel *member = modelArr[_index];
    self.avatar.image = member.memberAvatar;
    self.name.text = member.memberName;
    self.phone.text = member.memberPhone;
}

#pragma mark viewsSetting
- (void)viewsSetting{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBg"] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[Utils colorWithHexString:@"#333333"],NSFontAttributeName:[UIFont systemFontOfSize:17]};
    self.navigationItem.title = @"成员";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"导航栏返回图标"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.userInteractionEnabled = YES;
    
    UIImageView *avatar = [[UIImageView alloc]init];
    if (self.model.memberAvatar) {
        avatar.image = self.model.memberAvatar;
    } else {
        avatar.image = [UIImage imageNamed:@"未登录头像"];
    }
    [self.view addSubview:avatar];
    [avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(75, 75));
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(55);
    }];
    _avatar = avatar;
    
    UILabel *name = [[UILabel alloc]init];
    name.text = self.model.memberName;
    name.textAlignment = NSTextAlignmentCenter;
    name.textColor = [Utils colorWithHexString:@"#333333"];
    name.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:name];
    [name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(avatar.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(100, 20));
    }];
    _name = name;
    
    UILabel *phone = [[UILabel alloc]init];
    phone.text = self.model.memberPhone;
    phone.textAlignment = NSTextAlignmentCenter;
    phone.textColor = [Utils colorWithHexString:@"#333333"];
    phone.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:phone];
    [phone mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(name.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(250, 20));
    }];
    _phone = phone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXRefreshUserDetailNotification object:nil];
}

@end
