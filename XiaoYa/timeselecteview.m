//
//  timeselecteview.m
//  XiaoYa
//
//  Created by 曾凌峰 on 2017/1/19.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "timeselecteview.h"
#import "Utils.h"
#import "Masonry.h"
#import "DbManager.h"
#import "TimeSelectedTableViewCell.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define kScreenHeight [UIApplication sharedApplication].keyWindow.bounds.size.height

#define scaletoheight [UIApplication sharedApplication].keyWindow.bounds.size.height/1334.0
#define scaletowidth [UIApplication sharedApplication].keyWindow.bounds.size.width/750.0
@interface timeselecteview()<UITableViewDelegate,UITableViewDataSource,TimeSelectedTableViewCellDelegate>
@property (nonatomic,weak) UIView* titleview; //顶部蓝色块和内部星期几的标签
@property (nonatomic,weak) UIButton *cancel_btn;
@property (nonatomic,weak) UIButton *confirm_btn;
@property (nonatomic,weak) UILabel *today;
@property (nonatomic,weak) UITableView *timetable;

@property (nonatomic,strong) NSMutableArray *timeData;//这里后来想想改成储存字典比较好，而不是直接储存array
@property (nonatomic,assign) NSInteger whichSection;
@property (strong, nonatomic) NSMutableArray *selectIndexs;//现多选选中的行
@property (nonatomic ,assign) NSInteger selectedWeekday;//现在选择的是星期几
@property (nonatomic ,strong) NSMutableArray *originIndexs;//原选中的行
@property (nonatomic ,assign) NSInteger originWeekday;//原星期几
@end

@implementation timeselecteview
- (instancetype)initWithFrame:(CGRect)frame andCellModel:(CourseModel *)cellModel indexSection:(NSInteger)section originIndexs:(NSMutableArray*)originIndexs originWeekday:(NSInteger)originWeekday{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10.0;
        self.layer.masksToBounds = YES;
        _selectIndexs = [cellModel.timeArray mutableCopy];
        _selectedWeekday = cellModel.weekday.integerValue;
        _originWeekday = originWeekday;
        _originIndexs = [originIndexs mutableCopy];
        self.whichSection = section;
        //timeData数组的说明：元素1：“时间段”，元素2“第几节”，元素三“课程信息”（为空代表没课程）
        [self timeDataInit];
        [self loadCoursefromSQLwithCourseCellModel:cellModel];
        [self apperanceSetting];
        
        NSArray *weekdaylabel = @[@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六",@"星期日"];//这里应该把它写在apperanceSetting方法里比较好
        _today.text = weekdaylabel[cellModel.weekday.intValue];
    }
    return self;
}

//显示在表格里的课程名的处理
-(void)loadCoursefromSQLwithCourseCellModel:(CourseModel *)cellModel{
    NSMutableArray *courseNameArray = [NSMutableArray arrayWithCapacity:15];
    for (int i = 0; i < 15; i++) {
        [courseNameArray addObject:[[NSMutableSet alloc]init]];
    }
    DbManager *dbManger = [DbManager shareInstance];
    for (int i = 0; i < cellModel.weekArray.count; i++) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM course_table WHERE weeks like '%%,%@,%%' and weekDay is '%@'",cellModel.weekArray[i],[NSNumber numberWithInteger:self.selectedWeekday]];
        NSArray *dataFromSQL = [dbManger executeQuery:sql];
        
        if(dataFromSQL.count == 0) continue;//没有数据则说明这一天没有课程即不用继续下面的操作
        for(int m = 0; m < dataFromSQL.count; m++){
            NSDictionary *course = dataFromSQL[m];
            CourseModel *tempModel = [[CourseModel alloc]initWithDict:course];
            for (int n = 0; n < tempModel.timeArray.count; n++) {
                int index = [tempModel.timeArray[n] intValue];
                [courseNameArray[index] addObject:tempModel.courseName];
            }
        }
    }
    for (int i = 0; i < 15; i++) {
        if ([courseNameArray[i] count] > 0) {
            NSMutableString *str = [NSMutableString string];
            NSMutableSet *set = courseNameArray[i];
            for (NSString *courseName in set) {
                [str appendFormat:@"%@,",courseName];
            }
            [str deleteCharactersInRange:NSMakeRange(str.length - 1, 1)];
            [self.timeData[i] addObject:str];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.timeData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TimeSelectedTableViewCell *cell = [TimeSelectedTableViewCell TimeSelectCellWithTableView:tableView];
    [cell itemData:self.timeData[indexPath.row] selectIndexs:self.selectIndexs selectedWeekday:self.selectedWeekday originIndexs:self.originIndexs originWeekday:self.originWeekday indexPathRow:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    return cell;
}

#pragma mark TimeSelectedTableViewCellDelegate
- (void)TimeSelectedTableViewCell:(TimeSelectedTableViewCell *)cell selectIndex:(NSIndexPath *)indexPath{
    [self.selectIndexs addObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:indexPath.row]]];
    if (self.selectedWeekday == self.originWeekday) {
        if ([_originIndexs containsObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:indexPath.row]]]) {
            cell.conflict.hidden = YES;//封装不太好
        }
    }
}

- (void)TimeSelectedTableViewCell:(TimeSelectedTableViewCell*)cell deSelectIndex:(NSIndexPath *)indexPath{
    [self.selectIndexs removeObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:indexPath.row]]];
}

-(void)timeSelectCancel
{
    [_delegate timeSelectCancel:self];
    [self removeFromSuperview];
}

-(void)timeSelectConfirm
{
    [self removeFromSuperview];
    [self.selectIndexs sortUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2){
         if ([obj1 integerValue] < [obj2 integerValue]){
             return NSOrderedAscending;//将第一个元素放在第二个元素之前
         }else{
             return NSOrderedDescending;//将第一个元素放在第二个元素之后
         }
     }];
    [self.delegate timeSelectComfirm:self courseTimeArray:self.selectIndexs inSection:self.whichSection];
}

- (void)apperanceSetting{
    UIView *titleview = [[UIView alloc] init];
    _titleview = titleview;
    _titleview.backgroundColor = [Utils colorWithHexString:@"#39B9F8"];
    [self addSubview:_titleview];
    [_titleview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.width.centerX.equalTo(self);
        make.height.mas_equalTo(67);
    }];
    
    UILabel *today = [[UILabel alloc] init];
    _today = today;
    [_today setTextColor:[Utils colorWithHexString:@"#FFFFFF"]];
    [_today setTextAlignment:NSTextAlignmentCenter];
    [_today setFont:[UIFont systemFontOfSize:30]];
    [_titleview addSubview:_today];
    [_today mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.and.centerY.equalTo(_titleview);
    }];
    
    UITableView *timetable = [[UITableView alloc] init];
    _timetable = timetable;
    _timetable.dataSource = self;
    _timetable.delegate = self;
    _timetable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _timetable.bounces = NO;
    [self addSubview:_timetable];
    [timetable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleview.mas_bottom);
        make.width.and.centerX.equalTo(self);
        make.height.mas_equalTo((716-134-76)/2);
    }];
    
    UIView *line1 = [[UIView alloc] init];//横线
    line1.backgroundColor = [Utils colorWithHexString:@"#D9D9D9"];
    [self addSubview: line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.mas_width);
        make.height.mas_equalTo(0.5);
        make.centerX.equalTo(self.mas_centerX);
        make.bottom.equalTo(self.mas_bottom).offset(-38);
    }];
    UIView *line2 = [[UIView alloc] init];//竖线
    line2.backgroundColor = [Utils colorWithHexString:@"#D9D9D9"];
    [self addSubview: line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0.5);
        make.height.mas_equalTo(38);
        make.centerX.equalTo(self.mas_centerX);
        make.bottom.equalTo(self.mas_bottom);
    }];
    //添加取消和确认按钮
    UIButton *cancel_btn = [[UIButton alloc] init];
    _cancel_btn=cancel_btn;
    [_cancel_btn setTitle:@"取消" forState:UIControlStateNormal];
    [_cancel_btn setTitleColor:[Utils colorWithHexString:@"#00A7FA"] forState:UIControlStateNormal];
    _cancel_btn.titleLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:_cancel_btn];
    [_cancel_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(38);
        make.width.mas_equalTo(self.frame.size.width/2);
        make.right.equalTo(line2.mas_left);
        make.top.equalTo(line1.mas_bottom);
    }];
    UIButton *confirm_btn = [[UIButton alloc] init];
    _confirm_btn=confirm_btn;
    [_confirm_btn setTitle:@"确认" forState:UIControlStateNormal];
    [_confirm_btn setTitleColor:[Utils colorWithHexString:@"#00A7FA"] forState:UIControlStateNormal];
    _confirm_btn.titleLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:_confirm_btn];
    [_confirm_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(38);
        make.width.mas_equalTo(self.frame.size.width/2);
        make.left.equalTo(line2.mas_right);
        make.top.equalTo(line1.mas_bottom);
    }];
    
    [_cancel_btn addTarget:self action:@selector(timeSelectCancel) forControlEvents:UIControlEventTouchUpInside];
    [_confirm_btn addTarget:self action:@selector(timeSelectConfirm) forControlEvents:UIControlEventTouchUpInside];
}


- (void)timeDataInit{
    self.timeData = [NSMutableArray arrayWithCapacity:15];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"早间",@"", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"8:00",@"1", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"8:55",@"2", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"10:00",@"3", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"10:55",@"4", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"午间",@"", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"14:30",@"5", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"15:25",@"6", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"16:20",@"7", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"17:15",@"8", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"18:10",@"9", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"19:00",@"10", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"19:55",@"11", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"20:50",@"12", nil]];
    [self.timeData addObject:[NSMutableArray arrayWithObjects:@"晚间",@"", nil]];
}
@end
