//
//  CollectionViewCell.m
//  XiaoYa
//
//  Created by commet on 17/3/19.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "CollectionViewCell.h"
#import "BusinessModel.h"
#import "CourseModel.h"
#import "DbManager.h"
#import "CourseViewController.h"
#import "BusinessViewController.h"
#import "Utils.h"
@interface CollectionViewCell()
@property (nonatomic ,weak)UILabel *lab;
@end

@implementation CollectionViewCell
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
        _lab = lab;
        [self.contentView addSubview:_lab];
        _lab.textAlignment = NSTextAlignmentCenter;
        _lab.numberOfLines = 0;
        _lab.font = [UIFont systemFontOfSize:13];
        _lab.textColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setModel:(id)model{
    _model = model;
    if ([model isKindOfClass:[BusinessModel class]]) {
        BusinessModel *busMDL = model;
        _lab.text = busMDL.desc;
        self.backgroundColor = [Utils colorWithHexString:@"#02d6ac"];
    }else if([model isKindOfClass:[CourseModel class]]){
        CourseModel *courseMDL = model;
        _lab.text = [NSString stringWithFormat:@"%@\n@%@",courseMDL.courseName,courseMDL.place];
        self.backgroundColor = [Utils colorWithHexString:@"#39b9f8"];
    }
}
@end
