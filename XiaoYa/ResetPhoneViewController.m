//
//  ResetPhoneViewController.m
//  XiaoYa
//
//  Created by commet on 2017/6/8.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "ResetPhoneViewController.h"
#import "ResetTextCodeViewController.h"
#import "HXTextField.h"
#import "Utils.h"
#import "Masonry.h"
#import "HXNetworking.h"
#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width

@interface ResetPhoneViewController ()<UITextFieldDelegate>
@property (nonatomic ,weak)HXTextField *phoneNumber;
@property (nonatomic ,weak)UIButton *checkCode;
@property (nonatomic ,weak)UILabel *phonePrompt;

@end

@implementation ResetPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewsSetting];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(textFieldValueChanged) name:UITextFieldTextDidChangeNotification object:self.phoneNumber];
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    [self.view addGestureRecognizer:singleTap];
}

//返回
- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)receiveCheckCode{
    [self.view endEditing:YES];
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"RESETSME",@"type",self.phoneNumber.text,@"mobile", nil];
    __weak typeof (self)weakself = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [HXNetworking postWithUrl:@"http://139.199.170.95:8080/moyuzaiServer/Controller" params:paraDict success:^(NSURLSessionDataTask *task, id responseObject) {
            NSLog(@"dataID:%@",[responseObject objectForKey:@"identity"]);
            NSLog(@"dataMessage:%@",[responseObject objectForKey:@"message"]);
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[responseObject objectForKey:@"state"]boolValue] == 0){
                    if([[responseObject objectForKey:@"message"] isEqualToString:@"手机号已注册！"]){
                        weakself.phonePrompt.text = @"该手机号已被注册";
                    }else if ([[responseObject objectForKey:@"message"] isEqualToString:@"验证码发送失败！"]){
                        weakself.phonePrompt.text = @"验证码获取失败！";
                    }
                }else {
                    ResetTextCodeViewController *nextVC = [[ResetTextCodeViewController alloc]initWithPhoneNum:weakself.phoneNumber.text];
                    [weakself.navigationController pushViewController:nextVC animated:YES];
                }
            });
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"Error: %@", error);
        } refresh:NO];
    });
}

#pragma mark textfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldValueChanged{
    if (self.phoneNumber.text.length >= 11) {
        self.phoneNumber.text = [self.phoneNumber.text substringToIndex:11];
        self.checkCode.enabled = YES;
        self.checkCode.backgroundColor = [Utils colorWithHexString:@"00a7fa"];
        BOOL isValid = [Utils validMobile:self.phoneNumber.text];
        if (!isValid) {
            self.phonePrompt.text = @"请输入正确的手机号码格式";
        }
    }else{
        self.checkCode.enabled = NO;
        self.checkCode.backgroundColor = [Utils colorWithHexString:@"78cbf8"];
        self.phonePrompt.text = @" ";
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
    self.navigationItem.title = @"找回密码";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"导航栏返回图标"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    //界面其他
    HXTextField *phoneNumber = [[HXTextField alloc]init];
    _phoneNumber = phoneNumber;
    _phoneNumber.backgroundColor = [UIColor whiteColor];
    UIView *lv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 13, 20)];
    [_phoneNumber appearanceWithTextColor:[Utils colorWithHexString:@"#333333"] textFontSize:14.0 placeHolderColor:[Utils colorWithHexString:@"#d9d9d9"] placeHolderFontSize:14.0 placeHolderText:@"请输入您的手机号码" leftView:lv];
    [self.view addSubview:_phoneNumber];
    [_phoneNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenWidth, 40));
        make.top.equalTo(self.view).offset(10);
        make.centerX.equalTo(self.view);
    }];
    _phoneNumber.keyboardType = UIKeyboardTypeNumberPad;
    _phoneNumber.delegate = self;
    
    UILabel *prompt = [[UILabel alloc]init];
    _phonePrompt = prompt;
    _phonePrompt.text = @" ";
    _phonePrompt.font = [UIFont systemFontOfSize:12];
    _phonePrompt.textColor = [Utils colorWithHexString:@"#ff0000"];
    [self.view addSubview:_phonePrompt];
    [_phonePrompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScreenWidth-26);
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(_phoneNumber.mas_bottom).offset(5);
    }];
    
    UIButton *checkCode = [[UIButton alloc]init];
    _checkCode = checkCode;
    [_checkCode setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_checkCode addTarget:self action:@selector(receiveCheckCode) forControlEvents:UIControlEventTouchUpInside];
    _checkCode.titleLabel.font = [UIFont systemFontOfSize:15];
    _checkCode.backgroundColor = [Utils colorWithHexString:@"78cbf8"];
    _checkCode.layer.cornerRadius = 5.0;
    _checkCode.enabled = NO;
    [self.view addSubview:_checkCode];
    [_checkCode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_phonePrompt.mas_bottom).offset(5);
        make.size.mas_equalTo(CGSizeMake(kScreenWidth - 26, 40));
        make.centerX.equalTo(self.view);
    }];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.phoneNumber];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
