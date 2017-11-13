//
//  JoinGroupViewController.m
//  XiaoYa
//
//  Created by commet on 2017/7/13.
//  Copyright © 2017年 commet. All rights reserved.
//加入群组页

#import "JoinGroupViewController.h"
#import "GroupInfoViewController.h"
#import "GroupSearchTableViewCell.h"
#import "Utils.h"
#import "Masonry.h"
#import "HXTextField.h"
#import "HXNetworking.h"
#import "GroupSearchModel.h"
#import "GroupInfoModel.h"
#import "GroupListModel.h"
#import "UIAlertController+Appearance.h"
#import "AppDelegate.h"
#import "HXDBManager.h"

@interface JoinGroupViewController ()<UITextFieldDelegate ,UITableViewDelegate ,UITableViewDataSource ,GroupSearchCellDelegate>
@property (nonatomic ,weak) HXTextField *searchTxf;
@property (nonatomic ,weak) UIButton *searchBtn;
@property (nonatomic ,weak) UITableView *groupTable;
@property (nonatomic ,weak) UILabel *prompt;
@property (nonatomic ,weak) UILabel *noResult;

@property (nonatomic ,strong) NSMutableArray <GroupSearchModel *> *groupModels;
@property (nonatomic ,copy) gJoinSuccessBlock sucBlock;
@property (nonatomic ,strong) HXDBManager *hxdb;
@end

@implementation JoinGroupViewController
- (instancetype)initWithJoinSuccessBlock:(gJoinSuccessBlock)block{
    if (self = [super init]) {
        self.sucBlock = block;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self viewsSetting];
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(textFieldValueChanged) name:UITextFieldTextDidChangeNotification object:self.searchTxf];
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    [self.view addGestureRecognizer:singleTap];
    singleTap.cancelsTouchesInView = NO;
}

- (void)cancel{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)search{    
    __weak typeof(self) weakself = self;
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"GETGROUP",@"type", self.searchTxf.text ,@"groupId", nil];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [HXNetworking postWithUrl:httpUrl params:paraDict cache:NO success:^(NSURLSessionDataTask *task, id responseObject) {
            [weakself.groupModels removeAllObjects];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[responseObject objectForKey:@"state"]boolValue] == 0){
                    weakself.noResult.hidden = NO;
                    weakself.prompt.hidden = YES;
                }else {
                    GroupSearchModel *model = [GroupSearchModel groupModelWithDict:[responseObject objectForKey:@"group"]];
                    [weakself.groupModels addObject:model];
                    weakself.noResult.hidden = YES;
                    weakself.prompt.hidden = NO;
                }
                [weakself.groupTable reloadData];
            });
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"Error: %@", error);
        } refresh:NO];
    });
}

#pragma mark groupSearchDelegate
- (void)groupSearchCell:(GroupSearchTableViewCell *)cell selectIndex:(NSIndexPath *)indexPath{
    AppDelegate *apd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *userid = apd.userid;
    
    GroupSearchModel *selectedModel = self.groupModels[indexPath.row];
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"JOINGROUP",@"type",userid,@"userId", selectedModel.groupId, @"groupId",nil];
    
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __strong typeof(weakself) ss = weakself;
        [HXNetworking postWithUrl:httpUrl params:paraDict cache:NO success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([[responseObject objectForKey:@"state"]boolValue] == 0){
                dispatch_async(dispatch_get_main_queue(), ^{
                    //加入失败的交互待完善
                    void (^otherBlock)(UIAlertAction *action) = ^(UIAlertAction *action){
                    };
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"加入群组失败" message:[responseObject objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert cancelTitle:nil cancelBlock:nil otherTitles:@[@"确定"] otherBlocks:@[otherBlock]];
                    [ss presentViewController:alert animated:YES completion:nil];
                });
            }else {
                //更新数据库 - 群组表
                NSString *groupId = selectedModel.groupId;
                NSString *groupName = selectedModel.groupName;
                NSString *groupManagerId = selectedModel.managerId;
                NSString *groupAvatarId = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:selectedModel.avatarId]];
                NSString *numberOfMember = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:selectedModel.numberOfMember + 1]];//加1是因为要算上自己
                NSDictionary *groupParaDict = @{@"groupId":groupId ,@"groupName":groupName ,@"groupManagerId":groupManagerId ,@"groupAvatarId":groupAvatarId ,@"numberOfMember":numberOfMember ,@"deleteFlag":@0};
                [ss.hxdb insertTable:groupTable param:groupParaDict callback:^(NSError *error) {
                    if(error) NSLog(@"加入群组-插入群组表失败：%@",error);
                }];
                
                //更新消息表
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
//                [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//                NSDate *tempDate = [df dateFromString:[responseObject objectForKey:@"time"]];
                NSDate *tempDate = [NSDate date];
                [df setDateFormat:@"yyyyMMddHHmmss"];
                NSString *tempDateStr = [df stringFromDate:tempDate];
                int random = (arc4random() % 10000)+10000;//10000~19999随机数
                NSString *randomStr = [[NSString stringWithFormat:@"%d" ,random] substringFromIndex:1];
                NSDictionary *groupInfoDict = @{@"publishTime":[NSString stringWithFormat:@"%@%@",tempDateStr,randomStr] , @"event":@"你已加入群组", @"groupId":groupId};
                GroupInfoModel *infoModel = [GroupInfoModel groupInfoWithDict:groupInfoDict];
                [self.hxdb insertTable:groupInfoTable model:infoModel excludeProperty:nil callback:^(NSError *error) {
                    NSLog(@"%@",error);
                }];

                //更新缓存
                GroupListModel *groupModel = [GroupListModel groupWithDict:groupParaDict];
                groupModel.groupEvents = [NSMutableArray arrayWithObject:infoModel];
                if (ss.sucBlock) {
                    ss.sucBlock(groupModel);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    GroupInfoViewController *groupInfoVC = [[GroupInfoViewController alloc]initWithGroupModel:groupModel];
                    groupInfoVC.hidesBottomBarWhenPushed = YES;
                    [ss.navigationController pushViewController:groupInfoVC animated:YES];
                });
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"Error: %@", error);
        } refresh:NO];
    });
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
    cell.model = self.groupModels[indexPath.row];
    cell.delegate = self;
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
        make.top.equalTo(self.view).offset(10);
        make.left.equalTo(self.view).offset(13);
        make.right.equalTo(self.view).offset(-13);
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
        make.width.centerX.bottom.equalTo(self.view);
        make.top.equalTo(_searchTxf.mas_bottom).offset(30);
    }];
    [_groupTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    _groupTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
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

- (void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer{
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
- (NSMutableArray *)groupModels{
    if (_groupModels == nil) {
        _groupModels = [NSMutableArray array];
    }
    return _groupModels;
}

-(HXDBManager *)hxdb{
    if (_hxdb == nil) {
        _hxdb = [HXDBManager shareDB];
    }
    return _hxdb;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.searchTxf];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
