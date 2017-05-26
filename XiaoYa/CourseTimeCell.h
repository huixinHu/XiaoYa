//
//  CourseTimeCell.h
//  XiaoYa
//
//  Created by 曾凌峰 on 2016/11/5.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourseModel.h"
@interface CourseTimeCell : UITableViewCell

@property (nonatomic,weak) UIButton *weeks;
@property (nonatomic,weak) UIButton *weekDay;
@property (nonatomic,weak) UIButton *courseTime;
@property (nonatomic,weak) UIButton *delete_btn;
@property (nonatomic,weak) UITextField *place;
@property (nonatomic , strong)CourseModel *model;//模型
+(instancetype)CourseTimeCellWithTableView:(UITableView *)tableview;

@end
