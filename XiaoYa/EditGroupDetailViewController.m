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

@interface EditGroupDetailViewController ()
@property (nonatomic ,copy) gCreateSucBlock completeBlock;
@end

@implementation EditGroupDetailViewController

- (instancetype)initWithGroupModel:(GroupListModel *)model successBlock:(gCreateSucBlock)block{
    if (self = [super initWithGroupModel:model successBlock:nil]) {
        self.completeBlock = block;
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

    self.completeBlock(refreshModel);
    [self.navigationController popViewControllerAnimated:YES];
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:refreshModel forKey:HXRefreshGroupDetail];
    [[NSNotificationCenter defaultCenter] postNotificationName:HXEditGroupDetailNotification object:nil userInfo:dataDict];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
