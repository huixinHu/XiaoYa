//
//  WeekCell.m
//  XiaoYa
//
//  Created by commet on 16/10/17.
//  Copyright © 2016年 commet. All rights reserved.
//
//weeksheet（导航栏标题按钮选择第几周）的下拉选择菜单tableview上的cell
#import "WeekCell.h"
#import "Utils.h"
@implementation WeekCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        UILabel *lable = [[UILabel alloc] init];
        self.label = lable;
        _label.textAlignment =NSTextAlignmentCenter;
        _label.textColor = [Utils colorWithHexString:@"#333333"];
        _label.font = [UIFont systemFontOfSize:12];
        _label.backgroundColor = [UIColor whiteColor];
        _label.layer.cornerRadius = 2;
        _label.layer.masksToBounds = true;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:_label];
    }
    return self;
}

-(void)layoutSubviews{
    _label.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame));
}


//- (void)awakeFromNib {
//    // Initialization code
//}


@end
