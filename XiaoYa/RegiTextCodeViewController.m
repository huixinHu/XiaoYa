//
//  RegiTextCodeViewController.m
//  XiaoYa
//
//  Created by commet on 2017/6/7.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "RegiTextCodeViewController.h"
#import "RegiPwdViewController.h"
#import "HXTextField.h"
#import "HXButton.h"
#import "Utils.h"
#import "Masonry.h"
#import "NSTimer+Addition.h"
#import "HXNetworking.h"
#import "HXNotifyConfig.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define kTimerCount 60
@interface RegiTextCodeViewController ()<UITextFieldDelegate>
@property (nonatomic ,weak)HXTextField *textCode;
@property (nonatomic ,weak)UIButton *nextStep;
@property (nonatomic ,weak)UILabel *prompt;
@property (nonatomic ,copy)NSString *phoneNum;
@property (nonatomic ,strong)NSThread *thread;
//@property (nonatomic ,weak)NSTimer *timer;
@property (nonatomic ,weak)HXButton *timerBtn;
@end

@implementation RegiTextCodeViewController
{
    int count;
}
- (instancetype)initWithPhoneNum:(NSString *)phoneNum{
    if (self = [super init]) {
        self.phoneNum = phoneNum;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    count = kTimerCount;

    [self viewsSetting];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(textFieldValueChanged) name:UITextFieldTextDidChangeNotification object:self.textCode];
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    [self.view addGestureRecognizer:singleTap];
    
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

//下一步
- (void)next{
    [self.view endEditing:YES];
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"MATCH",@"type",self.textCode.text,@"textCode", nil];
    __weak typeof (self)weakself = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [HXNetworking postWithUrl:httpUrl params:paraDict cache:NO success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *responseDict = (NSDictionary *)responseObject;
            NSLog(@"dataMessage:%@",[responseDict objectForKey:@"message"]);
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[responseDict objectForKey:@"state"]boolValue] == 0){
                    weakself.prompt.text = @"验证码错误";
                }else{
                    RegiPwdViewController *nextVC = [[RegiPwdViewController alloc]initWithPhoneNum:weakself.phoneNum];
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
    self.navigationItem.title = @"注册";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"导航栏返回图标"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    __weak typeof(self)weakself = self;//注意循环引用
    HXButton *timerBtn = [[HXButton alloc]initWithFrame:CGRectMake(0, 0, 80, 30) timerCount:60 timerInerval:1.0 networkRequest:^{
        NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"GETSME",@"type",weakself.phoneNum,@"mobile", nil];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [HXNetworking postWithUrl:httpUrl params:paraDict cache:NO success:^(NSURLSessionDataTask *task, id responseObject) {
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
        make.size.mas_equalTo(CGSizeMake(kScreenWidth, 40));
        make.top.equalTo(self.view).offset(40);
        make.centerX.equalTo(self.view);
    }];
    _textCode.keyboardType = UIKeyboardTypeNumberPad;
    _textCode.delegate = self;
    
    UILabel *lab = [[UILabel alloc]init];
    lab.text = [NSString stringWithFormat:@"已发送验证码短信到%@",self.phoneNum];
    lab.textColor = [Utils colorWithHexString:@"#999999"];
    lab.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:lab];
    [lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
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
        make.centerX.equalTo(self.view.mas_centerX);
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
        make.size.mas_equalTo(CGSizeMake(kScreenWidth - 26, 40));
        make.centerX.equalTo(self.view);
    }];
}

- (void)dealloc{
    NSLog(@"RegiTextCodeViewController销毁了");
    
    //必须要在vc的dealloc方法中调用btn 的timer销毁方法和runloop的退出方法，保证vc pop的时候btn可以马上销毁
    if ([self.timerBtn.timer isValid]) {
        [self.timerBtn.timer invalidate];
        CFRunLoopStop(self.timerBtn.runloop);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.textCode];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
