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
@property (nonatomic ,strong ,nonnull)GroupMemberModel *model;
@property (nonatomic ,weak ,nullable)UIButton *deleteSelect;

@end
