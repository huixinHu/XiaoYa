//
//  ResetPwdViewController.m
//  XiaoYa
//
//  Created by commet on 2017/6/8.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "ResetPwdViewController.h"
#import "HXTextField.h"
#import "Utils.h"
#import "Masonry.h"
#import "HXNetworking.h"
#import "HXNotifyConfig.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
@class ResetTextCodeViewController;
@interface ResetPwdViewController ()<UITextFieldDelegate>
@property (nonatomic ,weak)HXTextField *pwd;
@property (nonatomic ,weak)UIButton *nextStep;
@property (nonatomic ,weak)UIButton *eye;
@property (nonatomic ,weak)UILabel *prompt;

@end

@implementation ResetPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewsSetting];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(textFieldValueChanged) name:UITextFieldTextDidChangeNotification object:self.pwd];
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    [self.view addGestureRecognizer:singleTap];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)next{
    BOOL isValid = [Utils validPwd:self.pwd.text];
    if (!isValid || self.pwd.text.length < 6 || self.pwd.text.length > 20) {
        self.prompt.text = @"密码格式错误";
        return;
    }else{
        NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"RESET",@"type",self.pwd.text,@"password", nil];
        __weak typeof (self)weakself = self;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [HXNetworking postWithUrl:httpUrl params:paraDict cache:NO success:^(NSURLSessionDataTask *task, id responseObject) {
                NSLog(@"dataID:%@",[responseObject objectForKey:@"identity"]);
                NSLog(@"dataMessage:%@",[responseObject objectForKey:@"message"]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([[responseObject objectForKey:@"state"]boolValue] == 0){
                        weakself.prompt.text = @"重置密码失败";
                    }else {
                        for (UIViewController *tempVC in weakself.navigationController.viewControllers) {
                            if ([tempVC isKindOfClass:NSClassFromString(@"LoginViewController")]) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [weakself.navigationController popToViewController:tempVC animated:YES];
                                });
                            }
                        }
                    }
                });
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog(@"Error: %@", error);
            } refresh:NO];
        });
    }
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
    self.prompt.text = @" ";
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
    self.navigationItem.title = @"找回密码";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"导航栏返回图标"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    
    //界面其他
    HXTextField *pwd = [[HXTextField alloc]init];
    _pwd = pwd;
    _pwd.backgroundColor = [UIColor whiteColor];
    UIView *lv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 13, 20)];
    [_pwd appearanceWithTextColor:[Utils colorWithHexString:@"#333333"] textFontSize:14.0 placeHolderColor:[Utils colorWithHexString:@"#d9d9d9"] placeHolderFontSize:14.0 placeHolderText:@"请设置新密码" leftView:lv];
    [self.view addSubview:_pwd];
    [_pwd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenWidth-40, 40));
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
    [_nextStep setTitle:@"完成" forState:UIControlStateNormal];
    [_nextStep addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    _nextStep.titleLabel.font = [UIFont systemFontOfSize:15];
    _nextStep.backgroundColor = [Utils colorWithHexString:@"78cbf8"];
    _nextStep.layer.cornerRadius = 5.0;
    _nextStep.enabled = NO;
    [self.view addSubview:_nextStep];
    [_nextStep mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_prompt.mas_bottom).offset(20);
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
    NSLog(@"销毁了");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.pwd];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
