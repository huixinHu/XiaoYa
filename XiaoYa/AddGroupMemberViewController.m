//
//  AddGroupMemberViewController.m
//  XiaoYa
//
//  Created by commet on 2017/7/12.
//  Copyright © 2017年 commet. All rights reserved.
//添加成员

#import "AddGroupMemberViewController.h"
#import "MemberSearchTableViewCell.h"
#import "Utils.h"
#import "Masonry.h"
#import "HXTextField.h"
#import "HXNetworking.h"
#import "GroupMemberModel.h"

@interface AddGroupMemberViewController ()<UITextFieldDelegate ,UITableViewDelegate ,UITableViewDataSource>
@property (nonatomic ,weak) HXTextField *searchTxf;
@property (nonatomic ,weak) UITableView *memberList;
@property (nonatomic ,weak) UILabel *prompt;
@property (nonatomic ,weak) UILabel *noResult;
@property (nonatomic ,weak) UIButton *searchBtn;

@property (nonatomic ,strong) NSMutableArray <GroupMemberModel *> *memberModels;
@property (nonatomic ,strong) NSMutableArray <NSNumber *> *selectIndexs;
@property (nonatomic ,strong) NSMutableArray *addedMembers;
@end

@implementation AddGroupMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self viewsSetting];
}

//传入已经添加过的成员模型数组
- (instancetype)initWithAddedMembers:(NSMutableArray *)addedMembers{
    if (self = [super init]) {
        self.addedMembers = [addedMembers mutableCopy];
    }
    return self;
}

- (void)cancel{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)done{
    [self.view endEditing:YES];
    NSMutableArray <GroupMemberModel *>*selectedModel = [NSMutableArray array];
    for (NSNumber *num in self.selectIndexs) {
        [selectedModel addObject:self.memberModels[num.intValue]];
    }
    [self.delegate AddGroupMemberViewController:self addMembersFinish:selectedModel];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchMember{
    [self.view endEditing:YES];
    __weak typeof(self) weakself = self;
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"GETUSER",@"type",self.searchTxf.text,@"mobile", nil];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [HXNetworking postWithUrl:httpUrl params:paraDict cache:NO success:^(NSURLSessionDataTask *task, id responseObject) {
            NSLog(@"dataID:%@",[responseObject objectForKey:@"identity"]);
            [weakself.memberModels removeAllObjects];
            [weakself.selectIndexs removeAllObjects];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[responseObject objectForKey:@"state"]boolValue] == 0){
                    weakself.noResult.hidden = NO;
                    self.prompt.hidden = YES;
                }else {
                    GroupMemberModel *model = [GroupMemberModel memberModelWithMemberSearchDict:responseObject];
                    [weakself.memberModels addObject:model];
                    weakself.noResult.hidden = YES;
                    self.prompt.hidden = NO;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.memberList reloadData];
                });
            });
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"Error: %@", error);
        } refresh:NO];
    });
}

#pragma mark tableview datasource &delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.memberModels.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 43;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) ws = self;
    MemberSearchTableViewCell *cell = [MemberSearchTableViewCell MemberSearchCellWithTableView:tableView selectBlock:^(NSIndexPath *indexPath) {
        [ws.view endEditing:YES];
        [ws.selectIndexs addObject:[NSNumber numberWithInteger:indexPath.row]];
        ws.navigationItem.rightBarButtonItem.enabled = YES;
    } deselectBlock:^(NSIndexPath *indexPath) {
        [ws.view endEditing:YES];
        [ws.selectIndexs removeObject:[NSNumber numberWithInteger:indexPath.row]];
        if (ws.selectIndexs.count == 0) {
            ws.navigationItem.rightBarButtonItem.enabled = NO;
        }
    } addedMembers:self.addedMembers];
    cell.member = self.memberModels[indexPath.row];;
    if ([self.selectIndexs containsObject:[NSNumber numberWithInteger:indexPath.row]]) {
        [cell.selectBtn setSelected:YES];
    }else{
        [cell.selectBtn setSelected:NO];
    }
    return cell;
}

#pragma mark viewsSetting
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
    [done setTitleColor:[Utils colorWithHexString:@"78cbf8"] forState:UIControlStateDisabled];
    done.titleLabel.font = [UIFont systemFontOfSize:15];
    [done addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:done];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.view.backgroundColor = [Utils colorWithHexString:@"#F0F0F6"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    [self.view addGestureRecognizer:singleTap];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(textFieldValueChanged) name:UITextFieldTextDidChangeNotification object:self.searchTxf];
    
    [self searchPartsSetting];
    [self searchListSetting];
}

- (void)searchPartsSetting{
    UIView *bg = [[UIView alloc]init];
    bg.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bg];
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.top.centerX.equalTo(self.view);
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
    _searchTxf.keyboardType = UIKeyboardTypeNumberPad;
    [_searchTxf appearanceWithTextColor:[Utils colorWithHexString:@"#333333"] textFontSize:15 placeHolderColor:[Utils colorWithHexString:@"#999999"] placeHolderFontSize:15 placeHolderText:@"搜索手机号码" leftView:nil];
    [bg addSubview:_searchTxf];
    [_searchTxf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.height.equalTo(bg);
        make.left.equalTo(searchImg.mas_right).offset(15);
        make.right.equalTo(bg).offset(-60);
    }];
    _searchTxf.delegate = self;
    
    UIButton *searchBtn = [[UIButton alloc]init];
    _searchBtn = searchBtn;
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [searchBtn setTitleColor:[Utils colorWithHexString:@"78cbf8"] forState:UIControlStateDisabled];
    [searchBtn setTitleColor:[Utils colorWithHexString:@"00a7fa"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchMember) forControlEvents:UIControlEventTouchUpInside];
    [bg addSubview:searchBtn];
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 40));
        make.centerY.equalTo(bg);
        make.left.equalTo(_searchTxf.mas_right);
    }];
    _searchBtn.enabled = NO;
    
    UILabel *prompt = [[UILabel alloc]init];
    _prompt = prompt;
    _prompt.text = @"搜索到以下结果:";
    _prompt.textColor = [Utils colorWithHexString:@"#999999"];
    _prompt.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:_prompt];
    [_prompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchImg);
        make.top.equalTo(_searchTxf.mas_bottom).offset(7.8);
    }];
    _prompt.hidden = YES;
}

- (void)searchListSetting{
    //设置搜索结果视图-tableview
    UITableView *memberList = [[UITableView alloc]init];
    _memberList = memberList;
    _memberList.delegate = self;
    _memberList.dataSource = self;
    _memberList.bounces = NO;
    _memberList.backgroundColor = [Utils colorWithHexString:@"#F0F0F6"];
    [self.view addSubview:_memberList];
    [_memberList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.centerX.bottom.equalTo(self.view);
        make.top.equalTo(_searchTxf.mas_bottom).offset(30);
    }];
    [_memberList setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    _memberList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UILabel *noResult = [[UILabel alloc]init];
    _noResult = noResult;
    _noResult.text = @"没有搜索到合适结果";
    _noResult.font = [UIFont systemFontOfSize:20];
    _noResult.textColor = [Utils colorWithHexString:@"#999999"];
    [self.view addSubview:_noResult];
    [_noResult mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    _noResult.hidden = YES;
}

-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer{
    [self.view endEditing:YES];
}

#pragma mark textfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldValueChanged{
    self.noResult.hidden = YES;
    if (self.searchTxf.text.length > 0) {
        self.searchBtn.enabled = YES;
    }else{
        self.searchBtn.enabled = NO;
    }
}

#pragma mark lazyload
- (NSMutableArray *)memberModels{
    if (_memberModels == nil) {
        _memberModels = [NSMutableArray array];
    }
    return _memberModels;
}

- (NSMutableArray *)selectIndexs{
    if (_selectIndexs == nil) {
        _selectIndexs = [NSMutableArray array];
    }
    return _selectIndexs;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.searchTxf];
}
@end
