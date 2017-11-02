//
//  EventPublishViewController.h
//  XiaoYa
//
//  Created by commet on 2017/8/1.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GroupInfoModel;

typedef void(^publishCompBlock)(GroupInfoModel * _Nullable newEvent);
@interface EventPublishViewController : UIViewController

- (nonnull instancetype)initWithInfoModel:(nonnull GroupInfoModel *)model publishCompBlock:(nullable publishCompBlock)block;
//- (instancetype)init NS_UNAVAILABLE;
@end
