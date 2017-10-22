//
//  GroupCreateViewController.m
//  XiaoYa
//
//  Created by commet on 2017/7/11.
//  Copyright © 2017年 commet. All rights reserved.
//创建群组

#import "GroupCreateViewController.h"
#import "GroupInfoViewController.h"
#import "AddGroupMemberViewController.h"
#import "HXTextField.h"
#import "MemberCollectionViewCell.h"
#import "GroupMemberModel.h"
#import "GroupListModel.h"
#import "Utils.h"
#import "Masonry.h"
#import "HXNetworking.h"
#import "UIAlertController+Appearance.h"
#import "HXDBManager.h"
#import "FMDB.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define kScreenHeight [UIApplication sharedApplication].keyWindow.bounds.size.height

@interface GroupCreateViewController ()<UICollectionViewDataSource ,UICollectionViewDelegate ,UITextFieldDelegate ,UIGestureRecognizerDelegate ,AddGroupMemberViewControllerDelegate>
@property (nonatomic ,weak) UIButton *avatar;
@property (nonatomic ,weak) HXTextField *groupName;
@property (nonatomic ,weak) UIView *coverLayer;//半透明遮罩
@property (nonatomic ,weak) UIButton *lastSelectedAvatar;
@property (nonatomic ,weak) UIButton *createGroup;
@property (nonatomic ,weak) UILabel *hint;
@property (nonatomic ,weak) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray <GroupMemberModel *> *dataArray;//存储数据(模型) 第一个一定是群主
@property (nonatomic ,strong) NSMutableArray *indexArray;//存储index
@property (nonatomic ,strong) GroupListModel *groupModel;
@property (nonatomic ,copy) gCreateSucBlock sucBlock;
@property (nonatomic ,assign) NSInteger avatarID; //存储选择的群头像id
@property (nonatomic ,strong) HXDBManager *hxdb;
@end

static NSString *identifier = @"collectionCell";
@implementation GroupCreateViewController
{
    BOOL isDeleteBtnClicked;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.lastSelectedAvatar = nil;
    isDeleteBtnClicked = NO;
    self.avatarID = -1;
    [self viewsSetting];
}

- (instancetype)initWithGroupModel:(GroupListModel *)model successBlock:(gCreateSucBlock)block{
    if (self = [super init]) {
        self.groupModel = [model copy];
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:[self.groupModel.groupMembers copy]];
        self.sucBlock = block;
    }
    return self;
}

- (void)back{
    __weak typeof(self) weakself = self;
    if (self.avatarID >= 0 || self.groupName.text.length > 0 || self.dataArray.count > 1) {
        void (^otherBlock)(UIAlertAction *action) = ^(UIAlertAction *action){
            [weakself.navigationController popViewControllerAnimated:YES];
        };
        NSArray *otherBlocks = @[otherBlock];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认退出？" message:@"一旦退出，编辑将不会保存" preferredStyle:UIAlertControllerStyleAlert cancelTitle:@"取消" cancelBlock:nil otherTitles:@[@"确定"] otherBlocks:otherBlocks];
        [self presentViewController:alert animated:YES completion:nil];
    }else {
       [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)finish{
    [self.view endEditing:YES];
    
    GroupMemberModel *manager = self.dataArray.firstObject;
    NSMutableString *usersStr = [NSMutableString stringWithString:manager.memberId];
    GroupMemberModel *member = nil;
    for (int i = 1 ; i < self.dataArray.count ; i++) {
        member = self.dataArray[i];
        [usersStr appendString:[NSString stringWithFormat:@",%@",member.memberId]];
    }
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"INITGROUP", @"type", self.groupName.text,@"groupName", manager.memberId, @"managerId", [NSNumber numberWithInteger:self.avatarID-101], @"picId", usersStr, @"users",nil];
    __weak typeof(self) ws = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __strong typeof(ws) ss = ws;
        [HXNetworking postWithUrl:httpUrl params:paraDict cache:NO success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *responseDic = (NSDictionary *)responseObject;
            if ([[responseObject objectForKey:@"state"]boolValue] == 0){
                NSLog(@"群组创建失败");
                //此处应有提示
            } else{
                //存入数据库
                //1.群组表
                NSString *groupId = [[[[[responseDic objectForKey:@"identity"] componentsSeparatedByString:@"("] lastObject] componentsSeparatedByString:@")"] firstObject];
                NSString *groupName = [[[responseDic objectForKey:@"identity"] componentsSeparatedByString:@"("] firstObject];
                NSString *groupManagerId = manager.memberId;
                NSString *groupAvatarId = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:ss.avatarID-101]];
                NSString *numberOfMember = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:ss.dataArray.count]];
                NSMutableDictionary *groupParaDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:groupId, @"groupId", groupName, @"groupName", groupManagerId, @"groupManagerId", groupAvatarId, @"groupAvatarId", numberOfMember, @"numberOfMember",nil];

                [ss.hxdb insertTable:groupTable param:groupParaDict callback:^(NSError *error) {
                    if(error) NSLog(@"创建群组-插入群组表失败：%@",error);
                }];
                //2.关系表
                NSMutableArray *relatParaArr = [NSMutableArray array];
                [ss.dataArray enumerateObjectsUsingBlock:^(GroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSDictionary *relatDict = @{@"memberId":obj.memberId ,@"groupId":groupId};
                    [relatParaArr addObject:relatDict];
                }];
                [ss.hxdb insertTableInTransaction:memberGroupRelation paramArr:relatParaArr callback:^(NSError *error) {
                    if(error) NSLog(@"创建群组-插入关系表失败：%@",error);
                }];
                //3.成员表 要注意重复问题，不过memberTable中的memberId已经设了是唯一Id
                //利用唯一id避免重复，这里不能使用封装的HXDB的事务方法，封装的方法中，只要有一条出错就回溯并且停止后续插入
                [ss.hxdb.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                    [ss.dataArray enumerateObjectsUsingBlock:^(GroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        [db executeUpdate:@"INSERT INTO memberTable (memberId,memberPhone,memberName) VALUES(?,?,?)" withArgumentsInArray:@[obj.memberId ,obj.memberName ,obj.memberPhone]];
                    }];
                }];
                
                //更新缓存
                [groupParaDict setValue:[ss.dataArray mutableCopy] forKey:@"groupMembers"];
                GroupListModel *gmodel = [GroupListModel groupWithDict:groupParaDict];
                if(ss.sucBlock){
                    ss.sucBlock(gmodel);
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    GroupInfoViewController *groupInfoVC = [[GroupInfoViewController alloc]initWithGroupModel:gmodel];
                    groupInfoVC.hidesBottomBarWhenPushed = YES;
                    [ss.navigationController pushViewController:groupInfoVC animated:YES];//这里要放主线程
                });
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"Error: %@", error);
        } refresh:NO];
    });
}

#pragma mark AddGroupMemberViewControllerDelegate
- (void)AddGroupMemberViewController:(AddGroupMemberViewController*)viewController addMembersFinish:(NSMutableArray <GroupMemberModel *>*)modelArray{
    [self.dataArray addObjectsFromArray:[modelArray copy]];
    [self.collectionView reloadData];
    
    [self collectionScrollToTop:self.collectionView countOfDataArray:self.dataArray.count];
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
                    [self.dataArray removeObjectAtIndex:[self.indexArray[i-1] integerValue]];
                }
                [collectionView reloadData];
                [self.indexArray removeAllObjects];
            }
            else{//点击的是“+”
                AddGroupMemberViewController *vc = [[AddGroupMemberViewController alloc]initWithAddedMembers:self.dataArray];
                vc.delegate = self;
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
        [self collectionScrollToTop:collectionView countOfDataArray:self.dataArray.count];
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

//把最后一个cell移到视线可见范围
- (void)collectionScrollToTop:(UICollectionView *)collectionView countOfDataArray:(NSInteger)count{
    NSIndexPath *path = nil;
    if (count == 1) {
        path = [NSIndexPath indexPathForItem:count inSection:0];
    }else {
        path = [NSIndexPath indexPathForItem:count+1 inSection:0];
    }
    [collectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
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
                memberModel = [GroupMemberModel ordinaryModelWithDict:@{@"memberAvatar" :@"确定删除成员"}];
            }else{
                memberModel = [GroupMemberModel ordinaryModelWithDict:@{@"memberAvatar" :@"成员添加键"}];
            }
        }else if (_dataArray.count > 1 && indexPath.item == _dataArray.count + 1){
            if (isDeleteBtnClicked == YES) {
                memberModel = [GroupMemberModel ordinaryModelWithDict:@{@"memberAvatar" :@"取消删除成员"}];
            }else{
                memberModel = [GroupMemberModel ordinaryModelWithDict:@{@"memberAvatar" :@"成员删除键"}];
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

- (void)avatarAndNameSetting{
    UIView *bg = [[UIView alloc]init];
    bg.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bg];
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(180);
        make.width.centerX.top.equalTo(self.view);
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
    _hint = hint;
    hint.text = @"群头像";
    hint.font = [UIFont systemFontOfSize:12];
    hint.textColor = [Utils colorWithHexString:@"#cccccc"];
    [self.avatar addSubview:hint];
    [hint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bg);
        make.top.equalTo(_avatar.mas_centerY).offset(25);
    }];
    if (self.groupModel.groupAvatarId){
        [self avatarSetting:[self.groupModel.groupAvatarId integerValue]];
        self.avatarID = [self.groupModel.groupAvatarId integerValue] +101;
    }

    HXTextField *groupName = [[HXTextField alloc]init];
    _groupName = groupName;
    [_groupName appearanceWithTextColor:[Utils colorWithHexString:@"#333333"] textFontSize:15 placeHolderColor:[Utils colorWithHexString:@"#cccccc"] placeHolderFontSize:15 placeHolderText:@"设置群组名称" leftView:nil];
    _groupName.text = self.groupModel.groupName;
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
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(textFieldValueChanged) name:UITextFieldTextDidChangeNotification object:self.groupName];
}

- (void)addAvatar{
    [self.view endEditing:YES];
    
    self.coverLayer = [Utils coverLayerAddToWindow];
    //添加手势
    _coverLayer.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverFingerTapped:)];
    singleTap.delegate = self;
    [_coverLayer addGestureRecognizer:singleTap];
    [self coverViewsSetting];
}

- (void)teamerListSetting{
    UIView *bg2 = [[UIView alloc]init];
    bg2.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bg2];
    [bg2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.centerX.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(190);
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
    _createGroup = createGroup;
    createGroup.backgroundColor = [Utils colorWithHexString:@"#999999"];
    [createGroup setTitle:@"创建群组" forState:UIControlStateNormal];
    [createGroup setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    createGroup.titleLabel.font = [UIFont systemFontOfSize:17];
    [createGroup addTarget:self action:@selector(finish) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createGroup];
    [createGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.centerX.bottom.equalTo(self.view);
        make.height.mas_equalTo(40);
    }];
    _createGroup.enabled = NO;
    
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
        make.bottom.equalTo(createGroup).offset(-5);
    }];
    _collectionView = collectionView;
}

- (void)coverViewsSetting{
    UIView *bg = [[UIView alloc]init];
    bg.tag = 100;
    bg.backgroundColor = [UIColor whiteColor];
    [self.coverLayer addSubview:bg];
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kScreenWidth, 125));
        make.centerX.bottom.mas_equalTo(self.view);
    }];
    
    UIButton *avatar2 = [self groupAvatarBtnWithBgImage:[UIImage imageNamed:@"头像2"]];
    avatar2.tag = 102;
    [bg addSubview:avatar2];
    [avatar2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(bg);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    
    UIButton *avatar1 = [self groupAvatarBtnWithBgImage:[UIImage imageNamed:@"头像1"]];
    avatar1.tag = 101;
    [bg addSubview:avatar1];
    [avatar1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bg);
        make.size.mas_equalTo(CGSizeMake(100, 100));
        make.right.equalTo(avatar2.mas_left).offset(-20);
    }];
    
    UIButton *avatar3 = [self groupAvatarBtnWithBgImage:[UIImage imageNamed:@"头像3"]];
    avatar3.tag = 103;
    [bg addSubview:avatar3];
    [avatar3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bg);
        make.size.mas_equalTo(CGSizeMake(100, 100));
        make.left.equalTo(avatar2.mas_right).offset(20);
    }];
    
    if (self.avatarID < 0) {
        avatar1.selected = YES;
        self.lastSelectedAvatar = avatar1;
    } else {
        switch (self.avatarID) {
            case 101:{
                avatar1.selected = YES;
                self.lastSelectedAvatar = avatar1;
            }break;
            case 102:{
                avatar2.selected = YES;
                self.lastSelectedAvatar = avatar2;
            }break;
            case 103:{
                avatar3.selected = YES;
                self.lastSelectedAvatar = avatar3;
            }break;
            default:
                break;
        }
    }
}

- (UIButton *)groupAvatarBtnWithBgImage:(UIImage *)bgImage{
    UIButton *btn = [[UIButton alloc]init];
    [btn setBackgroundImage:bgImage forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"添加新成员选中"] forState:UIControlStateSelected];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    btn.contentVerticalAlignment =UIControlContentVerticalAlignmentTop;
    btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    [btn addTarget:self action:@selector(groupAvatarSelect:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

//设置群头像时收起蒙层
-(void)coverFingerTapped:(UITapGestureRecognizer *)gestureRecognizer{
    [self avatarSetting:self.lastSelectedAvatar.tag - 101];
    self.avatarID = self.lastSelectedAvatar.tag;
    [self bottomBtnCanBeSelectd];
    [_coverLayer removeFromSuperview];
}

- (void)avatarSetting:(NSInteger)avatar_Id{
    self.hint.hidden = YES;
    switch (avatar_Id) {
        case 0:
            [self.avatar setBackgroundImage:[UIImage imageNamed:@"头像1"] forState:UIControlStateNormal];
            break;
        case 1:
            [self.avatar setBackgroundImage:[UIImage imageNamed:@"头像2"] forState:UIControlStateNormal];
            break;
        case 2:
            [self.avatar setBackgroundImage:[UIImage imageNamed:@"头像3"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

//收起键盘
-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer{
    [self.view endEditing:YES];
}

//头像单选逻辑
- (void)groupAvatarSelect:(UIButton *)sender{
    if (self.lastSelectedAvatar != sender) {
        sender.selected = !sender.selected;
        self.lastSelectedAvatar.selected = NO;
        self.lastSelectedAvatar = sender;
    }
}

//底部的 创建 按钮是否可以被选
- (void)bottomBtnCanBeSelectd{
    if (self.groupName.text.length > 0 && self.avatarID >= 0) {
        self.createGroup.enabled = YES;
        self.createGroup.backgroundColor = [Utils colorWithHexString:@"#00a7fa"];
    }else{
        self.createGroup.enabled = NO;
        self.createGroup.backgroundColor = [Utils colorWithHexString:@"#999999"];
    }
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (touch.view.tag >= 100 && touch.view.tag <= 103) {
        return NO;
    }
    return YES;
}

#pragma mark textfieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldValueChanged{
    [self bottomBtnCanBeSelectd];
    if (self.groupName.text.length >= 20) {
        self.groupName.text = [self.groupName.text substringToIndex:20];
    }
}

#pragma mark lazyload
- (NSMutableArray *)dataArray {
    if (nil == _dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)indexArray{
    if (nil == _indexArray) {
        _indexArray = [NSMutableArray array];
    }
    return _indexArray;
}

- (HXDBManager *)hxdb{
    if (_hxdb == nil) {
        _hxdb = [HXDBManager shareInstance];
    }
    return _hxdb;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self.groupName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
