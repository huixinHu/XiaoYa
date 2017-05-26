//
//  CollectView.h
//  XiaoYa
//
//  Created by commet on 17/3/19.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CollectView;
@protocol CollectViewDelegate <NSObject>
- (void)pushToDetailPage:(CollectView*)collectionView cellModel:(id)model;
@end

@interface CollectView : UIView
@property (nonatomic ,weak)id<CollectViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame modelArray:(NSArray *)modelArray;
@end
