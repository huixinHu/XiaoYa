//
//  ResetTextCodeViewController.m
//  XiaoYa
//
//  Created by commet on 2017/6/8.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "ResetTextCodeViewController.h"
#import "ResetPwdViewController.h"
#import "HXTextField.h"
#import "HXButton.h"
#import "Utils.h"
#import "Masonry.h"
#import "NSTimer+Addition.h"
#import "HXNetworking.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
@interface ResetTextCodeViewController ()<UITextFieldDelegate>
@property (nonatomic ,weak)HXTextField *textCode;
@property (nonatomic ,weak)UIButton *nextStep;
@property (nonatomic ,copy)NSString *phoneNum;
@property (nonatomic ,strong)NSThread *thread;
@property (nonatomic ,weak)HXButton *timerBtn;
@property (nonatomic ,weak)UILabel *prompt;

@end

@implementation ResetTextCodeViewController

- (instancetype)initWithPhoneNum:(NSString *)phoneNum{
    if (self = [super init]) {
        self.phoneNum = phoneNum;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewsSetting];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(textFieldValueChanged) name:UITextFieldTextDidChangeNotification object:self.textCode];
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    [self.view addGestureRecognizer:singleTap];
    
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)next{
    [self.view endEditing:YES];
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"MATCH",@"type",self.textCode.text,@"textCode", nil];
    __weak typeof (self)weakself = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [HXNetworking postWithUrl:@"http://139.199.170.95:8080/moyuzaiServer/Controller" params:paraDict success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *responseDict = (NSDictionary *)responseObject;
            NSLog(@"dataID:%@",[responseDict objectForKey:@"identity"]);
            NSLog(@"dataMessage:%@",[responseDict objectForKey:@"message"]);
            NSLog(@"dataState:%@",[responseDict objectForKey:@"state"]);
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[responseDict objectForKey:@"state"]boolValue] == 0){
                    if([[responseDict objectForKey:@"message"]  isEqual: @"验证失败！请核对您输入的验证码是否正确。"]){
                        weakself.prompt.text = @"验证码错误";
                    }
                }else {
                    ResetPwdViewController *nextVC = [[ResetPwdViewController alloc]init];
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
    if (self.textCode.text.length > 0) {
        self.nextStep.enabled = YES;
        self.nextStep.backgroundColor = [Utils colorWithHexString:@"00a7fa"];
    }else{
        self.nextStep.enabled = NO;
        self.nextStep.backgroundColor = [Utils colorWithHexString:@"78cbf8"];
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
    __weak typeof(self)weakself = self;
    HXButton *timerBtn = [[HXButton alloc]initWithFrame:CGRectMake(0, 0, 80, 30) timerCount:60 timerInerval:1.0 networkRequest:^{
        NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"RESETSME",@"type",weakself.phoneNum,@"mobile", nil];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [HXNetworking postWithUrl:@"http://139.199.170.95:8080/moyuzaiServer/Controller" params:paraDict success:^(NSURLSessionDataTask *task, id responseObject) {
                NSLog(@"dataMessage:%@",[responseObject objectForKey:@"message"]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([[responseObject objectForKey:@"state"]boolValue] == 0){
                        if ([[responseObject objectForKey:@"message"] isEqualToString:@"验证码发送失败！"]){
                            weakself.prompt.text = @"验证码获取失败！";
                        }
                    }
                });
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog(@"Error: %@", error);
            } refresh:NO];
        });
    }];
    _timerBtn = timerBtn;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:_timerBtn];
    
    //界面其他
    HXTextField *textCode = [[HXTextField alloc]init];
    _textCode = textCode;
    _textCode.backgroundColor = [UIColor whiteColor];
    UIView *lv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 13, 20)];
    [_textCode appearanceWithTextColor:[Utils colorWithHexString:@"#333333"] textFontSize:14.0 placeHolderColor:[Utils colorWithHexString:@"#d9d9d9"] placeHolderFontSize:14.0 placeHolderText:@"请输入短信验证码" leftView:lv];
    [self.view addSubview:_textCode];
    [_textCode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(weakself.view.mas_top).offset(40);
        make.height.mas_equalTo(40);
    }];
    _textCode.keyboardType = UIKeyboardTypeNumberPad;
    _textCode.delegate = self;
    
    UILabel *lab = [[UILabel alloc]init];
    lab.text = [NSString stringWithFormat:@"已发送验证码短信到%@",self.phoneNum];
    lab.textColor = [Utils colorWithHexString:@"#999999"];
    lab.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:lab];
    [lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.view.mas_centerX);
        make.centerY.equalTo(weakself.view.mas_top).offset(20);
    }];
    
    UILabel *prompt = [[UILabel alloc]init];
    _prompt = prompt;
    _prompt.text = @" ";
    _prompt.font = [UIFont systemFontOfSize:12];
    _prompt.textColor = [Utils colorWithHexString:@"#ff0000"];
    [self.view addSubview:_prompt];
    [_prompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScreenWidth-26);
        make.centerX.equalTo(weakself.view.mas_centerX);
        make.top.equalTo(_textCode.mas_bottom).offset(5);
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
        make.left.equalTo(weakself.view.mas_left).offset(13);
        make.right.equalTo(weakself.view.mas_right).offset(-13);
        make.height.mas_equalTo(40);
    }];
}

- (void)dealloc{
    NSLog(@"ResetTextCodeViewController销毁了");
    
    //必须要在vc的dealloc方法中调用btn 的timer销毁方法和runloop的退出方法，保证vc pop的时候btn可以马上销毁
    CFRunLoopStop(self.timerBtn.runloop);
    [self.timerBtn.timer invalidate];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.textCode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
