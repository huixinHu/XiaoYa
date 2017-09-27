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

@interface EditGroupDetailViewController ()
@property (nonatomic ,copy) gCreateSucBlock completeBlock;
@property (nonatomic ,strong) NSMutableSet <NSString *>*originMemberIds;
@end

@implementation EditGroupDetailViewController

- (instancetype)initWithGroupModel:(GroupListModel *)model successBlock:(gCreateSucBlock)block{
    if (self = [super initWithGroupModel:model successBlock:nil]) {
        self.completeBlock = block;
        NSMutableSet *originMemberIds = [NSMutableSet set];
        [model.groupMembers enumerateObjectsUsingBlock:^(GroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [originMemberIds addObject:obj.memberId];
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
    
    GroupListModel *refreshModel = [[GroupListModel alloc]init];
    refreshModel.groupMembers = [self.dataArray mutableCopy];
    if (self.avatarID >= 0) {
        refreshModel.groupAvatarId = [NSString stringWithFormat:@"%ld",self.avatarID - 101];
    } else{
        refreshModel.groupAvatarId = self.groupModel.groupAvatarId;
    }
    refreshModel.groupName = self.groupName.text;
    refreshModel.numberOfMember = self.dataArray.count;
    refreshModel.groupId = self.groupModel.groupId;
    refreshModel.managerId = self.groupModel.managerId;
    
    NSMutableSet <NSString *>*curMemberIds = [NSMutableSet set];
    [self.dataArray enumerateObjectsUsingBlock:^(GroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [curMemberIds addObject:obj.memberId];
    }];
    NSMutableSet <NSString *> *originSetCopy1 = [self.originMemberIds mutableCopy];
    [originSetCopy1 minusSet:curMemberIds];//减
    [curMemberIds minusSet:self.originMemberIds];//增
    NSString *minusUsers = [NSString string];
    if (originSetCopy1.count > 0) {//有删减
        NSMutableString *minus = [NSMutableString string];
        [originSetCopy1 enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [minus appendString:[NSString stringWithFormat:@"%@,",obj]];
        }];
        minusUsers = [minus substringToIndex:minus.length - 1];
    }
    NSString *addUsers = [NSMutableString string];
    if (curMemberIds.count > 0){//有增加
        NSMutableString *add = [NSMutableString string];
        [curMemberIds enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [add appendString:[NSString stringWithFormat:@"%@,",obj]];
        }];
        addUsers = [add substringToIndex:add.length - 1];
    }
    
    NSMutableDictionary *paraDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"CHGROUPDATA", @"type", refreshModel.groupId,@"groupId", refreshModel.managerId, @"managerId", refreshModel.groupAvatarId, @"picId",refreshModel.groupName,@"groupName",addUsers,@"addUsers",minusUsers,@"minusUsers",nil];
    __weak typeof(self) ws = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __strong typeof(ws) ss = ws;
        [HXNetworking postWithUrl:httpUrl params:paraDict cache:NO success:^(NSURLSessionDataTask *task, id response) {
            if ([[response objectForKey:@"state"]boolValue] == 0){
                NSLog(@"修改群资料失败");
            } else{
                NSLog(@"%@",[response objectForKey:@"message"]);
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
