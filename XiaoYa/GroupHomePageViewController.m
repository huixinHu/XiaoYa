//
//  GroupHomePageViewController.m
//  XiaoYa
//
//  Created by commet on 2017/7/7.
//  Copyright © 2017年 commet. All rights reserved.
//群组首页

#import "GroupHomePageViewController.h"
#import "GroupHomePageCell.h"
#import "GroupCreateViewController.h"
#import "GroupListModel.h"
#import "Utils.h"
#import "Masonry.h"
#import "JoinGroupViewController.h"

@interface GroupHomePageViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,weak)UIImageView *menu;
@property (nonatomic ,weak)UITableView *groupTable;
@property (nonatomic ,weak)UIButton *menuBtn;
@property (nonatomic ,strong)NSMutableArray *groupModels;

@end

@implementation GroupHomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self viewsSetting];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)create{
    GroupCreateViewController *createVC = [[GroupCreateViewController alloc]init];
    createVC.hidesBottomBarWhenPushed = YES;//从下级vc开始，tabbar都隐藏掉
    [self.navigationController pushViewController:createVC animated:YES];
    _menuBtn.selected = NO;
    _menu.hidden = YES;
}

- (void)join{
    JoinGroupViewController *joinVC = [[JoinGroupViewController alloc]init];
    joinVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:joinVC animated:YES];
    _menuBtn.selected = NO;
    _menu.hidden = YES;
}

#pragma mark tableview datasource &delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.groupModels.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 68;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GroupListModel *model = self.groupModels[indexPath.row];
    GroupHomePageCell *cell = [GroupHomePageCell groupHomePageCellWithTableView:tableView];
    cell.group = model;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"clicked table");
}

#pragma mark views setting
- (void)viewsSetting{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBg"] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[Utils colorWithHexString:@"#333333"],NSFontAttributeName:[UIFont systemFontOfSize:17]};
    self.navigationItem.title = @"群组";
    UIButton *menuBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    _menuBtn = menuBtn;
    [_menuBtn setImage:[UIImage imageNamed:@"点"] forState:UIControlStateNormal];
    [_menuBtn addTarget:self action:@selector(menuAppearAndHide:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:_menuBtn];
    self.view.backgroundColor = [Utils colorWithHexString:@"#F0F0F6"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    singleTap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:singleTap];
    [self grouplistSetting];
    [self menuSetting];
}

- (void)menuAppearAndHide:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        _menu.hidden = NO;
    }else{
        _menu.hidden = YES;
    }
}

-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer{
    _menu.hidden = YES;
    _menuBtn.selected = NO;
}

- (void)menuSetting{
    __weak typeof(self) weakself = self;
    UIImageView *menu = [[UIImageView alloc] init];
    _menu = menu;
    _menu.image = [self drawMenu];
    [self.view addSubview:_menu];
    [_menu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(113, 106));
        make.right.equalTo(weakself.view.mas_right).offset(-20);
        make.top.equalTo(weakself.view);
    }];
    _menu.userInteractionEnabled = YES;
    _menu.hidden = YES;
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [Utils colorWithHexString:@"636363"];
    [_menu addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(88, 1));
        make.centerX.equalTo(_menu.mas_centerX);
        make.top.equalTo(_menu.mas_top).offset(56);
    }];
    
    UIButton *joinGroup = [[UIButton alloc]init];
    [joinGroup setImage:[UIImage imageNamed:@"加入群组"] forState:UIControlStateNormal];
    [joinGroup setTitle:@"加入群组" forState:UIControlStateNormal];
    joinGroup.titleLabel.font = [UIFont systemFontOfSize:14.0];
    joinGroup.titleEdgeInsets = UIEdgeInsetsMake(0, 13, 0, 0);
    [joinGroup addTarget:self action:@selector(join) forControlEvents:UIControlEventTouchUpInside];
    [_menu addSubview:joinGroup];
    [joinGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(113, 50));
        make.top.equalTo(_menu.mas_top).offset(6);
        make.centerX.equalTo(_menu.mas_centerX);
    }];
    
    UIButton *creatGroup = [[UIButton alloc]init];
    [creatGroup setImage:[UIImage imageNamed:@"创建群组"] forState:UIControlStateNormal];
    [creatGroup setTitle:@"创建群组" forState:UIControlStateNormal];
    creatGroup.titleLabel.font = [UIFont systemFontOfSize:14.0];
    creatGroup.titleEdgeInsets = UIEdgeInsetsMake(0, 13, 0, 0);
    [creatGroup addTarget:self action:@selector(create) forControlEvents:UIControlEventTouchUpInside];
    [_menu addSubview:creatGroup];
    [creatGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(113, 50));
        make.bottom.centerX.equalTo(_menu);
    }];
}

- (void)grouplistSetting{
    __weak typeof(self)weakself = self;
    UITableView *groupTable = [[UITableView alloc]init];
    _groupTable = groupTable;
    _groupTable.delegate = self;
    _groupTable.dataSource = self;
    _groupTable.bounces = NO;
    _groupTable.backgroundColor = [Utils colorWithHexString:@"#F0F0F6"];
    [self.view addSubview:_groupTable];
    [_groupTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.top.centerX.equalTo(weakself.view);
    }];
    
    [_groupTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (UIImage *)drawMenu{
    CGFloat arrowHeight = 6.0 , arrowWidth = 6.0;
    CGFloat radius = 2.0;
    CGFloat width = 113 , height = 106;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath*path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(radius, radius + arrowHeight) radius:radius startAngle:M_PI endAngle:M_PI/2*3 clockwise:1];
    [path moveToPoint:CGPointMake(radius, arrowHeight)];
    [path addLineToPoint:CGPointMake(94, arrowHeight)];
    [path addLineToPoint:CGPointMake(94+arrowWidth/2, 0)];
    [path addLineToPoint:CGPointMake(94+arrowWidth , arrowHeight)];
    [path addLineToPoint:CGPointMake(width-radius , arrowHeight)];
    [path addArcWithCenter:CGPointMake(width - radius , radius + arrowHeight) radius:radius startAngle:M_PI*3/2 endAngle:M_PI*2 clockwise:1];
    [path addLineToPoint:CGPointMake(width, height - radius)];
    [path addArcWithCenter:CGPointMake(width - radius , height - radius) radius:radius startAngle:0 endAngle:M_PI/2.0 clockwise:1];
    [path addLineToPoint:CGPointMake(radius , height)];
    [path addArcWithCenter:CGPointMake(radius , height - radius) radius:radius startAngle:M_PI/2 endAngle:M_PI clockwise:1];
    [path addLineToPoint:CGPointMake(0, radius + arrowHeight)];
    [path closePath];
    UIColor *fillColor = [Utils colorWithHexString:@"#474747"];
    [fillColor set];
    [path fill];
    
    CGContextAddPath(ctx, path.CGPath);
    UIImage * getImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return getImage;
}

#pragma mark lazyload
- (NSMutableArray *)groupModels{
    if (_groupModels == nil) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"test.plist" ofType:nil];
        NSArray *arrayDict = [NSArray arrayWithContentsOfFile:path];
        NSMutableArray *arrModels = [NSMutableArray array];
        for (NSDictionary *dict in arrayDict) {
            GroupListModel *model = [GroupListModel groupWithDict:dict];
            [arrModels addObject:model];
        }
        _groupModels = arrModels;
    }
    return _groupModels;
}
@end
