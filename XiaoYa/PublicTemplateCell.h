//
//  PublicTemplateCell.h
//  XiaoYa
//
//  Created by commet on 16/11/29.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PublicTemplateCell : UITableViewCell
@property (nonatomic , weak)UIButton *choiceBtn;
@property (nonatomic , strong)NSArray *model;//模型

//初始化
//+(instancetype)PublicTemplateCellWithTableView:(UITableView *)tableview;
@end
