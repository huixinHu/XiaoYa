//
//  RegiNameViewController.m
//  XiaoYa
//
//  Created by commet on 2017/6/8.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "RegiNameViewController.h"
#import "AppDelegate.h"
#import "HXTextField.h"
#import "Utils.h"
#import "Masonry.h"
#import "HXNetworking.h"
#import "HXNotifyConfig.h"
#import "HXSocketBusinessManager.h"
#import "MBProgressHUD.h"
#import "LoginProgress.h"
#import "HXDBManager.h"
#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width

@interface RegiNameViewController ()<UITextFieldDelegate>
@property (nonatomic ,weak)HXTextField *name;
@property (nonatomic ,weak)UILabel *prompt;
@property (nonatomic ,weak)UIButton *nextStep;
@property (nonatomic ,copy)NSString *pwd;
@property (nonatomic ,copy)NSString *phoneNum;

@property (nonatomic ,strong) LoginProgress *loginPregress;
@property (nonatomic ,copy) HXSocketLoginCallback loginCallback;
@property (nonatomic ,strong) HXDBManager *hxdb;
@end

@implementation RegiNameViewController
- (instancetype)initWithPwd:(NSString *)pwd phoneNum:(NSString *)phoneNum{
    if (self = [super init]) {
        self.pwd = pwd;
        self.phoneNum = phoneNum;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self viewsSetting];
    [self initForSocketLogin];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(textFieldValueChanged) name:UITextFieldTextDidChangeNotification object:self.name];
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    [self.view addGestureRecognizer:singleTap];
}

//返回
- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

//注册完成
- (void)next{
    [self.view endEditing:YES];
    for (int i = 0; i < self.name.text.length; i++) {
        int a  = [self.name.text characterAtIndex:i];
        if (a < 0x4e00 || a > 0x9fff) {
            self.prompt.text = @"只允许中文输入";
            return;
        }
    }
    if (self.name.text.length > 4) {
        self.prompt.text = @"不超过4个字";
        return;
    }
    
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"REGISTER",@"type",self.name.text,@"name", self.pwd,@"password",nil];
    __weak typeof (self)weakself = self;
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    [HXNetworking postWithUrl:httpUrl params:paraDict cache:NO success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *responseDict = (NSDictionary *)responseObject;
        NSLog(@"dataMessage:%@",[responseDict objectForKey:@"message"]);
        if ([[responseDict objectForKey:@"state"]boolValue] == 0){
            weakself.prompt.text = @"注册失败";
            return;
        }
        dispatch_group_leave(group);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
    } refresh:NO];
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        [self login];
    });

}

//注册成功自动登录
- (void)login{
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"LOGIN",@"type",self.phoneNum,@"mobile",self.pwd,@"password", nil];
    __weak typeof (self)ws = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __strong typeof(ws) ss = ws;
        [HXNetworking postWithUrl:httpUrl params:paraDict cache:NO success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *resultDic = (NSDictionary *)responseObject;
            NSLog(@"登录dataID:%@",[resultDic objectForKey:@"identity"]);
            if ([[resultDic objectForKey:@"state"]boolValue] == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _prompt.text = @"登录失败";
                });
            }else {
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                NSString *result = [resultDic objectForKey:@"identity"];
                appDelegate.userName = [[result componentsSeparatedByString:@"("] firstObject];
                appDelegate.userid = [[[[result componentsSeparatedByString:@"("] lastObject] componentsSeparatedByString:@")"]firstObject];
                appDelegate.phone = ss.phoneNum;
                //http登录成功了就打开数据库
                self.hxdb = [HXDBManager shareDB:@"XiaoYa.sqlite" dbPath:[Utils HXNSStringMD5:appDelegate.userid]];
                [self.hxdb changeFilePath:[Utils HXNSStringMD5:appDelegate.userid] dbName:@"XiaoYa.sqlite"];
                [self.hxdb createTable:groupTable colDict:@{@"groupId":@"TEXT",@"groupName":@"TEXT",@"groupAvatarId":@"TEXT",@"numberOfMember":@"TEXT",@"groupManagerId":@"TEXT",@"deleteFlag":@"INTEGER"} primaryKey:@"groupId"];
                [self.hxdb createTable:memberTable colDict:@{@"memberId":@"TEXT",@"memberName":@"TEXT",@"memberphone":@"TEXT"} primaryKey:@"memberId"];
                
                [self.hxdb tableCreate:@"CREATE TABLE IF NOT EXISTS memberGroupRelation (memberId TEXT,groupId TEXT, FOREIGN KEY(groupId) REFERENCES groupTable(groupId) ON DELETE CASCADE);" table:@"memberGroupRelation"];
                [self.hxdb tableCreate:@"CREATE TABLE IF NOT EXISTS groupInfoTable(publishTime TEXT,publisher TEXT,eventDate TEXT,eventSection TEXT,event TEXT,deadlineIndex TEXT,groupId TEXT, comment TEXT,FOREIGN KEY(groupId) REFERENCES groupTable(groupId) ON DELETE CASCADE);" table:@"groupInfoTable"];
                
                NSDictionary *tokenDict = @{@"from":result};
                [ss.loginPregress showProgress:YES onView:ss.view];
                [[HXSocketBusinessManager shareInstance]connectSocket:tokenDict authAppraisalFailCallBack:self.loginCallback];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"Error: %@", error);
        } refresh:NO];
    });
}

- (void)initForSocketLogin{
    __weak typeof(self) ws = self;
    self.loginPregress = [[LoginProgress alloc]init];
    //设置超时block
    self.loginPregress.loginTimeoutBlock = ^{
        NSLog(@"登录超时");
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws.loginPregress showProgress:NO onView:ws.view];
            MBProgressHUD *timeOutHud = [MBProgressHUD showHUDAddedTo:ws.view animated:YES];
            timeOutHud.mode = MBProgressHUDModeText;
            timeOutHud.label.text = @"登录超时";
            [timeOutHud hideAnimated:YES afterDelay:1.5];
        });
    };
    //登录回调Block
    self.loginCallback = ^(NSError *error) {
        if ([ws.loginPregress timerIsActive]){
            [ws.loginPregress showProgress:NO onView:ws.view];
            if (error) {//登录出错
                dispatch_async(dispatch_get_main_queue(), ^{
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:ws.view animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.label.text = @"登录失败";
                    [hud hideAnimated:YES afterDelay:1.5];
                });
            } else{//登录成功
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIViewController *temp = ws.presentingViewController;//先取得presentingViewController。不先保存的话，popvc之后可能就为空了
                    [ws.navigationController popToRootViewControllerAnimated:YES];
                    [temp dismissViewControllerAnimated:YES completion:^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:HXPushViewControllerNotification object:nil];
                    }];
                });
            }
        } else{
            ws.loginPregress.loginTimeoutBlock();
        }
    };
}

#pragma mark textfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldValueChanged{
    self.prompt.text = @" ";
    if (self.name.text.length > 0) {
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
    self.navigationItem.title = @"注册";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"导航栏返回图标"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    
    //界面其他
    HXTextField *name = [[HXTextField alloc]init];
    _name = name;
    _name.backgroundColor = [UIColor whiteColor];
    UIView *lv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 13, 20)];
    [_name appearanceWithTextColor:[Utils colorWithHexString:@"#333333"] textFontSize:14.0 placeHolderColor:[Utils colorWithHexString:@"#d9d9d9"] placeHolderFontSize:14.0 placeHolderText:@"请输入您的姓名" leftView:lv];
    [self.view addSubview:_name];
    [_name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenWidth, 40));
        make.top.equalTo(self.view).offset(40);
        make.centerX.equalTo(self.view);
    }];
    _name.delegate = self;
    
    UILabel *lab = [[UILabel alloc]init];
    lab.text = @"输入您的真实姓名，让协作更加高效";
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
        make.top.equalTo(_name.mas_bottom).offset(5);
    }];
    
    UIButton *nextStep = [[UIButton alloc]init];
    _nextStep = nextStep;
    [_nextStep setTitle:@"完成" forState:UIControlStateNormal];
    [_nextStep addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    _nextStep.titleLabel.font = [UIFont systemFontOfSize:15];
    _nextStep.backgroundColor = [Utils colorWithHexString:@"78cbf8"];
    _nextStep.layer.cornerRadius = 5.0;
    _nextStep.enabled = NO;
    [_nextStep addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    _nextStep.enabled = NO;
    [self.view addSubview:_nextStep];
    [_nextStep mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_prompt.mas_bottom).offset(5);
        make.size.mas_equalTo(CGSizeMake(kScreenWidth - 26, 40));
        make.centerX.equalTo(self.view);
    }];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.name];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
