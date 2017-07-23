//
//  JoinGroupViewController.m
//  XiaoYa
//
//  Created by commet on 2017/7/13.
//  Copyright © 2017年 commet. All rights reserved.
//加入群组页

#import "JoinGroupViewController.h"
#import "GroupSearchTableViewCell.h"
#import "Utils.h"
#import "Masonry.h"
#import "HXTextField.h"

@interface JoinGroupViewController ()<UITextFieldDelegate ,UITableViewDelegate ,UITableViewDataSource>
@property (nonatomic ,weak) HXTextField *searchTxf;
@property (nonatomic ,weak) UIButton *searchBtn;
@property (nonatomic ,weak) UITableView *groupTable;
@property (nonatomic ,weak) UILabel *prompt;
@property (nonatomic ,strong)NSMutableArray *groupModels;

@end

@implementation JoinGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self viewsSetting];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(textFieldValueChanged) name:UITextFieldTextDidChangeNotification object:self.searchTxf];
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    [self.view addGestureRecognizer:singleTap];
    singleTap.cancelsTouchesInView = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)search{
    self.prompt.hidden = NO;
}

#pragma mark tableview datasource &delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.groupModels.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 68;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GroupSearchTableViewCell *cell = [GroupSearchTableViewCell GroupSearchCellWithTableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


#pragma mark viewsSetting
- (void)viewsSetting{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBg"] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[Utils colorWithHexString:@"#333333"],NSFontAttributeName:[UIFont systemFontOfSize:17]};
    self.navigationItem.title = @"查找群组";
    
    UIButton *back = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [back setTitle:@"取消" forState:UIControlStateNormal];
    [back setTitleColor:[Utils colorWithHexString:@"#00a7fa"] forState:UIControlStateNormal];
    back.titleLabel.font = [UIFont systemFontOfSize:15];
    [back addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:back];
    self.view.backgroundColor = [Utils colorWithHexString:@"#F0F0F6"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //设置搜索框
    __weak typeof(self)weakself = self;
    HXTextField *searchTxf = [[HXTextField alloc]init];
    _searchTxf = searchTxf;
    _searchTxf.backgroundColor = [UIColor whiteColor];
    _searchTxf.textAlignment = NSTextAlignmentCenter;
    _searchTxf.layer.borderColor = [[Utils colorWithHexString:@"#d9d9d9"]CGColor];
    _searchTxf.layer.borderWidth = 0.5f;
    _searchTxf.layer.cornerRadius = 2.0f;
    [_searchTxf appearanceWithTextColor:[Utils colorWithHexString:@"#999999"] textFontSize:14 placeHolderColor:[Utils colorWithHexString:@"#cccccc"] placeHolderFontSize:14 placeHolderText:@"请输入群组ID"  leftView:nil];
    UIButton *searchBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 45, 30)];
    _searchBtn = searchBtn;
    [_searchBtn addTarget:self action:@selector(search) forControlEvents:UIControlEventTouchUpInside];
    [_searchBtn setImage:[UIImage imageNamed:@"搜索按钮不可点击"] forState:UIControlStateDisabled];
    [_searchBtn setImage:[UIImage imageNamed:@"搜索按钮可点击"] forState:UIControlStateNormal];
    _searchTxf.rightView = searchBtn;
    _searchTxf.rightViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:_searchTxf];
    [_searchTxf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.top.equalTo(weakself.view).offset(10);
        make.left.equalTo(weakself.view).offset(13);
        make.right.equalTo(weakself.view).offset(-13);
    }];
    _searchTxf.delegate = self;
    _searchBtn.enabled = NO;
    
    //设置搜索结果视图-tableview
    UITableView *groupTable = [[UITableView alloc]init];
    _groupTable = groupTable;
    _groupTable.delegate = self;
    _groupTable.dataSource = self;
    _groupTable.bounces = NO;
    _groupTable.backgroundColor = [Utils colorWithHexString:@"#F0F0F6"];
    [self.view addSubview:_groupTable];
    [_groupTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.centerX.bottom.equalTo(weakself.view);
        make.top.equalTo(_searchTxf.mas_bottom).offset(30);
    }];
    [_groupTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    UILabel *prompt = [[UILabel alloc]init];
    _prompt = prompt;
    _prompt.text = @"搜索到以下群:";
    _prompt.textColor = [Utils colorWithHexString:@"#999999"];
    _prompt.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:_prompt];
    [_prompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_searchTxf);
        make.top.equalTo(_searchTxf.mas_bottom).offset(7.8);
    }];
    _prompt.hidden = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldValueChanged{
    if (self.searchTxf.text.length > 0) {
        self.searchBtn.enabled = YES;
    }else{
        self.searchBtn.enabled = NO;
    }
}

- (void)cancel{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer{
    [self.view endEditing:YES];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.searchTxf];
}

#pragma mark lazyload
- (NSMutableArray *)groupModels{
    if (_groupModels == nil) {
        _groupModels = [NSMutableArray array];
    }
    return _groupModels;
}
@end
