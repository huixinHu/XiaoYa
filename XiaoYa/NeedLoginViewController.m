//
//  NeedLoginViewController.m
//  XiaoYa
//
//  Created by commet on 2017/7/20.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "NeedLoginViewController.h"
#import "RegisterViewController.h"
#import "LoginViewController.h"
#import "Utils.h"
#import "Masonry.h"
#import "LoginManager.h"
@interface NeedLoginViewController ()
@property (nonatomic ,weak) UIButton *loginBtn;
@end

@implementation NeedLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self viewsSetting];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)userRegister{
    RegisterViewController *regVC = [[RegisterViewController alloc]init];
    regVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:regVC animated:YES];
}

- (void)cancel{
    [self dismissViewControllerAnimated:YES completion:^{
        //[[NSNotificationCenter defaultCenter]postNotificationName:HXDismissViewControllerNotification object:nil];
    }];
}

- (void)login{
    LoginViewController *loginVC = [[LoginViewController alloc]init];
    loginVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:loginVC animated:YES];
}

- (void)viewsSetting{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [Utils colorWithHexString:@"#F0F0F6"];
    //导航栏
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[Utils colorWithHexString:@"#333333"],NSFontAttributeName:[UIFont systemFontOfSize:17]};
    self.navigationItem.title = @"群组";
    UIButton *regi = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    regi.titleLabel.font = [UIFont systemFontOfSize:15];
    [regi setTitleColor:[Utils colorWithHexString:@"#00a7fa"] forState:UIControlStateNormal];
    [regi setTitle:@"注册" forState:UIControlStateNormal];
    [regi addTarget:self action:@selector(userRegister) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:regi];
    
    UIButton *cancel = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    cancel.titleLabel.font = [UIFont systemFontOfSize:15];
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel setTitleColor:[Utils colorWithHexString:@"#00a7fa"] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancel];
    
    __weak typeof(self)weakself = self;
    UIButton *loginBtn = [[UIButton alloc]init];
    _loginBtn = loginBtn;
    [_loginBtn setTitle:@"立即登录" forState:UIControlStateNormal];
    _loginBtn.backgroundColor = [Utils colorWithHexString:@"#00a7fa"];
    _loginBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    _loginBtn.layer.cornerRadius = 5;
    [_loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginBtn];
    [_loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(125, 40));
        make.top.equalTo(weakself.view.mas_centerY);
        make.centerX.equalTo(weakself.view);
    }];
    
    UILabel *text1 = [[UILabel alloc]init];
    text1.font = [UIFont systemFontOfSize:11];
    text1.textColor = [Utils colorWithHexString:@"#999999"];
    text1.text = @"登陆后才能进行相关操作";
    [self.view addSubview:text1];
    [text1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view);
        make.bottom.equalTo(_loginBtn.mas_top).offset(-20);
    }];
    
    UILabel *text2 = [[UILabel alloc]init];
    text2.font = [UIFont systemFontOfSize:17];
    text2.textColor = [Utils colorWithHexString:@"#333333"];
    text2.text = @"您还未登录";
    [self.view addSubview:text2];
    [text2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view);
        make.bottom.equalTo(text1.mas_top).offset(-15);
    }];
    
    UIImageView *img = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"未登录头像"]];
    [self.view addSubview:img];
    [img mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view);
        make.size.mas_equalTo(CGSizeMake(100, 100));
        make.bottom.equalTo(text2.mas_top).offset(-15);
    }];
}

@end
