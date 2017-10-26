//
//  EditGroupDetailViewController.m
//  XiaoYa
//
//  Created by commet on 2017/9/12.
//  Copyright © 2017年 commet. All rights reserved.
//编辑群资料

#import "EditGroupDetailViewController.h"
#import "Utils.h"
#import "HXNotifyConfig.h"
#import "GroupListModel.h"
#import "GroupMemberModel.h"
#import "UIAlertController+Appearance.h"
#import "HXNetworking.h"
#import "HXDBManager.h"

@interface EditGroupDetailViewController ()
@property (nonatomic ,copy) gCreateSucBlock completeBlock;
@property (nonatomic ,strong) NSMutableSet <NSString *>*originMemberIds;
@property (nonatomic ,strong) HXDBManager *hxdb;
@end

@implementation EditGroupDetailViewController

- (instancetype)initWithGroupModel:(GroupListModel *)model successBlock:(gCreateSucBlock)block{
    if (self = [super initWithGroupModel:model successBlock:nil]) {
        self.completeBlock = block;
        self.originMemberIds = [NSMutableSet set];
        [model.groupMembers enumerateObjectsUsingBlock:^(GroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.originMemberIds addObject:obj.memberId];
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"群资料";
    UIButton *completeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [completeBtn setTitle:@"完成" forState:UIControlStateNormal];
    [completeBtn setTitleColor:[Utils colorWithHexString:@"#00a7fa"] forState:UIControlStateNormal];
    [completeBtn setTitleColor:[Utils colorWithHexString:@"78cbf8"] forState:UIControlStateDisabled];
    completeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [completeBtn addTarget:self action:@selector(complete) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:completeBtn];
    [self.createGroup setHidden:YES];
}

//完成
- (void)complete{
    if (self.groupName.text.length == 0) {
        void (^otherBlock)(UIAlertAction *action) = ^(UIAlertAction *action){
        };
        NSArray *otherBlocks = @[otherBlock];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请完善信息" message:@"群组名未输入" preferredStyle:UIAlertControllerStyleAlert cancelTitle:nil cancelBlock:nil otherTitles:@[@"确定"] otherBlocks:otherBlocks];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSString *groupName = self.groupName.text;
    NSString *groupId = self.groupModel.groupId;
    NSString *groupAvatarId = (self.avatarID >= 0) ? [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:self.avatarID - 101]] : self.groupModel.groupAvatarId;
    NSString *groupManagerId = self.groupModel.groupManagerId;
    NSString *numberOfMember = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:self.dataArray.count]];
    //成员增减
    NSMutableSet <NSString *>*curMemberIds = [NSMutableSet set];//存放现有成员的id
    NSMutableArray <GroupMemberModel*> *addMemberArr = [NSMutableArray array];//存放新增成员的模型
    NSMutableString *add = [NSMutableString string];
    NSMutableArray *addRelatParaArr = [NSMutableArray array];//插入关系表的数据
    [self.dataArray enumerateObjectsUsingBlock:^(GroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [curMemberIds addObject:obj.memberId];
        //添加的人
        if (![self.originMemberIds containsObject:obj.memberId]) {
            [addMemberArr addObject:obj];
            [add appendString:[NSString stringWithFormat:@"%@,",obj.memberId]];
            NSDictionary *tempDict = @{@"memberId":obj.memberId ,@"groupId":groupId};//添加到关系表的数据
            [addRelatParaArr addObject:tempDict];
        }
    }];
    if (add.length > 0) [add deleteCharactersInRange:NSMakeRange(add.length - 1, 1)];
    
    NSMutableSet <NSString *> *originSetCopy1 = [self.originMemberIds mutableCopy];
    [originSetCopy1 minusSet:curMemberIds];//减
    NSMutableString *minus = [NSMutableString string];
    NSMutableArray *delRelatWheresArr = [NSMutableArray array];//删除关系表的wheres数组
    if (originSetCopy1.count > 0) {//有删减
        [originSetCopy1 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [minus appendString:[NSString stringWithFormat:@"%@,",obj]];
            NSArray *temp = @[@"memberId", @"=", obj, @"groupId", @"=" ,groupId];
            [delRelatWheresArr addObject:temp];
        }];
        [minus deleteCharactersInRange:NSMakeRange(minus.length - 1, 1)];
    }
    
//    if (addMemberArr.count > 0) {
//        [addMemberArr enumerateObjectsUsingBlock:^(GroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            [add appendString:[NSString stringWithFormat:@"%@,",obj.memberId]];
//            NSDictionary *tempDict = @{@"memberId":obj.memberId ,@"groupId":groupId};
//            [addRelatParaArr addObject:tempDict];
//        }];
//        [add deleteCharactersInRange:NSMakeRange(add.length - 1, 1)];
//    }
    
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"CHGROUPDATA", @"type", groupId,@"groupId", groupManagerId, @"managerId", groupAvatarId, @"picId",groupName,@"groupName",add,@"addUsers",minus,@"minusUsers",nil];
    __weak typeof(self) ws = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __strong typeof(ws) ss = ws;
        [HXNetworking postWithUrl:httpUrl params:paraDict cache:NO success:^(NSURLSessionDataTask *task, id response) {
            if ([[response objectForKey:@"state"]boolValue] == 0){
                NSLog(@"修改群资料失败");
            } else{
                NSLog(@"%@",[response objectForKey:@"message"]);
                //更新数据库
                //1.群组表
                NSDictionary *groupParaDict = @{@"groupName":groupName ,@"groupAvatarId":groupAvatarId ,@"numberOfMember":numberOfMember};
                [ss.hxdb updateTable:groupTable param:groupParaDict whereArr:@[@"groupId", @"=" ,groupId] callback:^(NSError *error) {
                    NSLog(@"%@",error);
                }];
                //2.关系表
                if (delRelatWheresArr.count > 0) {
                    [ss.hxdb deleteTableInTransaction:memberGroupRelation whereArrs:delRelatWheresArr callback:^(NSError *error) {
                        NSLog(@"%@",error);
                    }];
                }
                if (addRelatParaArr.count > 0) {
                    [ss.hxdb insertTableInTransaction:memberGroupRelation paramArr:addRelatParaArr callback:^(NSError *error) {
                        NSLog(@"%@",error);
                    }];
                }
                //3.成员表 只需插入新加的人
                NSMutableArray *addMemParaArr = [NSMutableArray array];//插入成员表的数据
                [addMemberArr enumerateObjectsUsingBlock:^(GroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    //查询成员表，这些新增的人是否已经在数据库
                    int count = [ss.hxdb itemCountForTable:memberTable whereArr:@[@"memberId", @"=", obj.memberId]];
                    if (count == 0) {//数据库中没有
                        NSDictionary *memDict = @{@"memberId":obj.memberId, @"memberName":obj.memberName, @"memberPhone":obj.memberPhone};
                        [addMemParaArr addObject:memDict];
                    }
                }];
                if (addMemParaArr.count > 0) {
                    [ss.hxdb insertTableInTransaction:memberTable paramArr:addMemParaArr callback:^(NSError *error) {
                        NSLog(@"%@",error);
                    }];
                }
                
                //更新缓存
                NSDictionary *modelDict = @{@"groupName":groupName, @"groupId":groupId, @"groupAvatarId":groupAvatarId, @"numberOfMember":numberOfMember, @"groupManagerId":groupManagerId, @"groupMembers":[self.dataArray mutableCopy]};
                GroupListModel *refreshModel = [GroupListModel groupWithDict:modelDict];
                if (ss.completeBlock) {
                    ss.completeBlock(refreshModel);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ss.navigationController popViewControllerAnimated:YES];
                });
                NSDictionary *dataDict = [NSDictionary dictionaryWithObject:refreshModel forKey:HXEditGroupDetailKey];
                [[NSNotificationCenter defaultCenter] postNotificationName:HXEditGroupDetailNotification object:nil userInfo:dataDict];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"Error: %@", error);
        } refresh:NO];
    });
}

- (HXDBManager *)hxdb{
    if (_hxdb == nil) {
        _hxdb = [HXDBManager shareInstance];
    }
    return _hxdb;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
