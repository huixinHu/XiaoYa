//
//  CollectView.m
//  XiaoYa
//
//  Created by commet on 17/3/19.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "CollectView.h"
#import "CollectionViewCell.h"
#import "Utils.h"
static NSString * const CellReuseIdentify = @"CellReuseIdentify";
@interface CollectView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic ,strong)NSArray *modelArray;
@end

@implementation CollectView
- (instancetype)initWithFrame:(CGRect)frame modelArray:(NSArray *)modelArray{
    if (self = [super initWithFrame:frame]) {
        [self setUpViews];
        self.backgroundColor = [UIColor clearColor];
        self.modelArray = modelArray;
    }
    return self;
}

- (void)setUpViews{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 20;
    layout.itemSize = CGSizeMake(100, 100);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [self addSubview:collectionView];
    
    //注册
    [collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:CellReuseIdentify];
}

#pragma mark - UICollectionViewDataSource method
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.modelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentify forIndexPath:indexPath];
//    cell.backgroundColor = [Utils colorWithHexString:@"#39b9f8"];
    cell.model = self.modelArray[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCell *cell = (CollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [self.delegate pushToDetailPage:self cellModel:cell.model];
}

@end
