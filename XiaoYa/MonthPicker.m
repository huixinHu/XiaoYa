//
//  MonthPicker.m
//  rsaTest
//
//  Created by commet on 16/11/18.
//  Copyright © 2016年 commet. All rights reserved.
//月份选择器

#import "MonthPicker.h"
#import "DateUtils.h"
#import "Masonry.h"

@interface MonthPicker()<UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic ,weak) UIPickerView *pickerview;
@property (nonatomic , weak) UILabel *yearLab;
@property (nonatomic , weak) UILabel *monthLab;
@property (nonatomic , weak) UIButton *confirm;
@property (nonatomic , weak) UIButton *cancel;
@property (nonatomic , weak) UIView *line1;//横灰线
@property (nonatomic , weak) UIView *line2;//竖灰线

@property (nonatomic ,assign) NSInteger year;//当前年
@property (nonatomic ,assign) NSInteger month;//当前月
@property (nonatomic ,strong) NSDate *currentDate;//当前日期
@property (nonatomic ,strong) NSArray* monthArr;//月份数组
@property (nonatomic ,strong) NSDateComponents *curDateComp;

@end

@implementation MonthPicker
{
    NSInteger lastyear;//上一次滚动停止选中的年份
}

- (instancetype)initWithFrame:(CGRect)frame date:(NSDate* )currentDate{
    if (self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10.0;
//        self.layer.masksToBounds = YES;
        
        self.monthArr =@[@"1月",@"2月",@"3月",@"4月",@"5月",@"6月",@"7月",@"8月",@"9月",@"10月",@"11月",@"12月"];
        _currentDate = currentDate;
        NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        self.curDateComp = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:currentDate];
        _year = self.curDateComp.year;
        _month = self.curDateComp.month;
        
        [self drawHeader];
        [self commonInit];

        //row=self.monthArr.count * 5刚好是一月
        [_pickerview selectRow:(self.monthArr.count * 5 + _month - 1) inComponent:0 animated:NO];
        lastyear = self.monthArr.count * 5 / self.monthArr.count +1;
    }
    return self;
}

- (void)commonInit{
    UILabel *yearLab = [[UILabel alloc]init];
    _yearLab = yearLab;
    _yearLab.textAlignment = NSTextAlignmentCenter;
    _yearLab.text = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:_year]];
    _yearLab.textColor = [UIColor whiteColor];
    _yearLab.font = [UIFont systemFontOfSize:18.0];
    [self addSubview:_yearLab];
    
    UILabel *monthLab = [[UILabel alloc]init];
    _monthLab = monthLab;
    _monthLab.textAlignment = NSTextAlignmentCenter;
    _monthLab.text = [NSString stringWithFormat:@"%@月",[NSNumber numberWithInteger:_month]];
    _monthLab.textColor = [UIColor whiteColor];
    _monthLab.font = [UIFont systemFontOfSize:30.0];
    [self addSubview:_monthLab];
    
    UIPickerView *pickerview = [[UIPickerView alloc]init];
    _pickerview = pickerview;
    _pickerview.backgroundColor = [UIColor whiteColor];
    _pickerview.dataSource = self;
    _pickerview.delegate = self;
    [self addSubview:_pickerview];
    [_pickerview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(265, 200));
        make.top.equalTo(self.mas_top).offset(80);
    }];
    
    UIButton *confirm = [[UIButton alloc]init];
    _confirm = confirm;
    [_confirm setTitle:@"确认" forState:UIControlStateNormal];
    [_confirm setTitleColor:[UIColor colorWithRed:57/255.0 green:185/255.0 blue:248/255.0 alpha:1.0] forState:UIControlStateNormal];//39b9f8
    _confirm.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [_confirm addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_confirm];
    
    UIButton *cancel = [[UIButton alloc]init];
    _cancel = cancel;
    [_cancel setTitle:@"取消" forState:UIControlStateNormal];
    [_cancel setTitleColor:[UIColor colorWithRed:57/255.0 green:185/255.0 blue:248/255.0 alpha:1.0] forState:UIControlStateNormal];//39b9f8
    _cancel.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [_cancel addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancel];
    
    UIView *line1 = [[UIView alloc]init];
    _line1 = line1;
    _line1.backgroundColor = [UIColor colorWithRed:217/255.0 green:217/255.0 blue:217/255.0 alpha:1.0];//d9d9d9
    [self addSubview:_line1];
    
    UIView *line2 = [[UIView alloc]init];
    _line2 = line2;
    _line2.backgroundColor = [UIColor colorWithRed:217/255.0 green:217/255.0 blue:217/255.0 alpha:1.0];//d9d9d9
    [self addSubview:_line2];
}

- (void)confirmAction{
    self.curDateComp.year = _year;
    self.curDateComp.month = _month;
    self.curDateComp.day = 1;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *date = [calendar dateFromComponents:self.curDateComp];
//    date = [DateUtils getNowDateFromatAnDate:date];//时区修正
    [self.delegate monthPickerConfirmAction:self date:date];//返回的是某月的一号
    [self removeFromSuperview];
}

- (void)cancelAction{
    [self.delegate monthPickerCancelAction:self];
    [self removeFromSuperview];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGPoint center =  _pickerview.center;
    
    _yearLab.frame = CGRectMake(0, 13, 50, 18);
    center =  _yearLab.center;
    center.x = self.frame.size.width/2;
    _yearLab.center = center;
    
    _monthLab.frame = CGRectMake(0, 18+26, 70, 30);
    center =  _monthLab.center;
    center.x = self.frame.size.width/2;
    _monthLab.center = center;
    
    _confirm.frame = CGRectMake(self.frame.size.width / 2 , self.frame.size.height - 36, self.frame.size.width / 2, 36);
    _cancel.frame = CGRectMake(0, self.frame.size.height - 36, self.frame.size.width / 2, 36);
    _line1.frame = CGRectMake(0, self.frame.size.height - 36, self.frame.size.width, 0.5);
    _line2.frame = CGRectMake(self.frame.size.width / 2, self.frame.size.height - 36, 0.5, 36);
}

//一列
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

//行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.monthArr.count * 10;
}

//返回指定行的标题
- (nullable NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:self.monthArr[row % [self.monthArr count]] attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:51/255 green:51/255 blue:51/255 alpha:1.0],NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];//333333
    return attString;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
    
}

//停止滚动后调用
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSInteger newyear = row / self.monthArr.count +1;
    NSInteger delta = newyear - lastyear;
    _year = _year +delta;
    self.yearLab.text = [NSString stringWithFormat: @"%@", [NSNumber numberWithInteger:_year]];
    _month = row % self.monthArr.count + 1;
    self.monthLab.text = [NSString stringWithFormat: @"%@月", [NSNumber numberWithInteger:_month]];
    lastyear = newyear;
}

- (void)drawHeader{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(265, 322), NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat width = 265;
    CGFloat radius = 10;
    UIBezierPath*path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:M_PI endAngle:M_PI/2*3 clockwise:1];
    [path moveToPoint:CGPointMake(radius, 0)];
    [path addLineToPoint:CGPointMake(width - radius, 0)];
    [path addArcWithCenter:CGPointMake(width - radius , radius) radius:radius startAngle:M_PI*3/2 endAngle:M_PI*2 clockwise:1];
    [path addLineToPoint:CGPointMake(width, 86)];
    [path addLineToPoint:CGPointMake(0 , 86)];
    [path addLineToPoint:CGPointMake(0, radius)];
    [path closePath];
    UIColor *fillColor = [UIColor colorWithRed:57/255.0 green:185/255.0 blue:248/255.0 alpha:1.0];//39b9f8
    [fillColor set];
    [path fill];
    
    CGContextAddPath(ctx, path.CGPath);
    UIImage * getImage = UIGraphicsGetImageFromCurrentImageContext();
    [self addSubview:[[UIImageView alloc]initWithImage:getImage]];
    UIGraphicsEndImageContext();
}
@end
