//
//  AddGroupMemberViewController.m
//  XiaoYa
//
//  Created by commet on 2017/7/12.
//  Copyright © 2017年 commet. All rights reserved.
//添加成员

#import "AddGroupMemberViewController.h"
#import "Utils.h"
#import "Masonry.h"
#import "HXTextField.h"
@interface AddGroupMemberViewController ()<UITextFieldDelegate>
@property (nonatomic ,weak) HXTextField *searchTxf;
@end

@implementation AddGroupMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self viewsSetting];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewsSetting{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBg"] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[Utils colorWithHexString:@"#333333"],NSFontAttributeName:[UIFont systemFontOfSize:17]};
    self.navigationItem.title = @"添加新成员";
    
    UIButton *back = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [back setTitle:@"取消" forState:UIControlStateNormal];
    [back setTitleColor:[Utils colorWithHexString:@"#00a7fa"] forState:UIControlStateNormal];
    back.titleLabel.font = [UIFont systemFontOfSize:15];
    [back addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:back];
    
    UIButton *done = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [done setTitle:@"完成" forState:UIControlStateNormal];
    [done setTitleColor:[Utils colorWithHexString:@"#00a7fa"] forState:UIControlStateNormal];
    done.titleLabel.font = [UIFont systemFontOfSize:15];
    [done addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:done];

    self.view.backgroundColor = [Utils colorWithHexString:@"#F0F0F6"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    [self.view addGestureRecognizer:singleTap];
    
    [self searchPartsSetting];
}

- (void)cancel{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)done{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer{
    [self.view endEditing:YES];
}

- (void)searchPartsSetting{
    __weak typeof(self) weakself = self;
    UIView *bg = [[UIView alloc]init];
    bg.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bg];
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.top.centerX.equalTo(weakself.view);
        make.height.mas_equalTo(60);
    }];
    UIImageView *searchImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"放大镜-灰"]];
    [bg addSubview:searchImg];
    [searchImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bg);
        make.left.equalTo(bg).offset(12);
        make.size.mas_equalTo(CGSizeMake(13, 13));
    }];
    
    HXTextField *searchTxf = [[HXTextField alloc]init];
    _searchTxf = searchTxf;
    [_searchTxf appearanceWithTextColor:[Utils colorWithHexString:@"#333333"] textFontSize:15 placeHolderColor:[Utils colorWithHexString:@"#999999"] placeHolderFontSize:15 placeHolderText:@"搜索姓名/手机号码" leftView:nil];
    [bg addSubview:_searchTxf];
    [_searchTxf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bg);
        make.left.equalTo(searchImg.mas_right).offset(15);
        make.right.equalTo(bg).offset(-50);
        make.height.mas_equalTo(40);
    }];
    _searchTxf.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
