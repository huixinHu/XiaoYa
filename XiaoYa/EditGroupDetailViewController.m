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
#import "GroupInfoModel.h"
#import "GroupMemberModel.h"
#import "UIAlertController+Appearance.h"
#import "HXNetworking.h"
#import "HXDBManager.h"

@interface EditGroupDetailViewController ()
@property (nonatomic ,copy) gCreateSucBlock completeBlock;
@property (nonatomic ,strong) NSMutableSet <NSString *>*originMemberIds;
@property (nonatomic ,strong) HXDBManager *hxdb;
@property (nonatomic ,copy) NSString *originGroupName;
@property (nonatomic ,strong) NSMutableArray <GroupMemberModel *> *originMembers;
@end

@implementation EditGroupDetailViewController

- (instancetype)initWithGroupModel:(GroupListModel *)model successBlock:(gCreateSucBlock)block{
    if (self = [super initWithGroupModel:model successBlock:nil]) {
        self.completeBlock = block;
        self.originMemberIds = [NSMutableSet set];
        [model.groupMembers enumerateObjectsUsingBlock:^(GroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.originMemberIds addObject:obj.memberId];
        }];
        self.originGroupName = model.groupName;
        self.originMembers = [model.groupMembers copy];
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

    NSMutableString *minus = [NSMutableString string];
    NSMutableArray *delRelatWheresArr = [NSMutableArray array];//删除关系表的wheres数组
    //有删减
    NSMutableArray <GroupMemberModel *> *delMemberArr = [NSMutableArray arrayWithCapacity:0];//存放踢出成员的模型
    [self.originMembers enumerateObjectsUsingBlock:^(GroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![curMemberIds containsObject:obj.memberId]) {
            [delMemberArr addObject:obj];
            [minus appendString:[NSString stringWithFormat:@"%@,",obj.memberId]];
            [delRelatWheresArr addObject:@{@"WHERE memberId = ? AND groupId = ?":@[obj,groupId]}];
        }
    }];
    if (minus.length > 0) [minus deleteCharactersInRange:NSMakeRange(minus.length - 1, 1)];
    
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
                [ss.hxdb updateTable:groupTable param:groupParaDict whereDict:@{@"WHERE groupId = ?":@[groupId]} callback:^(NSError *error) {
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
                    int count = [ss.hxdb itemCountForTable:memberTable whereDict:@{@"WHERE memberId = ?" : @[obj.memberId]}];
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
                
                //4.消息表
                NSMutableArray *insertMegList = [NSMutableArray arrayWithCapacity:0];//由于群资料更改产生的新群组消息
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *tempDate = [df dateFromString:[response objectForKey:@"time"]];
                [df setDateFormat:@"yyyyMMddHHmmss"];
                NSString *tempDateStr = [df stringFromDate:tempDate];
                __block int random = (arc4random() % 10000)+10000;//10000~19999随机数
                //群名
                if (![ss.originGroupName isEqualToString:groupName]) {
                    NSString *randomStr = [[NSString stringWithFormat:@"%d" ,random] substringFromIndex:1];
                    NSDictionary *groupInfoDict = @{@"publishTime":[NSString stringWithFormat:@"%@%@",tempDateStr,randomStr] , @"event":[NSString stringWithFormat:@"群组名改为%@",groupName] , @"groupId":groupId};
                    GroupInfoModel *infoModel = [GroupInfoModel groupInfoWithDict:groupInfoDict];
                    [insertMegList addObject:infoModel];
                }
                //添加的人
                [addMemberArr enumerateObjectsUsingBlock:^(GroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    random +=1;
                    NSString *randomStr = [NSString stringWithFormat:@"%@",@(idx+random)];//从群组名更改的random+1开始
                    NSString *publishTime = [tempDateStr stringByAppendingString:[randomStr substringFromIndex:1]];
                    NSDictionary *groupInfoDict = @{@"publishTime":publishTime , @"event":[NSString stringWithFormat:@"%@加入群组",obj.memberName] , @"groupId":groupId};
                    GroupInfoModel *infoModel = [GroupInfoModel groupInfoWithDict:groupInfoDict];
                    [insertMegList addObject:infoModel];
                }];
                //踢出的人
                [delMemberArr enumerateObjectsUsingBlock:^(GroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    random += 1;
                    NSString *randomStr = [NSString stringWithFormat:@"%@",@(idx+random)];
                    NSString *publishTime = [tempDateStr stringByAppendingString:[randomStr substringFromIndex:1]];
                    NSDictionary *groupInfoDict = @{@"publishTime":publishTime , @"event":[NSString stringWithFormat:@"%@被踢出群组",obj.memberName] , @"groupId":groupId};
                    GroupInfoModel *infoModel = [GroupInfoModel groupInfoWithDict:groupInfoDict];
                    [insertMegList addObject:infoModel];

                }];
                //插入由于群资料更改产生的新群组消息
                if (insertMegList.count > 0) {
                    NSMutableArray *exclude = [NSMutableArray arrayWithCapacity:0];
                    for (int i = 0; i < insertMegList.count; ++i) {
                        [exclude addObject:@[@"eventSection",@"deadlineIndex"]];
                    }
                    [self.hxdb insertTableInTransaction:groupInfoTable modelArr:insertMegList excludeProperty:exclude callback:^(NSError *error) {
                        NSLog(@"%@",error);
                    }];
                    insertMegList = (NSMutableArray *)[[insertMegList reverseObjectEnumerator] allObjects];//倒序。时间越晚的越前
                }
                
                //更新缓存
                NSDictionary *modelDict = @{@"groupName":groupName, @"groupId":groupId, @"groupAvatarId":groupAvatarId, @"numberOfMember":numberOfMember, @"groupManagerId":groupManagerId, @"groupMembers":[self.dataArray mutableCopy], @"deleteFlag":@0};
                GroupListModel *refreshModel = [GroupListModel groupWithDict:modelDict];
                if (ss.completeBlock) {
                    ss.completeBlock(refreshModel);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [ss.navigationController popViewControllerAnimated:YES];
                });
                NSDictionary *dataDict = @{HXEditGroupDetailKey:refreshModel ,@"insertMegList":insertMegList};
                [[NSNotificationCenter defaultCenter] postNotificationName:HXEditGroupDetailNotification object:nil userInfo:dataDict];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"Error: %@", error);
            NSError *underErr = error.userInfo[@"NSUnderlyingError"];
            NSData *data = underErr.userInfo[@"com.alamofire.serialization.response.error.data"];
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"result :%@",result);
        } refresh:NO];
    });
}

- (HXDBManager *)hxdb{
    if (_hxdb == nil) {
        _hxdb = [HXDBManager shareDB];
    }
    return _hxdb;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
