//
//  LoginViewController.m
//  XiaoYa
//
//  Created by commet on 2017/6/6.
//  Copyright © 2017年 commet. All rights reserved.
//登录

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "ResetPhoneViewController.h"
#import "Utils.h"
#import "Masonry.h"
#import "HXTextField.h"
#import "BgView.h"
#import "HXNetworking.h"
#import "AppDelegate.h"
#import "HXNotifyConfig.h"
#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width

@interface LoginViewController ()<UITextFieldDelegate>
@property (nonatomic ,weak)HXTextField *account;
@property (nonatomic ,weak)HXTextField *pwd;
@property (nonatomic ,weak)UIButton *eye;
@property (nonatomic ,weak)UIButton *btn;
@property (nonatomic ,weak)UILabel *prompt;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self viewsSetting];
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    [self.view addGestureRecognizer:singleTap];
}

//注册
- (void)registerAccount{
    RegisterViewController *registerVC = [[RegisterViewController alloc]init];
    registerVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:registerVC animated:YES];
}

//返回
- (void)back{
    
}

//防止切换明文密文时光标移动
- (void)textSwitch:(UIButton *)sender{
    sender.selected = !sender.selected;
    NSString *tempPwdStr = self.pwd.text;
    self.pwd.text = @"";
    self.pwd.secureTextEntry = sender.selected;
    self.pwd.text = tempPwdStr;
}

//登录
- (void)login{
    [self.view endEditing:YES];
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"LOGIN",@"type",self.account.text,@"mobile",self.pwd.text,@"password", nil];
    __weak typeof (self)weakself = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [HXNetworking postWithUrl:httpUrl params:paraDict cache:NO success:^(NSURLSessionDataTask *task, id responseObject) {
            NSLog(@"dataID:%@",[responseObject objectForKey:@"identity"]);
            NSLog(@"dataMessage:%@",[responseObject objectForKey:@"message"]);
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[responseObject objectForKey:@"state"]boolValue] == 0) {//后台数据返回的问题。state实际上是一种__NSCFBoolean类型的数据，要转成bool再判断
                    if([[responseObject objectForKey:@"message"] isEqualToString:@"密码错误！"]){
                        weakself.prompt.text = @"密码错误(这里的文案有点问题";
                    }else if ([[responseObject objectForKey:@"message"] isEqualToString:@"手机号未注册！"]){
                        weakself.prompt.text = @"该号码未注册";
                    }
                }else{
                    UIViewController *temp = weakself.presentingViewController;//先取得presentingViewController。不先保存的话，popvc之后可能就为空了
                    [weakself.navigationController popToRootViewControllerAnimated:YES];
                    [temp dismissViewControllerAnimated:YES completion:^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:HXPushViewControllerNotification object:nil];
                    }];
                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    appDelegate.user = [responseObject objectForKey:@"identity"];
                    appDelegate.phone = weakself.account.text;
                }
            });
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"Error: %@", error);
        } refresh:NO];
    });
}

//重置密码
- (void)resetPwd{
    ResetPhoneViewController *resetVc = [[ResetPhoneViewController alloc]init];
    [self.navigationController pushViewController:resetVc animated:YES];
}

#pragma mark TextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

//和密码输入框切换明文密文有关的设置。防止切换后再输入时原内容被清空
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.pwd &&textField.isSecureTextEntry) {
        textField.text = toBeString;
        [self textFiledDidChange:textField];
        return NO;
    }
    return YES;
}

//点击空白处收回键盘
-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer{
    [self.view endEditing:YES];
}

- (void)textFiledDidChange:(UITextField *)textField{
    //密文状态下不会执行这个方法
    [self loginBtnCanBeSelected];
    self.prompt.text = @" ";
    if(self.account.text.length >= 11){
        self.account.text = [self.account.text substringToIndex:11];
        BOOL isValid = [Utils validMobile:self.account.text];
        if (!isValid) {
            self.prompt.text = @"请输入正确的手机号码格式";
        }
    }
}

- (void)loginBtnCanBeSelected{
    if (self.account.text.length == 11 && self.pwd.text.length > 0) {
        self.btn.enabled = YES;
        self.btn.backgroundColor = [Utils colorWithHexString:@"00a7fa"];
    }else{
        self.btn.enabled = NO;
        self.btn.backgroundColor = [Utils colorWithHexString:@"78cbf8"];
    }
}

#pragma mark viewssetting
- (void)viewsSetting{
    self.view.backgroundColor = [Utils colorWithHexString:@"#F0F0F6"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBg"] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[Utils colorWithHexString:@"#333333"],NSFontAttributeName:[UIFont systemFontOfSize:17]};
    self.navigationItem.title = @"登录";
    UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [rightBtn setTitle:@"注册" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[Utils colorWithHexString:@"#00a7fa"] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [rightBtn addTarget:self action:@selector(registerAccount) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"导航栏返回图标"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(back)];

    [self settingAccountAndPwdViews];
    [self settingLoginBtnAndForgetPwd];
}

- (void)settingAccountAndPwdViews{
    BgView *background = [[BgView alloc]init];
    background.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:background];
    [background mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenWidth, 80));
        make.top.equalTo(self.view.mas_top).offset(10);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    UIView *line3 = [[UIView alloc]init];//分割线
    line3.backgroundColor = [Utils colorWithHexString:@"#d9d9d9"];
    [background addSubview:line3];
    [line3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenWidth-13, 0.5));
        make.centerY.right.equalTo(background);
    }];
    
    HXTextField *account = [[HXTextField alloc]init];
    _account = account;
    [_account appearanceWithTextColor:[Utils colorWithHexString:@"#333333"] textFontSize:14.0 placeHolderColor:[Utils colorWithHexString:@"#d9d9d9"] placeHolderFontSize:14.0 placeHolderText:@"请输入您的手机号码" leftView:nil];
    [_account addTarget:self action:@selector(textFiledDidChange:) forControlEvents:UIControlEventEditingChanged];
    [background addSubview:_account];
    [_account mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(background.mas_left).offset(13);
        make.right.equalTo(background.mas_right).offset(-40);
        make.top.equalTo(background.mas_top);
        make.height.mas_equalTo(40);
    }];
    _account.keyboardType = UIKeyboardTypeNumberPad;
    _account.delegate = self;
    
    HXTextField *pwd = [[HXTextField alloc]init];
    _pwd = pwd;
    [_pwd appearanceWithTextColor:[Utils colorWithHexString:@"#333333"] textFontSize:14.0 placeHolderColor:[Utils colorWithHexString:@"#d9d9d9"] placeHolderFontSize:14.0 placeHolderText:@"请输入密码" leftView:nil];
    [_pwd addTarget:self action:@selector(textFiledDidChange:) forControlEvents:UIControlEventEditingChanged];
    [background addSubview:_pwd];
    [_pwd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(background.mas_left).offset(13);
        make.right.equalTo(background.mas_right).offset(-40);
        make.bottom.equalTo(background.mas_bottom);
        make.height.mas_equalTo(40);
    }];
    _pwd.keyboardType = UIKeyboardTypeASCIICapable;
    _pwd.delegate = self;
    self.pwd.secureTextEntry = YES;
    
    UIButton *eye = [[UIButton alloc]init];
    _eye = eye;
    [_eye setImage:[UIImage imageNamed:@"密码可见"] forState:UIControlStateNormal];
    [_eye setImage:[UIImage imageNamed:@"密码不可见"] forState:UIControlStateSelected];
    [_eye addTarget:self action:@selector(textSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [background addSubview:_eye];
    [_eye mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.left.equalTo(_pwd.mas_right);
        make.centerY.equalTo(_pwd.mas_centerY);
    }];
    _eye.selected = YES;
    
    UILabel *prompt = [[UILabel alloc]init];
    _prompt = prompt;
    _prompt.text = @" ";
    _prompt.font = [UIFont systemFontOfSize:12];
    _prompt.textColor = [Utils colorWithHexString:@"#ff0000"];
    [self.view addSubview:_prompt];
    [_prompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScreenWidth-26);
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(background.mas_bottom).offset(5);
    }];
}

- (void)settingLoginBtnAndForgetPwd{
    UIButton *btn = [[UIButton alloc]init];
    _btn = btn;
    [_btn setTitle:@"登录" forState:UIControlStateNormal];
    [_btn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    _btn.titleLabel.font = [UIFont systemFontOfSize:15];
    _btn.backgroundColor = [Utils colorWithHexString:@"78cbf8"];
    _btn.layer.cornerRadius = 5.0;
    _btn.enabled = NO;
    [self.view addSubview:_btn];
    [_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_prompt.mas_bottom).offset(5);
        make.left.equalTo(self.view.mas_left).offset(13);
        make.right.equalTo(self.view.mas_right).offset(-13);
        make.height.mas_equalTo(40);
    }];
    
    UIButton *findPwd = [[UIButton alloc]init];
    [self.view addSubview:findPwd];
    findPwd.titleLabel.font = [UIFont systemFontOfSize:12];
    [findPwd setTitle:@"找回密码" forState:UIControlStateNormal];
    [findPwd setTitleColor:[Utils colorWithHexString:@"#00a7fa"] forState:UIControlStateNormal];
    [findPwd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_btn.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(60, 36));
        make.right.equalTo(self.view.mas_right).offset(-13);
    }];
    [findPwd addTarget:self action:@selector(resetPwd) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
