//
//  GroupDetailViewController.m
//  XiaoYa
//
//  Created by commet on 2017/8/1.
//  Copyright © 2017年 commet. All rights reserved.
//查看群资料

#import "GroupDetailViewController.h"
#import "MemberCollectionViewCell.h"
#import "MemberDetailViewController.h"
#import "MemberListViewController.h"
#import "EditGroupDetailViewController.h"
#import "GroupListModel.h"
#import "GroupMemberModel.h"
#import "GroupInfoModel.h"
#import "Utils.h"
#import "Masonry.h"
#import "BgView.h"
#import "AppDelegate.h"
#import "UIAlertController+Appearance.h"
#import "HXNetworking.h"
#import "HXNotifyConfig.h"
#import "FMDB.h"
#import "HXDBManager.h"
#import "MessageProtoBuf.pbobjc.h"

static NSString *identifier = @"groupDetailCollectionCell";

@interface GroupDetailViewController () <UICollectionViewDataSource ,UICollectionViewDelegate>
@property (nonatomic ,weak) UIImageView *avatarImage;
@property (nonatomic ,weak) UILabel *groupName;
@property (nonatomic ,weak) UICollectionView *collectionView;
@property (nonatomic ,weak) UIButton *editBtn;
@property (nonatomic ,weak) UIButton *moreBtn;

@property (nonatomic ,strong) GroupListModel *groupModel;
@property (nonatomic ,strong) HXDBManager *hxDB;
@property (nonatomic ,assign) BOOL isNetWorkFinish;//网络请求完毕，数据转为用户模型且更新本页缓存之后设为YES
@end

@implementation GroupDetailViewController
- (instancetype)initWithGroupInfo:(GroupListModel *)model{
    if (self = [super init]) {
        self.isNetWorkFinish = NO;
        self.groupModel = [model copy];
        
        __weak typeof(self) ws = self;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            __strong typeof(ws) ss = ws;
            //首先获取群组名、群组头像
            NSMutableDictionary *getGroup = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"GETGROUP",@"type", model.groupId ,@"groupId", nil];
            [HXNetworking postWithUrl:httpUrl params:getGroup cache:NO success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *responseDict = (NSDictionary *)responseObject;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([[responseDict objectForKey:@"state"] boolValue] != 0){
                        NSDictionary *groupDetail = [responseDict objectForKey:@"group"];
                        ss.groupModel.groupName = [groupDetail objectForKey:@"groupName"];
                        ss.groupModel.groupAvatarId = [NSString stringWithFormat:@"%@",[groupDetail objectForKey:@"picId"]];
                    }
                });
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog(@"Error: %@", error);
            } refresh:NO];
            
            
            NSMutableArray *relationMemberIdArr = [NSMutableArray array];//关系表中的用户id数组
            //无论有没有缓存都先取数据库，再取网络
//            if (model.groupMembers.count == 0 || !model.groupMembers){
            //从数据库去取
            //1.查找该群组所有的用户id 查找关系表
            NSArray *dbMemberIdDictArr = [ss.hxDB queryTable:memberGroupRelation columns:@{@"memberId":SQL_TEXT}whereDict:@{@"WHERE groupId = ?" : @[model.groupId]} callback:^(NSError *error) {
                NSLog(@"%@",error.userInfo[NSLocalizedDescriptionKey]);
            }];//NSArray <NSDictionary *>*
            //如果关系表有
            if (dbMemberIdDictArr.count > 0) {
                [dbMemberIdDictArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSDictionary *memberIdDict = (NSDictionary *)obj;
                    [relationMemberIdArr addObject:[memberIdDict objectForKey:@"memberId"]];
                }];
                [Utils sortArrayFromMinToMax:relationMemberIdArr];//对数组元素从小到大排序。因为网络请求返回的就是从小到大排序的
                //要把群主移到数组第一个，见后
                //2.根据用户id查找对应的用户信息。查找成员表
                NSMutableArray <GroupMemberModel*> *membersInfoArr = [NSMutableArray array];
                [ss.hxDB.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                    [relationMemberIdArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        FMResultSet *rs = [db executeQuery:@"SELECT * FROM memberTable WHERE memberId = ?" withArgumentsInArray:@[obj]];
                        if (![rs next]) {//没找到，放一个空模型占位
                            [membersInfoArr addObject:[GroupMemberModel ordinaryModelWithDict:@{@"memberAvatar":@"未登录头像"}]];
                        }
                        //找得到
                        else { //这里能确定的一点是，一条查找只会得到一条记录
                            int count = [rs columnCount];
                            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                            for (int i = 0 ; i < count ; i++) {
                                NSString *key = [rs columnNameForIndex:i];
                                NSString *value = [rs stringForColumnIndex:i];
                                [dic setValue:value forKey:key];
                            }
                            //转模型
                            GroupMemberModel *mModel = [GroupMemberModel ordinaryModelWithDict:dic];
                            if (mModel.memberId == ss.groupModel.groupManagerId) {
                                [membersInfoArr insertObject:mModel atIndex:0];//把群主移到第一个
                            } else{
                                [membersInfoArr addObject:mModel];
                            }
                        }
                        //查找出错
                        if (rs == nil) {
                            NSLog(@"%@",[db lastError]);
                            [rs close];
                            return;
                        }
                        [rs close];
                    }];
                    //3.更新缓存
                    ss.groupModel.groupMembers = [membersInfoArr mutableCopy];
                    ss.groupModel.numberOfMember = membersInfoArr.count;
                    //通知本页和首页、成员列表页、成员详情页
                    NSDictionary *dataDict = @{HXRefreshUserDetailKey:membersInfoArr ,@"groupId":ss.groupModel.groupId};
                    [[NSNotificationCenter defaultCenter] postNotificationName:HXRefreshUserDetailNotification object:nil userInfo:dataDict];
                }];
            }
//            }
        
            //4.网络访问更新缓存和数据库
            NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"GETUSERS",@"type",model.groupId,@"groupId",nil];
            [HXNetworking postWithUrl:httpUrl params:paraDict cache:NO success:^(NSURLSessionDataTask *task, id response) {
                __strong typeof(ws) ss = ws;
                NSDictionary *responseDict = (NSDictionary *)response;
                if ([[responseDict objectForKey:@"state"]boolValue] == 0) {
                    NSLog(@"获取群组用户信息失败");
                } else{
                    NSArray *users = [responseDict objectForKey:@"identity"];
                    NSMutableArray <GroupMemberModel *>*groupMembers = [NSMutableArray array];
                    NSMutableArray *deleteMemberWheres = [NSMutableArray array];//该群组成员已存在于成员表的成员id 的where条件数组.因为要删除旧数据在添加新数据，每次打开群资料都要这样做
                    NSMutableSet *networkMemberIdSet = [NSMutableSet set];//网络请求获得的所有成员id
                    [users enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSDictionary *userDict = (NSDictionary *)obj;
                        GroupMemberModel *mModel = [GroupMemberModel memberModelWithOneOfAllUserDict:userDict];
                        if (mModel.memberId == ss.groupModel.groupManagerId) {
                            [groupMembers insertObject:mModel atIndex:0];//把群主移到第一个
                        } else{
                            [groupMembers addObject:mModel];
                        }
                        [networkMemberIdSet addObject:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"id"]]];//获取成员id//要显式转成nsstring，[userDict objectForKey:@"id"]得到的是long
                        NSString *memberId = [NSString stringWithFormat:@"%@",[userDict objectForKey:@"id"]];
                        int count = [ss.hxDB itemCountForTable:memberTable whereDict:@{@"WHERE memberId = ?" : @[memberId]}];
                        if (count > 0) {
                            [deleteMemberWheres addObject:@{@"WHERE memberId = ?" : @[[NSString stringWithFormat:@"%@",[userDict objectForKey:@"id"]]]}];
                        }
                    }];
                    //更新缓存
                    ss.groupModel.groupMembers = [groupMembers mutableCopy];
                    ss.groupModel.numberOfMember = groupMembers.count;
                    ss.isNetWorkFinish = YES;
                    //通知本页和首页、成员列表页、成员详情页
                    NSDictionary *dataDict = @{HXRefreshUserDetailKey:groupMembers ,@"groupId":ss.groupModel.groupId};
                    [[NSNotificationCenter defaultCenter] postNotificationName:HXRefreshUserDetailNotification object:nil userInfo:dataDict];
                    //更新数据库
                    //1.更新关系表
                    NSMutableSet *relationMemberIdSet = [NSMutableSet setWithArray:relationMemberIdArr];//关系表memberId set
                    NSMutableSet *networkMemberIdSetB = [networkMemberIdSet mutableCopy];//备份
                    [networkMemberIdSet minusSet:relationMemberIdSet];//新增的
                    [relationMemberIdSet minusSet:networkMemberIdSetB];//删减的
                    if (networkMemberIdSet.count > 0) {
                        NSMutableArray *addRelation = [NSMutableArray array];
                        [networkMemberIdSet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
                            NSDictionary *addParaDict = @{@"memberId":obj ,@"groupId":ss.groupModel.groupId};
                            [addRelation addObject:addParaDict];
                        }];//增
                        [ss.hxDB insertTableInTransaction:memberGroupRelation paramArr:addRelation callback:^(NSError *error) {
                            NSLog(@"%@",error.userInfo[NSLocalizedDescriptionKey]);
                        }];
                    }
                    if (relationMemberIdSet.count > 0) {
                        NSMutableArray *deleteRelation = [NSMutableArray array];
                        [relationMemberIdSet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
                            [deleteRelation addObject:@{@"WHERE memberId = ? AND groupId = ?" : @[obj ,ss.groupModel.groupId]}];
                        }];//删
                        [ss.hxDB deleteTableInTransaction:memberGroupRelation whereArrs:deleteRelation callback:^(NSError *error) {
                            NSLog(@"%@",error.userInfo[NSLocalizedDescriptionKey]);
                        }];
                    }
                    //2.更新成员表,删除旧数据、插入新数据
                    if (deleteMemberWheres.count > 0) {
                        [ss.hxDB deleteTableInTransaction:memberTable whereArrs:deleteMemberWheres callback:^(NSError *error) {
                            NSLog(@"%@",error);
                        }];
                    }
                    NSMutableArray *memParaArr = [NSMutableArray array];
                    [groupMembers enumerateObjectsUsingBlock:^(GroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSDictionary *memDict = @{@"memberId":obj.memberId, @"memberName":obj.memberName, @"memberPhone":obj.memberPhone};
                        [memParaArr addObject:memDict];
                    }];
                    [ss.hxDB insertTableInTransaction:memberTable paramArr:memParaArr callback:^(NSError *error) {
                        NSLog(@"%@",error);
                    }];
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog(@"Error: %@", error);
            } refresh:NO];
        });        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserDetail:) name:HXRefreshUserDetailNotification object:nil];//刷新成员信息
    [self viewsSetting];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

//调用这个通知方法时，有可能控制器还没加载出来（没调viewDidLoad）
- (void)refreshUserDetail:(NSNotification *)notification{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.collectionView) {
            [self.collectionView reloadData];
        }
        if (self.isNetWorkFinish) {
            self.editBtn.enabled = YES;
        }
    });
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)edit{
    __weak typeof(self) ws = self;
    EditGroupDetailViewController *vc = [[EditGroupDetailViewController alloc] initWithGroupModel:self.groupModel successBlock:^(GroupListModel *model) {
        ws.groupModel = model;
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws settingImage:[model.groupAvatarId integerValue]];
            ws.groupName.text = model.groupName;
            [ws.collectionView reloadData];
            if (model.groupMembers.count > 4) {
                ws.moreBtn.hidden = NO;
            } else{
                ws.moreBtn.hidden = YES;
            }
        });
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)allMembers{
    MemberListViewController *memberListVC = [[MemberListViewController alloc] initWithAllMembersModel:self.groupModel.groupMembers totalMember:self.groupModel.numberOfMember];
    [self.navigationController pushViewController:memberListVC animated:YES];
}

- (void)exit{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *groupId = self.groupModel.groupId;
    NSString *userid = appDelegate.userid;
    __weak typeof(self) ws = self;
    if (appDelegate.userid.intValue == self.groupModel.groupManagerId.intValue) {//解散群
        void (^otherBlock)(UIAlertAction *action) = ^(UIAlertAction *action){
            __strong typeof(ws) ss = ws;
            NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"DISMISSGROUP",@"type",groupId,@"groupId",userid,@"managerId",nil];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [HXNetworking postWithUrl:httpUrl params:paraDict cache:NO success:^(NSURLSessionDataTask *task, id response) {
                    NSDictionary *responseDict = (NSDictionary *)response;
                    if ([[responseDict objectForKey:@"state"]boolValue] == 0){
                        NSLog(@"解散群组失败");
                    }else {
                        //更新数据库 //删除群组表、关系表、消息表
                        [self.hxDB deleteTable:groupTable whereDict:@{@"WHERE groupId = ?":@[groupId]} callback:^(NSError *error) {
                            NSLog(@"%@",error);
                        }];
                        [self.hxDB deleteTable:memberGroupRelation whereDict:@{@"WHERE groupId = ?":@[groupId]} callback:^(NSError *error) {
                            NSLog(@"%@",error);
                        }];
                        [self.hxDB deleteTable:groupInfoTable whereDict:@{@"WHERE groupId = ?":@[groupId]} callback:^(NSError *error) {
                            NSLog(@"%@",error);
                        }];
                        //仅更新群组表，deleteFlag置1
                        [ss.hxDB updateTable:groupTable param:@{@"deleteFlag":@1} whereDict:@{@"WHERE groupId = ?":@[groupId]} callback:^(NSError *error) {
                            NSLog(@"%@",error);
                        }];
                        //消息表
                        NSDateFormatter *df = [[NSDateFormatter alloc] init];
                        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        NSDate *tempDate = [df dateFromString:[responseDict objectForKey:@"time"]];
                        [df setDateFormat:@"yyyyMMddHHmmss"];
                        NSString *tempDateStr = [df stringFromDate:tempDate];
                        int random = (arc4random() % 10000)+10000;//10000~19999随机数
                        NSString *randomStr = [[NSString stringWithFormat:@"%d" ,random] substringFromIndex:1];
                        NSDictionary *groupInfoDict = @{@"publishTime":[NSString stringWithFormat:@"%@%@",tempDateStr,randomStr] , @"event":@"你已解散群组", @"groupId":groupId};
                        GroupInfoModel *infoModel = [GroupInfoModel groupInfoWithDict:groupInfoDict];
//                        [ss.hxDB insertTable:groupInfoTable model:infoModel excludeProperty:@[@"eventSection",@"deadlineIndex"] callback:^(NSError *error) {
//                            NSLog(@"%@",error);
//                        }];//好像不需要插入数据库了，反正下次打开app该群就没有了，要保证群消息干净

                        //更新缓存
                        NSDictionary *dataDict = @{HXNewGroupInfo:infoModel ,@"deleteFlag":@1};
                        [[NSNotificationCenter defaultCenter] postNotificationName:HXDismissExitGroupNotification object:nil userInfo:dataDict];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            for (UIViewController *tempVC in ss.navigationController.viewControllers) {
                                if ([tempVC isKindOfClass:NSClassFromString(@"GroupHomePageViewController")]) {
                                    [ss.navigationController popToViewController:tempVC animated:YES];
                                }
                            }
                        });
                    }
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    NSLog(@"Error: %@", error);
                } refresh:NO];
            });
        };
        NSArray *otherBlocks = @[otherBlock];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"解散群组" message:@"是否确定解散？" preferredStyle:UIAlertControllerStyleAlert cancelTitle:@"取消" cancelBlock:nil otherTitles:@[@"确定"] otherBlocks:otherBlocks];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    } else {//退出群
        void (^otherBlock)(UIAlertAction *action) = ^(UIAlertAction *action){
            __strong typeof(ws) ss = ws;
            NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"SIGNOUTGROUP",@"type",userid,@"userId",groupId,@"groupId",nil];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [HXNetworking postWithUrl:httpUrl params:paraDict cache:NO success:^(NSURLSessionDataTask *task, id response) {
                    NSDictionary *responseDict = (NSDictionary *)response;
                    if ([[responseDict objectForKey:@"state"]boolValue] == 0){
                        NSLog(@"退出群组失败");
                    }else {
                        //更新数据库 //删除群组表、关系表、消息表
                        [self.hxDB deleteTable:groupTable whereDict:@{@"WHERE groupId = ?":@[groupId]} callback:^(NSError *error) {
                            NSLog(@"%@",error);
                        }];
                        [ss.hxDB deleteTable:memberGroupRelation whereDict:@{@"WHERE groupId = ?":@[groupId]} callback:^(NSError *error) {
                            NSLog(@"%@",error);
                        }];//避免再次加入群时产生重复数据
                        [self.hxDB deleteTable:groupInfoTable whereDict:@{@"WHERE groupId = ?":@[groupId]} callback:^(NSError *error) {
                            NSLog(@"%@",error);
                        }];
                        [ss.hxDB updateTable:groupTable param:@{@"deleteFlag":@1} whereDict:@{@"WHERE groupId = ?":@[groupId]} callback:^(NSError *error) {
                            NSLog(@"%@",error);
                        }];
                        //消息表
                        NSDateFormatter *df = [[NSDateFormatter alloc] init];
                        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        NSDate *tempDate = [df dateFromString:[responseDict objectForKey:@"time"]];
                        [df setDateFormat:@"yyyyMMddHHmmss"];
                        NSString *tempDateStr = [df stringFromDate:tempDate];
                        int random = (arc4random() % 10000)+10000;//10000~19999随机数
                        NSString *randomStr = [[NSString stringWithFormat:@"%d" ,random] substringFromIndex:1];
                        NSDictionary *groupInfoDict = @{@"publishTime":[NSString stringWithFormat:@"%@%@",tempDateStr,randomStr] , @"event":@"你已退出群组", @"groupId":groupId};
                        GroupInfoModel *infoModel = [GroupInfoModel groupInfoWithDict:groupInfoDict];
//                        [ss.hxDB insertTable:groupInfoTable model:infoModel excludeProperty:@[@"eventSection",@"deadlineIndex"] callback:^(NSError *error) {
//                            NSLog(@"%@",error);
//                        }];
                        //更新缓存
                        NSDictionary *dataDict = @{HXNewGroupInfo:infoModel ,@"numberOfMember":@(ss.groupModel.numberOfMember - 1) ,@"deleteFlag":@1};
                        [[NSNotificationCenter defaultCenter] postNotificationName:HXDismissExitGroupNotification object:nil userInfo:dataDict];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            for (UIViewController *tempVC in ws.navigationController.viewControllers) {
                                if ([tempVC isKindOfClass:NSClassFromString(@"GroupHomePageViewController")]) {
                                    [ws.navigationController popToViewController:tempVC animated:YES];
                                }
                            }
                        });
                    }
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    NSLog(@"Error: %@", error);
                } refresh:NO];
            });
        };
        NSArray *otherBlocks = @[otherBlock];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"退出群组" message:@"是否确定退出？" preferredStyle:UIAlertControllerStyleAlert cancelTitle:@"取消" cancelBlock:nil otherTitles:@[@"确定"] otherBlocks:otherBlocks];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
}

#pragma mark collectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    MemberDetailViewController *vc = [[MemberDetailViewController alloc] initWithMemberModel:self.groupModel.groupMembers[indexPath.row] indexInGroup:indexPath.item];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark collectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.groupModel.numberOfMember >= 4) {//使用成员总人数字段而不是成员数组的元素数目，要给在数据库总没有的记录占位
        return 4;
    }else{
        return self.groupModel.numberOfMember;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MemberCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (self.groupModel.groupMembers.count >= indexPath.item + 1) {
        GroupMemberModel *memberModel = self.groupModel.groupMembers[indexPath.item];
        cell.model = memberModel;
    }
    return cell;
}

#pragma mark viewsSetting
- (void)viewsSetting{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBg"] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[Utils colorWithHexString:@"#333333"],NSFontAttributeName:[UIFont systemFontOfSize:17]};
    self.navigationItem.title = @"群资料";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"导航栏返回图标"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    
    UIButton *editBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [editBtn setTitleColor:[Utils colorWithHexString:@"#00a7fa"] forState:UIControlStateNormal];
    editBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    _editBtn = editBtn;//要判断是否群主
    [editBtn addTarget:self action:@selector(edit) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:editBtn];
    _editBtn.enabled = self.isNetWorkFinish ? YES : NO;//网络加载完毕才能编辑。
    
    self.view.backgroundColor = [Utils colorWithHexString:@"#F0F0F6"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.userInteractionEnabled = YES;

    [self avatarAndNameSetting];
    [self memberListSetting];
}

- (void)avatarAndNameSetting{
    BgView *bg = [[BgView alloc]init];
    bg.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bg];
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(180);
        make.width.centerX.top.equalTo(self.view);
    }];
    
    UIImageView *avatar = [[UIImageView alloc]init];
    _avatarImage = avatar;
    [self settingImage:[self.groupModel.groupAvatarId integerValue]];
    [bg addSubview:_avatarImage];
    [_avatarImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 100));
        make.centerX.equalTo(bg);
        make.top.equalTo(bg).offset(19);
    }];
    
    UILabel *groupName = [[UILabel alloc]init];
    _groupName = groupName;
    _groupName.text = self.groupModel.groupName;
    _groupName.textColor = [Utils colorWithHexString:@"#333333"];
    _groupName.font = [UIFont systemFontOfSize:15];
    [bg addSubview:_groupName];
    [_groupName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(bg);
        make.top.equalTo(_avatarImage.mas_bottom).offset(24);
    }];
}

- (void)memberListSetting{
    BgView *bg2 = [[BgView alloc]init];
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
        make.size.mas_equalTo(CGSizeMake(275, 75));
        make.centerX.equalTo(bg2);
        make.top.equalTo(lab.mas_bottom).offset(20);
    }];
    _collectionView = collectionView;
    
    UIButton *moreBtn = [[UIButton alloc] init];
    moreBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [moreBtn setTitle:@"查看全部成员" forState:UIControlStateNormal];
    [moreBtn setTitleColor:[Utils colorWithHexString:@"#00a7fa"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(allMembers) forControlEvents:UIControlEventTouchUpInside];
    [bg2 addSubview:moreBtn];
    [moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(collectionView);
        make.top.equalTo(collectionView.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(100, 30));
    }];
    if (self.groupModel.numberOfMember > 4) {
        moreBtn.hidden = NO;
    } else{
        moreBtn.hidden = YES;
    }
    _moreBtn = moreBtn;
    
    UIButton *exit = [[UIButton alloc]init];
    exit.titleLabel.font = [UIFont systemFontOfSize:15];
    exit.backgroundColor = [Utils colorWithHexString:@"#00a7fa"];
    exit.layer.cornerRadius = 5;
    [exit addTarget:self action:@selector(exit) forControlEvents:UIControlEventTouchUpInside];
    [bg2 addSubview:exit];
    [exit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(125, 40));
        make.top.equalTo(collectionView.mas_bottom).offset(50);
        make.centerX.equalTo(self.view);
    }];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.userid.intValue == self.groupModel.groupManagerId.intValue) {
        self.editBtn.hidden = NO;
        [exit setTitle:@"解散该群" forState:UIControlStateNormal];
    } else{
        self.editBtn.hidden = YES;
        [exit setTitle:@"退出群组" forState:UIControlStateNormal];
    }
}

- (void)settingImage:(NSInteger)imageId{
    switch (imageId) {
        case 0:
            _avatarImage.image = [UIImage imageNamed:@"头像1"];
            break;
        case 1:
            _avatarImage.image = [UIImage imageNamed:@"头像2"];
            break;
        case 2:
            _avatarImage.image = [UIImage imageNamed:@"头像3"];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HXRefreshUserDetailNotification object:nil];
}

- (HXDBManager *)hxDB{
    if (_hxDB == nil) {
        _hxDB = [HXDBManager shareDB];
    }
    return _hxDB;
}
@end
