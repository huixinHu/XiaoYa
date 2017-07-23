//
//  GroupCreateViewController.m
//  XiaoYa
//
//  Created by commet on 2017/7/11.
//  Copyright © 2017年 commet. All rights reserved.
//创建群组

#import "GroupCreateViewController.h"
#import "HXTextField.h"
#import "MemberCollectionViewCell.h"
#import "GroupMemberModel.h"
#import "AddGroupMemberViewController.h"
#import "Utils.h"
#import "Masonry.h"
#import "HXNetworking.h"

@interface GroupCreateViewController ()<UICollectionViewDataSource ,UICollectionViewDelegate ,UITextFieldDelegate>
@property (nonatomic ,weak)UIButton *avatar;
@property (nonatomic ,weak)HXTextField *groupName;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic ,strong) NSMutableArray *indexArray;
@end

static NSString *identifier = @"collectionCell";
@implementation GroupCreateViewController
{
    BOOL isDeleteBtnClicked;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self viewsSetting];
    isDeleteBtnClicked = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)createGroup{
    [self.view endEditing:YES];
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"CREATEGROUP",@"type",@"群组名",@"groupName",@9,@"managerId", nil];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [HXNetworking postWithUrl:@"http://139.199.170.95:8080/moyuzaiServer/Controller" params:paraDict success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *responseDic = (NSDictionary *)responseObject;
            NSLog(@"dataID:%@",[responseDic objectForKey:@"identity"]);
            NSLog(@"dataMessage:%@",[responseDic objectForKey:@"message"]);
            NSLog(@"dataState:%@",[responseDic objectForKey:@"state"]);

        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"Error: %@", error);
        } refresh:NO];
    });
}

#pragma mark collectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //点击了特殊键
    if (indexPath.item >= self.dataArray.count) {
        if (indexPath.item == self.dataArray.count) {
            if (isDeleteBtnClicked == YES){//上一次点击的是“-”，现在点击的是“删除”
                isDeleteBtnClicked = NO;
                //排序
                [self.indexArray sortUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2){
                    if ([obj1 integerValue] < [obj2 integerValue]){
                        return NSOrderedAscending;
                    }else{
                        return NSOrderedDescending;
                    }
                }];
                for (NSInteger i = self.indexArray.count; i > 0 ; i--) {
                    [self.dataArray removeObjectAtIndex:i];
                }
                [collectionView reloadData];
                [self.indexArray removeAllObjects];
            }
            else{//点击的是“+”
                AddGroupMemberViewController *vc = [[AddGroupMemberViewController alloc]init];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        else if (self.dataArray.count > 1 && indexPath.item == self.dataArray.count + 1){//成员数>=2，点击了最后一个cell
            if (isDeleteBtnClicked == NO) {//点击了"-"
                isDeleteBtnClicked = YES;
            }else{//上一次点击的是“-”，现在点击的是“取消”
                isDeleteBtnClicked = NO;
                [self.indexArray removeAllObjects];
            }
            [collectionView reloadData];
        }
        //把最后一个cell移到视线可见范围
        NSIndexPath *path = [NSIndexPath indexPathForItem:self.dataArray.count+1 inSection:0];
        [collectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
    //点击了成员
    else {
        if (indexPath.item != 0 && isDeleteBtnClicked == YES) {
            MemberCollectionViewCell *cell = (MemberCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
            if (cell.deleteSelect.isSelected) {
                cell.deleteSelect.selected = NO;
                [self.indexArray removeObject:[NSNumber numberWithInteger:indexPath.item]];
            }else{
                cell.deleteSelect.selected = YES;
                [self.indexArray addObject:[NSNumber numberWithInteger:indexPath.item]];
            }
        }
    }
}

#pragma mark collectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.dataArray.count == 1) {
        return self.dataArray.count + 1;
    }else if(self.dataArray.count > 1){
        return self.dataArray.count + 2;
    }else{
        return self.dataArray.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MemberCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    GroupMemberModel *memberModel = nil;
    if (indexPath.item >= self.dataArray.count) {//特殊键
        if (indexPath.item == self.dataArray.count) {
            if (isDeleteBtnClicked == YES) {
                memberModel = [[GroupMemberModel alloc]initWithDict:@{@"memberName":@"",@"memberAvatar":@"确定删除成员"}];
            }else{
                memberModel = [[GroupMemberModel alloc]initWithDict:@{@"memberName":@"",@"memberAvatar":@"成员添加键"}];
            }
        }else if (_dataArray.count > 1 && indexPath.item == _dataArray.count + 1){
            if (isDeleteBtnClicked == YES) {
                memberModel = [[GroupMemberModel alloc]initWithDict:@{@"memberName":@"",@"memberAvatar":@"取消删除成员"}];
            }else{
                memberModel = [[GroupMemberModel alloc]initWithDict:@{@"memberName":@"",@"memberAvatar":@"成员删除键"}];
            }
        }
        cell.deleteSelect.hidden = YES;
    }else{//成员键
        if (indexPath.item != 0 && isDeleteBtnClicked == YES) {
            cell.deleteSelect.hidden = NO;
            if ([self.indexArray containsObject:[NSNumber numberWithInteger:indexPath.item]]) {
                cell.deleteSelect.selected = YES;
            }else{
                cell.deleteSelect.selected = NO;
            }
        }else{//群主
            cell.deleteSelect.hidden = YES;
        }
        memberModel = self.dataArray[indexPath.item];
    }    
    cell.model = memberModel;
    return cell;
}

#pragma mark viewsSetting
- (void)viewsSetting{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBg"] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[Utils colorWithHexString:@"#333333"],NSFontAttributeName:[UIFont systemFontOfSize:17]};
    self.navigationItem.title = @"创建群组";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"导航栏返回图标"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.view.backgroundColor = [Utils colorWithHexString:@"#F0F0F6"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    singleTap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:singleTap];
    
    [self avatarAndNameSetting];
    [self teamerListSetting];
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer{
    [self.view endEditing:YES];
}

- (void)avatarAndNameSetting{
    __weak typeof(self)weakself = self;
    UIView *bg = [[UIView alloc]init];
    bg.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bg];
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(180);
        make.width.centerX.top.equalTo(weakself.view);
    }];
    
    UIButton *avatar = [[UIButton alloc]init];
    _avatar = avatar;
    [_avatar setBackgroundImage:[UIImage imageNamed:@"群头像添加"] forState:UIControlStateNormal];
    [_avatar addTarget:self action:@selector(addAvatar) forControlEvents:UIControlEventTouchUpInside];
    [bg addSubview:_avatar];
    [_avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 100));
        make.centerX.equalTo(bg);
        make.top.equalTo(bg).offset(19);
    }];
    UILabel *hint = [[UILabel alloc]init];
    hint.text = @"群头像";
    hint.font = [UIFont systemFontOfSize:12];
    hint.textColor = [Utils colorWithHexString:@"#cccccc"];
    [self.avatar addSubview:hint];
    [hint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bg);
        make.top.equalTo(_avatar.mas_centerY).offset(25);
    }];
    
    HXTextField *groupName = [[HXTextField alloc]init];
    _groupName = groupName;
    [_groupName appearanceWithTextColor:[Utils colorWithHexString:@"#333333"] textFontSize:15 placeHolderColor:[Utils colorWithHexString:@"#cccccc"] placeHolderFontSize:15 placeHolderText:@"设置群组名称" leftView:nil];
    _groupName.textAlignment = NSTextAlignmentCenter;
    [bg addSubview:_groupName];
    [_groupName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bg);
        make.size.mas_equalTo(CGSizeMake(250, 32));
        make.top.equalTo(_avatar.mas_bottom).offset(24);
    }];
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = [Utils colorWithHexString:@"#cccccc"];
    [bg addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(90, 1));
        make.top.equalTo(_groupName.mas_bottom);
        make.centerX.equalTo(bg.mas_centerX);
    }];
    _groupName.delegate = self;
}

- (void)teamerListSetting{
    __weak typeof(self)weakself = self;
    UIView *bg2 = [[UIView alloc]init];
    bg2.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bg2];
    [bg2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.centerX.equalTo(weakself.view);
        make.top.equalTo(weakself.view).offset(190);
        make.bottom.equalTo(weakself.view).offset(-40);
    }];
    
    UILabel *lab = [[UILabel alloc]init];
    lab.text = @"添加成员";
    lab.textColor = [Utils colorWithHexString:@"#999999"];
    lab.font = [UIFont systemFontOfSize:15];
    [bg2 addSubview:lab];
    [lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bg2).offset(12);
        make.left.equalTo(bg2).offset(12);
    }];
    
    UIButton *createGroup = [[UIButton alloc]init];
    createGroup.backgroundColor = [Utils colorWithHexString:@"#999999"];
    [createGroup setTitle:@"创建群组" forState:UIControlStateNormal];
    [createGroup setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    createGroup.titleLabel.font = [UIFont systemFontOfSize:17];
    [createGroup addTarget:self action:@selector(createGroup) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createGroup];
    [createGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.centerX.bottom.equalTo(weakself.view);
        make.height.mas_equalTo(40);
    }];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(50, 75);
    flowLayout.minimumInteritemSpacing = 25;
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.bounces = NO;
    [collectionView registerClass:[MemberCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    [bg2 addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(275);
        make.centerX.equalTo(bg2);
        make.top.equalTo(lab.mas_bottom).offset(20);
        make.bottom.equalTo(bg2).offset(-5);
    }];
    //把最后一个cell移到视线可见范围
    NSIndexPath *path = [NSIndexPath indexPathForItem:self.dataArray.count+1 inSection:0];
    [collectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

#pragma mark textfieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark lazyload
- (NSMutableArray *)dataArray {
    if (nil == _dataArray) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"member.plist" ofType:nil];
        NSArray *tempArray = [NSArray arrayWithContentsOfFile:path];
        NSMutableArray *mutable = [NSMutableArray array];
        for (NSDictionary *dict in tempArray) {
            GroupMemberModel *appModel = [GroupMemberModel memberModelWithDict:dict];
            [mutable addObject:appModel];
        }
        _dataArray = mutable;
    }
    return _dataArray;
}

- (NSMutableArray *)indexArray{
    if (nil == _indexArray) {
        _indexArray = [NSMutableArray array];
    }
    return _indexArray;
}
@end
