//
//  CourseTimeCell.m
//  XiaoYa
//
//  Created by 曾凌峰 on 2016/11/5.
//  Copyright © 2016年 commet. All rights reserved.
//

#import "CourseTimeCell.h"
#import "Utils.h"
#import "Masonry.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define scaletowidth [UIApplication sharedApplication].keyWindow.bounds.size.width/750.0
//用在添加课程的页面
@implementation CourseTimeCell
- (void)setModel:(CourseModel *)model{
    [self.weeks setTitle:[self weeksArraytoWeeksString:model.weekArray] forState:UIControlStateNormal];
    [self.weekDay setTitle:[self weekDayNumtoWeekDay:model.weekday.integerValue] forState:UIControlStateNormal];
    NSString *courseTimeTitle = [self courseTimeArraytoCourseTimeString:model.timeArray];
    [self.courseTime setTitle:courseTimeTitle forState:UIControlStateNormal];
    if ([courseTimeTitle isEqualToString:@"选择时间"]) {
        [self.courseTime setTitleColor:[Utils colorWithHexString:@"#d9d9d9"] forState:UIControlStateNormal];
    }else{
        [self.courseTime setTitleColor:[Utils colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    }
    self.place.text = model.place;
}

+(instancetype)CourseTimeCellWithTableView:(UITableView *)tableview{
    static NSString *ID = @"CourseTimeCell";
    CourseTimeCell *cell = [tableview dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[CourseTimeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    self.backgroundColor = [UIColor whiteColor];
    __weak typeof(self) weakself = self;
    //添加竖线
    for(int i =0;i<2;i++){
        UIView *verticalline = [[UIView alloc] init];
        verticalline.backgroundColor = [Utils colorWithHexString:@"#D9D9D9"];
        [self addSubview:verticalline];
        [verticalline mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(160);
            make.width.mas_equalTo(0.5);
            make.left.equalTo(weakself.contentView.mas_left).offset((60  + 65 * i)/2);
            make.centerY.equalTo(weakself.contentView.mas_centerY);
        }];
    }
    //添加横线和箭头
    for (int i =0; i<3; i++) {
        UIView *horizonline = [[UIView alloc] init];
        horizonline.backgroundColor = [Utils colorWithHexString:@"#D9D9D9"];
        [self addSubview:horizonline];
        [horizonline mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0.5);
            make.width.mas_equalTo(500.0 *scaletowidth);
            make.left.equalTo(weakself.contentView.mas_left).offset(125.0 /2);
            make.top.equalTo(weakself.contentView.mas_top).offset(40 * (i+1));
        }];
        
        UIImageView *arrow = [[UIImageView alloc] init];
        arrow.image = [UIImage imageNamed:@"arrow"];
        [self addSubview:arrow];
        [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(horizonline.mas_right);
            make.bottom.equalTo(horizonline.mas_bottom);
        }];
    }

    UIButton *deletebtn = [[UIButton alloc] init];
    _delete_btn = deletebtn;
    [_delete_btn setImage:[UIImage imageNamed:@"删除圆"] forState:UIControlStateNormal];
    _delete_btn.backgroundColor = [UIColor whiteColor];
    [self addSubview:_delete_btn];
    [_delete_btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakself.mas_centerY);
        make.centerX.equalTo(weakself.mas_left).offset(30.0/2);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(60);
    }];
    
    UILabel *coursetime = [[UILabel alloc] init];
    coursetime.text = @"上\n课\n时\n间";
    coursetime.textColor = [Utils colorWithHexString:@"#333333"];
    coursetime.numberOfLines = [coursetime.text length];
    coursetime.font = [UIFont systemFontOfSize:14];
    coursetime.textAlignment = NSTextAlignmentCenter;
    [self addSubview:coursetime];
    [coursetime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(weakself.contentView.mas_height);
        make.width.mas_equalTo(65.0 /2);
        make.left.mas_equalTo(60.0 /2);
        make.centerY.equalTo(weakself.contentView.mas_centerY);
    }];
    
    //设置三个显示的button和一个field
    UIButton *weeks = [[UIButton alloc] init];
    _weeks = weeks;
    [self addSubview:_weeks];
    [_weeks setTitle:@"1-16周" forState:UIControlStateNormal];
    [_weeks setTitleColor:[Utils colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    _weeks.titleLabel.font = [UIFont systemFontOfSize:14];
    
    UIButton *weekDay = [[UIButton alloc] init];
    _weekDay = weekDay;
    [self addSubview:_weekDay];
    [_weekDay setTitle:@"周一" forState:UIControlStateNormal];
    [_weekDay setTitleColor:[Utils colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    _weekDay.titleLabel.font = [UIFont systemFontOfSize:14];
    
    UIButton *courseTime = [[UIButton alloc] init];
    _courseTime = courseTime;
    [self addSubview:_courseTime];
    [_courseTime setTitle:@"1-2节" forState:UIControlStateNormal];
    [_courseTime setTitleColor:[Utils colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    _courseTime.titleLabel.font = [UIFont systemFontOfSize:14];
    
    UITextField *place = [[UITextField alloc] init];
    _place = place;
    [self addSubview:_place];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSForegroundColorAttributeName] = [Utils colorWithHexString:@"#d9d9d9"];
    dict[NSFontAttributeName] = [UIFont systemFontOfSize:12.0];
    NSAttributedString *attribute = [[NSAttributedString alloc] initWithString:@"请输入上课教室" attributes:dict];
    [_place setAttributedPlaceholder:attribute];
    _place.font = [UIFont systemFontOfSize:12.0];
    [_place setTextAlignment:NSTextAlignmentCenter];
    
    [_weeks mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.contentView.mas_centerX);
        make.width.mas_equalTo(500.0 /2);
        make.height.mas_equalTo(40);
        make.top.equalTo(weakself.contentView.mas_top);
    }];
    [_weekDay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.contentView.mas_centerX);
        make.width.mas_equalTo(500.0 /2);
        make.height.mas_equalTo(40);
        make.top.equalTo(_weeks.mas_bottom);
    }];
    [courseTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.contentView.mas_centerX);
        make.width.mas_equalTo(500.0 /2);
        make.height.mas_equalTo(40);
        make.top.equalTo(_weekDay.mas_bottom);
    }];
    [_place mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakself.mas_centerX);
        make.width.mas_equalTo(500.0 /2);
        make.height.mas_equalTo(40);
        make.top.equalTo(courseTime.mas_bottom);
    }];
}

//显示格式处理,从选择的结果拼接出要显示的数据。如1-4,6,8-10 或 1-16（双周）
- (NSString *)weeksArraytoWeeksString:(NSMutableArray *)weeksArray{
    if(weeksArray.count == 0){ //如果没有选
        return @"";
    }else{
        NSString *weekTempStr = [NSString string];
        int i = 0;
        for (; i < weeksArray.count - 1; i++) {
            if ([weeksArray[i] intValue] + 2 != [weeksArray[i + 1] intValue]) {
                break;
            }
        }
        if (i == weeksArray.count - 1) {//可单双周表示
            if ([weeksArray[0] intValue] % 2 == 0) {//单周
                weekTempStr = [NSString stringWithFormat:@"%d-%d周(单周)",[[weeksArray firstObject]intValue]+1,[[weeksArray lastObject] intValue]+1];
            }else{//双周
                weekTempStr = [NSString stringWithFormat:@"%d-%d周(双周)",[[weeksArray firstObject]intValue]+1,[[weeksArray lastObject] intValue]+1];
            }
        }else{
            int start = [[NSString stringWithString:weeksArray[0]] intValue];
            int end=0;
            int step=1;
            for(int i = 1;i<weeksArray.count;i++)
            {
                NSString *weekstring = weeksArray[i];
                if(weekstring.intValue == start + step){
                    end = weekstring.intValue;
                    step++;
                }else{
                    if(end > start){
                        weekTempStr = [weekTempStr stringByAppendingFormat:@"%d-%d,",start+1,end+1];}
                    else{
                        weekTempStr = [weekTempStr stringByAppendingFormat:@"%d,",start+1];
                    }
                    start = [[NSString stringWithString:weeksArray[i]] intValue];
                    step = 1;
                }
            }
            if(end > start){
                weekTempStr = [weekTempStr stringByAppendingFormat:@"%d-%d",start+1,end+1];}
            else{
                weekTempStr = [weekTempStr stringByAppendingFormat:@"%d",start+1];}
            weekTempStr = [weekTempStr stringByAppendingFormat:@"周"];
        }
        return weekTempStr;
    }
}

- (NSString *)weekDayNumtoWeekDay:(NSInteger)index{
    NSArray * itemData = @[@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六",@"星期日"];
    return itemData[index];
}

- (NSString*)courseTimeArraytoCourseTimeString:(NSMutableArray *)timeArray
{
    if (timeArray.count == 0) {
        return @"选择时间";
    }else{
        //分割节数连续段
        NSMutableArray *sections = [[Utils subSectionArraysFromArray:timeArray] mutableCopy];
        NSMutableString *str = [NSMutableString string];
        NSString *start = [NSString string];
        NSString *end = [NSString string];
        for(int i = 0;i < sections.count;i++){
            start = [sections[i] firstObject];
            end = [sections[i] lastObject];
            if ([sections[i] count] == 1) {
                [str appendFormat:@"%@,",[self timeConvert:start]];
            }else{
                [str appendFormat:@"%@-%@,",[self timeConvert:start],[self timeConvert:end]];
            }
        }
        [str deleteCharactersInRange:NSMakeRange(str.length - 1, 1)];//截去最后一个符号“,”
        [str appendString:@" 节"];
        return str;
    }
}

- (NSString* )timeConvert:(NSString*)str{
    NSString *convert = [NSString string];
    if ([str intValue] == 0) {
        convert = @"早间";
    }else if ([str intValue] == 5){
        convert = @"午间";
    }else if([str intValue] > 5 && [str intValue] < 14){
        convert = [NSString stringWithFormat:@"%d",[str intValue] - 1];
    }
    else if ([str intValue] == 14){
        convert = @"晚间";
    }else{
        convert = str;
    }
    return convert;
}

@end
