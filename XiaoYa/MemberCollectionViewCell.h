//
//  MemberCollectionViewCell.h
//  XiaoYa
//
//  Created by commet on 2017/7/11.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupMemberModel;

@interface MemberCollectionViewCell : UICollectionViewCell
@property (nonatomic ,strong)GroupMemberModel *model;
@property (nonatomic ,weak)UIButton *deleteSelect;

@end
