//
//  WeekSheet.m
//  XiaoYa
//
//  Created by commet on 16/10/11.
//  Copyright © 2016年 commet. All rights reserved.
//

#import "WeekSheet.h"
#import "WeekCell.h"
#import "Masonry.h"
#import "Utils.h"
@interface WeekSheet()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic , weak)UITableView *weekTableView;
@property (strong, nonatomic) NSMutableArray *selectIndexs;//选中的行
@end

@implementation WeekSheet

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
        _selectIndexs = [NSMutableArray array];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)commonInit{
    [self drawSomething];
    
    CGFloat margin = 5;
    UITableView *weekTableView = [[UITableView alloc] init];
    _weekTableView = weekTableView;
    _weekTableView.delegate = self;
    _weekTableView.dataSource = self;
    _weekTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _weekTableView.bounces = NO;
    _weekTableView.rowHeight = 30;
    [self addSubview:_weekTableView];
    [_weekTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(margin + 5, margin, margin, margin));
    }];
    
    NSIndexPath *selectdIdxPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_weekTableView selectRowAtIndexPath:selectdIdxPath animated:NO scrollPosition:UITableViewScrollPositionTop];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 24;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //设置选中样式
    WeekCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.label.textColor = [Utils colorWithHexString:@"#FFFFFF"];
    cell.label.backgroundColor = [Utils colorWithHexString:@"39B9F8"];
    //通知导航栏标题改变
    [self.delegate refreshNavItemTitle:self content:indexPath.row];
    
    [self.selectIndexs addObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:indexPath.row]]];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    //设置非选中样式
    WeekCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.label.textColor = [Utils colorWithHexString:@"#000000"];
    cell.label.backgroundColor = [Utils colorWithHexString:@"FFFFFF"];
    
    [self.selectIndexs removeObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:indexPath.row]]];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"weekCell";
    WeekCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[WeekCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.label.text = [NSString stringWithFormat:@"第%@周",[NSNumber numberWithInteger:indexPath.row+1]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.label.textColor = [Utils colorWithHexString:@"#000000"];
    cell.label.backgroundColor = [Utils colorWithHexString:@"FFFFFF"];
    if ([_selectIndexs containsObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:indexPath.row]]]) {
        cell.label.textColor = [Utils colorWithHexString:@"#FFFFFF"];
        cell.label.backgroundColor = [Utils colorWithHexString:@"39B9F8"];
    }

    return cell;
}

//-(void)drawRect:(CGRect)rect{
//    CGFloat width = self.frame.size.width;//162
//    CGFloat height = self.frame.size.height;//178
//    CGFloat radius = 2;
//    CGFloat arrowHeight = 5;
//    CGFloat arrowWeight = 17;
//    
//    UIBezierPath*path = [UIBezierPath bezierPath];
//    [path addArcWithCenter:CGPointMake(radius, radius + arrowHeight) radius:radius startAngle:M_PI endAngle:M_PI/2*3 clockwise:1];
//    [path moveToPoint:CGPointMake(radius, arrowHeight)];
//    [path addLineToPoint:CGPointMake((width-arrowWeight)/2, arrowHeight)];
//    [path addLineToPoint:CGPointMake(width/2, 0)];
//    [path addLineToPoint:CGPointMake((width + arrowWeight)/2 , arrowHeight)];
//    [path addLineToPoint:CGPointMake(width - radius , arrowHeight)];
//    [path addArcWithCenter:CGPointMake(width - radius , radius + arrowHeight) radius:radius startAngle:M_PI*3/2 endAngle:M_PI*2 clockwise:1];
//    [path addLineToPoint:CGPointMake(width, height - radius)];
//    [path addArcWithCenter:CGPointMake(width - radius , height - radius) radius:radius startAngle:0 endAngle:M_PI/2.0 clockwise:1];
//    [path addLineToPoint:CGPointMake(radius , height)];
//    [path addArcWithCenter:CGPointMake(radius , height - radius) radius:radius startAngle:M_PI/2 endAngle:M_PI clockwise:1];
//    [path addLineToPoint:CGPointMake(0, radius + arrowHeight)];
//    [path closePath];
//    UIColor *fillColor = [UIColor whiteColor];
//    [fillColor set];
//    [path fill];
//}

- (void)drawSomething{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(162, 178), NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat width = 162;//162
    CGFloat height = 178;//178
    CGFloat radius = 2;
    CGFloat arrowHeight = 5;
    CGFloat arrowWeight = 17;
    
    UIBezierPath*path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(radius, radius + arrowHeight) radius:radius startAngle:M_PI endAngle:M_PI/2*3 clockwise:1];
    [path moveToPoint:CGPointMake(radius, arrowHeight)];
    [path addLineToPoint:CGPointMake((width-arrowWeight)/2, arrowHeight)];
    [path addLineToPoint:CGPointMake(width/2, 0)];
    [path addLineToPoint:CGPointMake((width + arrowWeight)/2 , arrowHeight)];
    [path addLineToPoint:CGPointMake(width - radius , arrowHeight)];
    [path addArcWithCenter:CGPointMake(width - radius , radius + arrowHeight) radius:radius startAngle:M_PI*3/2 endAngle:M_PI*2 clockwise:1];
    [path addLineToPoint:CGPointMake(width, height - radius)];
    [path addArcWithCenter:CGPointMake(width - radius , height - radius) radius:radius startAngle:0 endAngle:M_PI/2.0 clockwise:1];
    [path addLineToPoint:CGPointMake(radius , height)];
    [path addArcWithCenter:CGPointMake(radius , height - radius) radius:radius startAngle:M_PI/2 endAngle:M_PI clockwise:1];
    [path addLineToPoint:CGPointMake(0, radius + arrowHeight)];
    [path closePath];
    UIColor *fillColor = [UIColor whiteColor];
    [fillColor set];
    [path fill];
    
    CGContextAddPath(ctx, path.CGPath);
    UIImage * getImage = UIGraphicsGetImageFromCurrentImageContext();
    [self addSubview:[[UIImageView alloc]initWithImage:getImage]];
    //结束图形上下文
    UIGraphicsEndImageContext();
}

@end
