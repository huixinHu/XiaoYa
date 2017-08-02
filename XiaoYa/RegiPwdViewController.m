//
//  RegiPwdViewController.m
//  XiaoYa
//
//  Created by commet on 2017/6/8.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "RegiPwdViewController.h"
#import "RegiNameViewController.h"
#import "HXTextField.h"
#import "Utils.h"
#import "Masonry.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width

@interface RegiPwdViewController ()<UITextFieldDelegate>
@property (nonatomic ,weak)HXTextField *pwd;
@property (nonatomic ,weak)UIButton *nextStep;
@property (nonatomic ,weak)UIButton *eye;
@property (nonatomic ,weak)UILabel *prompt;
@property (nonatomic ,copy)NSString *phoneNum;
@end

@implementation RegiPwdViewController
- (instancetype)initWithPhoneNum:(NSString *)phoneNum{
    if (self = [super init]) {
        self.phoneNum = phoneNum;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewsSetting];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(textFieldValueChanged) name:UITextFieldTextDidChangeNotification object:self.pwd];
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    [self.view addGestureRecognizer:singleTap];}

//返回
- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

//下一步
- (void)next{
    [self.view endEditing:YES];
    RegiNameViewController *nextVC = [[RegiNameViewController alloc]initWithPwd:self.pwd.text phoneNum:self.phoneNum];
    [self.navigationController pushViewController:nextVC animated:YES];
}

- (void)textSwitch:(UIButton *)sender{
    sender.selected = !sender.selected;
    NSString *tempPwdStr = self.pwd.text;
    self.pwd.text = @"";
    self.pwd.secureTextEntry = sender.selected;
    self.pwd.text = tempPwdStr;
}

#pragma mark textfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.pwd &&textField.isSecureTextEntry) {
        textField.text = toBeString;
        return NO;
    }
    return YES;
}

- (void)textFieldValueChanged{
    if (self.pwd.text.length > 0) {
        self.nextStep.enabled = YES;
        self.nextStep.backgroundColor = [Utils colorWithHexString:@"00a7fa"];
    }else{
        self.nextStep.enabled = NO;
        self.nextStep.backgroundColor = [Utils colorWithHexString:@"78cbf8"];
    }
    //    ^[A-Za-z0-9]+$
    BOOL isValid = [Utils validPwd:self.pwd.text];
    if (!isValid) {
        self.prompt.text = @"密码格式错误";
    }else{
        self.prompt.text = @" ";
    }
}

//点击空白处收回键盘
-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer{
    [self.view endEditing:YES];
}

#pragma mark viewssetting
- (void)viewsSetting{
    self.view.backgroundColor = [Utils colorWithHexString:@"#F0F0F6"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //导航栏
    self.navigationItem.title = @"注册";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"导航栏返回图标"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    
    //界面其他
    HXTextField *pwd = [[HXTextField alloc]init];
    _pwd = pwd;
    _pwd.backgroundColor = [UIColor whiteColor];
    UIView *lv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 13, 20)];
    [_pwd appearanceWithTextColor:[Utils colorWithHexString:@"#333333"] textFontSize:14.0 placeHolderColor:[Utils colorWithHexString:@"#d9d9d9"] placeHolderFontSize:14.0 placeHolderText:@"请设置登录密码" leftView:lv];
    [self.view addSubview:_pwd];
    [_pwd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenWidth - 40, 40));
        make.top.equalTo(self.view).offset(40);
        make.left.equalTo(self.view);
    }];
    _pwd.keyboardType = UIKeyboardTypeASCIICapable;
    _pwd.delegate = self;
    
    UILabel *lab = [[UILabel alloc]init];
    lab.text = @"密码由6-20位字符组成，包含字母和数字";
    lab.textColor = [Utils colorWithHexString:@"#999999"];
    lab.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:lab];
    [lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view.mas_top).offset(20);
    }];
    
    UILabel *prompt = [[UILabel alloc]init];
    _prompt = prompt;
    _prompt.text = @" ";
    _prompt.font = [UIFont systemFontOfSize:12];
    _prompt.textColor = [Utils colorWithHexString:@"#ff0000"];
    [self.view addSubview:_prompt];
    [_prompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScreenWidth-26);
        make.centerX.equalTo(self.view);
        make.top.equalTo(_pwd.mas_bottom).offset(5);
    }];
    
    UIButton *nextStep = [[UIButton alloc]init];
    _nextStep = nextStep;
    [_nextStep setTitle:@"下一步" forState:UIControlStateNormal];
    [_nextStep addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    _nextStep.titleLabel.font = [UIFont systemFontOfSize:15];
    _nextStep.backgroundColor = [Utils colorWithHexString:@"78cbf8"];
    _nextStep.layer.cornerRadius = 5.0;
    _nextStep.enabled = NO;
    [self.view addSubview:_nextStep];
    [_nextStep mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_prompt.mas_bottom).offset(5);
        make.size.mas_equalTo(CGSizeMake(kScreenWidth - 26, 40));
        make.centerX.equalTo(self.view);
    }];
    
    UIButton *eye = [[UIButton alloc]init];
    _eye = eye;
    [self.eye setBackgroundColor:[UIColor whiteColor]];
    [_eye setImage:[UIImage imageNamed:@"密码可见"] forState:UIControlStateNormal];
    [_eye setImage:[UIImage imageNamed:@"密码不可见"] forState:UIControlStateSelected];
    [_eye addTarget:self action:@selector(textSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_eye];
    [_eye mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.left.equalTo(_pwd.mas_right);
        make.centerY.equalTo(_pwd);
    }];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.pwd];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
