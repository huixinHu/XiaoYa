//
//  DatePicker.m
//  rsaTest
//
//  Created by commet on 16/11/17.
//  Copyright © 2016年 commet. All rights reserved.
//日期选择器

#import "DatePicker.h"
#import "CalendarView.h"
#import "MonthPicker.h"
#import "Utils.h"

@interface DatePicker()
@property (nonatomic , weak) CalendarView *calendar;
@property (nonatomic , weak) UIButton *confirm;
@property (nonatomic , weak) UIButton *cancel;
@property (nonatomic , weak) UILabel *yearLab;
@property (nonatomic , weak) UIButton *monthBtn;
@property (nonatomic , weak) UIView *line1;//横灰线
@property (nonatomic , weak) UIView *line2;//竖灰线

@property (nonatomic ,assign) NSInteger year;//当前年
@property (nonatomic ,assign) NSInteger month;//当前月
@property (nonatomic ,strong) NSDate *currentDate;//当前日期
@property (nonatomic ,strong) NSDateComponents *curDateComp;
@property (nonatomic , strong) NSDate *firstDateOfTerm;//传入本学期第一天的日期
@end

@implementation DatePicker
{
    NSDate * today;
    CGFloat weekWidth;//“第几周”label宽度
    CGFloat cellWidth;//“日期”btn高度、宽度
}

- (instancetype)initWithFrame:(CGRect)frame date:(NSDate*)currentDate firstDateOfTerm:(NSDate *)firstDateOfTerm
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 10.0;
        _currentDate = currentDate;
        _firstDateOfTerm = firstDateOfTerm;
        NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        self.curDateComp = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:currentDate];
        _year = self.curDateComp.year;
        _month = self.curDateComp.month;

        [self drawHeader];
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    CalendarView *calendar = [[CalendarView alloc]initWithFrame:CGRectMake(0, 178/2, self.frame.size.width - 5, self.frame.size.height - (178+76)/2 -10) date:self.currentDate firstDateOfTerm:self.firstDateOfTerm];
    _calendar = calendar;
    [self addSubview:_calendar];
    
    UIButton *confirm = [[UIButton alloc]init];
    _confirm = confirm;
    [_confirm setTitle:@"确认" forState:UIControlStateNormal];
    [_confirm setTitleColor:[Utils colorWithHexString:@"#39b9f8"] forState:UIControlStateNormal];
    _confirm.titleLabel.font = [UIFont systemFontOfSize:13.0];
//    _confirm.backgroundColor = [UIColor whiteColor];
    [_confirm addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_confirm];
    
    UIButton *cancel = [[UIButton alloc]init];
    _cancel = cancel;
    [_cancel setTitle:@"取消" forState:UIControlStateNormal];
    [_cancel setTitleColor:[Utils colorWithHexString:@"#39b9f8"] forState:UIControlStateNormal];
    _cancel.titleLabel.font = [UIFont systemFontOfSize:13.0];
//    _cancel.backgroundColor = [UIColor whiteColor];
    [_cancel addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancel];
    
    UIView *line1 = [[UIView alloc]init];
    _line1 = line1;
    _line1.backgroundColor = [Utils colorWithHexString:@"#d9d9d9"];
    [self addSubview:_line1];
    
    UIView *line2 = [[UIView alloc]init];
    _line2 = line2;
    _line2.backgroundColor = [Utils colorWithHexString:@"#d9d9d9"];
    [self addSubview:_line2];
    
    UILabel *yearLab = [[UILabel alloc]init];
    _yearLab = yearLab;
    _yearLab.textAlignment = NSTextAlignmentCenter;
    _yearLab.text = [NSString stringWithFormat:@"%ld",(long)_year];
    _yearLab.textColor = [UIColor whiteColor];
    _yearLab.font = [UIFont systemFontOfSize:18.0];
    [self addSubview:_yearLab];
    
    UIButton *monthBtn = [[UIButton alloc]init];
    _monthBtn = monthBtn;
    [_monthBtn setTitle:[NSString stringWithFormat:@"%ld月",(long)_month] forState:UIControlStateNormal];
    [_monthBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _monthBtn.titleLabel.font = [UIFont systemFontOfSize:30.0];
    [_monthBtn addTarget:self action:@selector(monthChoice) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_monthBtn];
}

//确定，传回选择的日期
- (void)confirmAction{
    self.curDateComp.day = _calendar.btnClickedTag - 100;;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *SelectedDate = [calendar dateFromComponents:self.curDateComp];
    
    [self.delegate datePicker:self selectedDate:SelectedDate];
    [self removeFromSuperview];
}

//取消，移除视图，什么也不做
- (void)cancelAction{
    [self removeFromSuperview];
    [self.delegate datePickerCancelAction:self];
}

- (void)monthChoice{
    [self.delegate datePicker:self createMonthPickerWithDate:self.currentDate];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _calendar.frame = CGRectMake(0, 178/2, self.frame.size.width, self.frame.size.height - (178 + 76)/2);
    
    _confirm.frame = CGRectMake(self.frame.size.width/2, self.frame.size.height-38, self.frame.size.width/2, 38);
    _cancel.frame = CGRectMake(0, self.frame.size.height-38, self.frame.size.width/2, 38);
    _line1.frame = CGRectMake(0, self.frame.size.height-38, self.frame.size.width, 0.5);
    _line2.frame = CGRectMake(self.frame.size.width/2, self.frame.size.height-38, 0.5, 38);

    _yearLab.frame = CGRectMake(0, 20, 50, 18);
    CGPoint center =  _yearLab.center;
    center.x = self.frame.size.width/2;
    _yearLab.center = center;
    
    _monthBtn.frame = CGRectMake(0, 30 + 18 , 70, 30);
    center =  _monthBtn.center;
    center.x = self.frame.size.width/2;
    _monthBtn.center = center;
}

//- (void)drawRect:(CGRect)rect{
//    CGFloat width = self.frame.size.width;
//    CGFloat radius = 10;
//    UIBezierPath*path = [UIBezierPath bezierPath];
//    [path addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:M_PI endAngle:M_PI/2*3 clockwise:1];
//    [path moveToPoint:CGPointMake(radius, 0)];
//    [path addLineToPoint:CGPointMake(width - radius, 0)];
//    [path addArcWithCenter:CGPointMake(width - radius , radius) radius:radius startAngle:M_PI*3/2 endAngle:M_PI*2 clockwise:1];
//    [path addLineToPoint:CGPointMake(width, 178/2)];
//    [path addLineToPoint:CGPointMake(0 , 178 /2)];
//    [path addLineToPoint:CGPointMake(0, radius)];
//    [path closePath];
//    UIColor *fillColor = [UIColor colorWithRed:57/255.0 green:185/255.0 blue:248/255.0 alpha:1.0];//39b9f8
//    [fillColor set];
//    [path fill];
//}

- (void)drawHeader{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(321, 178), NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat width = 321;
    CGFloat radius = 10;
    UIBezierPath*path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:M_PI endAngle:M_PI/2*3 clockwise:1];
    [path moveToPoint:CGPointMake(radius, 0)];
    [path addLineToPoint:CGPointMake(width - radius, 0)];
    [path addArcWithCenter:CGPointMake(width - radius , radius) radius:radius startAngle:M_PI*3/2 endAngle:M_PI*2 clockwise:1];
    [path addLineToPoint:CGPointMake(width, 178/2)];
    [path addLineToPoint:CGPointMake(0 , 178 /2)];
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
