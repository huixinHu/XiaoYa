//
//  weekselectview.m
//  XiaoYa
//
//  Created by 曾凌峰 on 2016/11/14.
//  Copyright © 2016年 commet. All rights reserved.
//

#import "weekselectview.h"
#import "Utils.h"
#import "Masonry.h"


#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define kScreenHeight [UIApplication sharedApplication].keyWindow.bounds.size.height
#define scaletowidth [UIApplication sharedApplication].keyWindow.bounds.size.width/750.0

@interface weekselectview()
@property (nonatomic,weak) UIButton *singleweek;
@property (nonatomic,weak) UIButton *doubleweek;
@property (nonatomic,weak) UIButton *allweek;
@property (nonatomic,weak) UIButton *cancel_btn;
@property (nonatomic,weak) UIButton *confirm_btn;
@property (nonatomic,assign) NSInteger whichSection;
@property (nonatomic,strong) NSMutableArray *weekselected_array;//存储周数btn的数组，24个
@property (nonatomic,strong) NSMutableArray* selectResult;//点击确认时选择了的周数数组
@end

@implementation weekselectview
{
    CGFloat marginX;
    CGFloat marginY;
    CGFloat weeknumwidth;
}
- (instancetype)initWithFrame:(CGRect)frame andWeekSelect:(NSArray *)showweek indexSection:(NSInteger)section{
    if(self = [super initWithFrame:frame]){
        self.layer.cornerRadius = 10;
        self.backgroundColor = [Utils colorWithHexString:@"#FFFFFF"];
        self.whichSection = section;
        marginX = 8.75;
        marginY = 7;
        weeknumwidth = 30;
        
        [self segmentSetting];
        [self setWeekBtn:showweek];
        [self CancelComfirmBtnSetting];
    }
    return self;
}

//-----------------------------------单周 双周 全选--------------------------------------------
- (void)segmentSetting{
    UIView *weekchoice = [[UIView alloc]init];
    weekchoice.layer.borderWidth = 1;
    weekchoice.layer.borderColor=[[Utils colorWithHexString:@"#39B9F8"] CGColor];
    [self addSubview:weekchoice];
    [weekchoice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(225, 33));
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self).offset(39);
    }];
    UIView *verticallin1 = [[UIView alloc]init];
    verticallin1.backgroundColor = [Utils colorWithHexString:@"#39B9F8"];
    [weekchoice addSubview:verticallin1];
    [verticallin1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(1, 33));
        make.left.equalTo(weekchoice.mas_left).offset(75);
        make.top.equalTo(weekchoice.mas_top);
    }];
    UIView *verticallin2 = [[UIView alloc]init];
    verticallin2.backgroundColor = [Utils colorWithHexString:@"#39B9F8"];
    [weekchoice addSubview:verticallin2];
    [verticallin2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(1, 33));
        make.left.equalTo(verticallin1.mas_left).offset(75);
        make.top.equalTo(weekchoice.mas_top);
    }];
    
    UIButton *singleweek = [[UIButton alloc] init];
    _singleweek = singleweek;
    [_singleweek setTitle:@"单周" forState:UIControlStateNormal];
    [_singleweek setTitleColor:[Utils colorWithHexString:@"#39B9F8"] forState:UIControlStateNormal];
    [_singleweek setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    _singleweek.titleLabel.font = [UIFont systemFontOfSize:17.0];
    _singleweek.tag = 111;
    [_singleweek addTarget:self action:@selector(weekchoicebtnclick:) forControlEvents:UIControlEventTouchUpInside];
    [_singleweek setBackgroundImage:[UIImage imageNamed:@"单双周"] forState:UIControlStateSelected];
    [weekchoice addSubview:_singleweek];
    [_singleweek mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(75, 33));
        make.left.equalTo(weekchoice.mas_left);
        make.top.equalTo(weekchoice.mas_top);
    }];
    
    UIButton *doubleweek = [[UIButton alloc] init];
    _doubleweek = doubleweek;
    [doubleweek setTitle:@"双周" forState:UIControlStateNormal];
    [doubleweek setTitleColor:[Utils colorWithHexString:@"#39B9F8"] forState:UIControlStateNormal];
    [doubleweek setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    doubleweek.titleLabel.font = [UIFont systemFontOfSize:17.0];
    doubleweek.tag = 222;
    [doubleweek addTarget:self action:@selector(weekchoicebtnclick:) forControlEvents:UIControlEventTouchUpInside];
    [doubleweek setBackgroundImage:[UIImage imageNamed:@"单双周"] forState:UIControlStateSelected];
    [weekchoice addSubview:doubleweek];
    [doubleweek mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(75, 33));
        make.left.equalTo(singleweek.mas_right);
        make.top.equalTo(weekchoice.mas_top);
    }];
    
    UIButton *allweek = [[UIButton alloc] init];
    _allweek=allweek;
    [allweek setTitle:@"全选" forState:UIControlStateNormal];
    [allweek setTitleColor:[Utils colorWithHexString:@"#39B9F8"] forState:UIControlStateNormal];
    [allweek setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    allweek.titleLabel.font = [UIFont systemFontOfSize:17.0];
    allweek.tag = 333;
    [allweek addTarget:self action:@selector(weekchoicebtnclick:) forControlEvents:UIControlEventTouchUpInside];
    [allweek setBackgroundImage:[UIImage imageNamed:@"单双周"] forState:UIControlStateSelected];
    [weekchoice addSubview:allweek];
    [allweek mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(75, 33));
        make.left.equalTo(doubleweek.mas_right);
        make.top.equalTo(weekchoice.mas_top);
    }];
}

//--------------------------------装周数选择按钮的容器view------------------------------------------
-(void)setWeekBtn:(NSArray *)showweek{
    UIView *btnview = [[UIView alloc] init];
    btnview.backgroundColor = [UIColor clearColor];
    [self addSubview:btnview];
    [btnview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(_singleweek.mas_bottom).offset(25);
        make.width.mas_equalTo(marginX*5+weeknumwidth*6);
        make.height.mas_equalTo(marginY*3+weeknumwidth*4);
    }];
    
    //添加周数选择button
    self.weekselected_array = [NSMutableArray array];
    for(int i=0 ; i< 4 ; i++){
        for(int j = 0; j<6 ;j++){
            UIButton *weekbtn = [[UIButton alloc] initWithFrame:CGRectMake(j*(marginX+weeknumwidth), i*(marginY+weeknumwidth), weeknumwidth, weeknumwidth)];
            weekbtn.titleLabel.font = [UIFont systemFontOfSize:14];
            [weekbtn setTitle:[NSString stringWithFormat:@"%i",i*6+j+1] forState:UIControlStateNormal];
            [weekbtn setTitleColor:[Utils colorWithHexString:@"#666666"] forState:UIControlStateNormal];
            [weekbtn setTitleColor:[Utils colorWithHexString:@"#FFFFFF"] forState:UIControlStateSelected];
            [weekbtn setBackgroundImage:[UIImage imageNamed:@"btnBG"] forState:UIControlStateSelected];
            [weekbtn addTarget:self action:@selector(btnselected:) forControlEvents:UIControlEventTouchUpInside];
            weekbtn.tag = i*6+j;//btn title和btn tag数值上相差1
            [_weekselected_array addObject:weekbtn];
            if([showweek containsObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:weekbtn.tag]]]){//在数组里
                weekbtn.selected = YES;
            }
            [btnview addSubview:weekbtn];
        }
    }
    [self segmentSelect];
}

//-----------------------------------添加底部取消确认按钮-----------------------------------------
-(void)CancelComfirmBtnSetting{
    UIView *line1 = [[UIView alloc] init];//横线
    line1.backgroundColor = [Utils colorWithHexString:@"#D9D9D9"];
    [self addSubview: line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.mas_width);
        make.height.mas_equalTo(0.5);
        make.centerX.equalTo(self.mas_centerX);
        make.bottom.equalTo(self.mas_bottom).offset(-39);
    }];
    
    UIView *line2 = [[UIView alloc] init];//竖线
    line2.backgroundColor = [Utils colorWithHexString:@"#D9D9D9"];
    [self addSubview: line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0.5);
        make.height.mas_equalTo(39);
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
        make.height.mas_equalTo(39);
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
        make.height.mas_equalTo(39);
        make.width.mas_equalTo(self.frame.size.width/2);
        make.left.equalTo(line2.mas_right);
        make.top.equalTo(line1.mas_bottom);
    }];
    
    [_confirm_btn addTarget:self action:@selector(weekselectconfirm) forControlEvents:UIControlEventTouchUpInside];
    [_cancel_btn addTarget:self action:@selector(weekselectcancel) forControlEvents:UIControlEventTouchUpInside];
}

-(void)btnselected:(id)sender{
    UIButton *selected_btn = (UIButton *)sender;
    selected_btn.selected = !selected_btn.selected;
    _allweek.selected = NO;
    _singleweek.selected = NO;
    _doubleweek.selected = NO;
    [self segmentSelect];
}

- (void)segmentSelect{
    //扫描是否单周 双周 全选
    NSMutableArray *selectresult = [NSMutableArray array];
    for(UIButton *everyone_Btn in _weekselected_array){
        if(everyone_Btn.selected)
            [selectresult addObject:everyone_Btn.titleLabel.text];//btn title和btn tag数值上相差1
    }
    if(selectresult.count == _weekselected_array.count)//全选了
        _allweek.selected = YES;
    if(selectresult.count == _weekselected_array.count/2){
        //选中全部的单周或者全部的双周
        int firstelement = [[NSString stringWithString:selectresult[0]] intValue];
        int time=0;
        if(firstelement % 2 == 1){
            for(NSString *selectWeek in selectresult){
                if(selectWeek.intValue % 2 == 1)
                    time++;
            }
            if(time == selectresult.count)
                _singleweek.selected = YES;
        }
        time = 0 ;
        if(firstelement % 2 == 0){
            for(NSString *selectWeek in selectresult){
                if(selectWeek.intValue % 2 == 0)
                    time++;
            }
            if(time == selectresult.count)
                _doubleweek.selected = YES;
        }
    }
}

//单击 单周 双周 全选 按钮后的处理
-(void)weekchoicebtnclick:(id)sender
{
    //原来哪一个选择中状态的
    UIButton *selectedbtn = [[UIButton alloc] init];
    if(_singleweek.selected) selectedbtn = _singleweek;
    if(_doubleweek.selected) selectedbtn = _doubleweek;
    if(_allweek.selected) selectedbtn = _allweek;
    
    UIButton *choice_btn = (UIButton *)sender;
    for(int i = 0;i<_weekselected_array.count;i++){
        UIButton *btn = _weekselected_array[i];
        btn.selected = NO;
    }
    
    //点击一个已经选取状态下的按钮
    if(choice_btn.tag == selectedbtn.tag){
        choice_btn.selected = NO;
    }else{
        _singleweek.selected=NO;
        _doubleweek.selected=NO;
        _allweek.selected=NO;
        choice_btn.selected = YES;
        switch (choice_btn.tag) {
            case 111:
                //singleweek
                for(int i = 0; i < 24;){
                    UIButton *btn = _weekselected_array[i];
                    btn.selected = YES;
                    i += 2;
                }
                break;
            case 222:
                //doubleweek
                for(int i = 1;i<24;){
                    UIButton *btn = _weekselected_array[i];
                    btn.selected = YES;
                    i += 2;
                }
                break;
            case 333:
                //allweek
                for(int i = 0;i<24;i++){
                    UIButton *btn = _weekselected_array[i];
                    btn.selected = YES;
                }
                break;
        }
    }
}

-(void)weekselectcancel{
    [self.delegate weekSelectCancelAction:self];
    [self removeFromSuperview];
}

-(void)weekselectconfirm{
    self.selectResult = [NSMutableArray array];
    for(UIButton *btn in _weekselected_array){
        if(btn.selected == YES){
            [_selectResult addObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:btn.tag]]];
        }
    }
    if([_delegate respondsToSelector:@selector(setWeekSelectResult:inSection:)]){
        [_delegate setWeekSelectResult:_selectResult inSection:self.whichSection];
    }
    [self removeFromSuperview];
}
@end
