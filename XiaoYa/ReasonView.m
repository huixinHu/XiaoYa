//
//  ReasonView.m
//  XiaoYa
//
//  Created by commet on 2017/8/1.
//  Copyright © 2017年 commet. All rights reserved.
//输入不参加的原因

#import "ReasonView.h"
#import "Masonry.h"
#import "Utils.h"
#import "HXTextField.h"
@interface ReasonView()
@property (nonatomic , weak) HXTextField *txf;
@property (nonatomic , weak) UIButton *confirm;
@property (nonatomic , weak) UIButton *cancel;
@property (nonatomic , copy) void(^cancelBlock)();
@property (nonatomic , copy) void(^confirmBlock)(NSString *reason);
@end

@implementation ReasonView

- (instancetype)initWithCancelBlock:(void (^)())cancelBlock confirmBlock:(void (^)(NSString *reason))confirmBlock{
    if (self = [super initWithFrame:CGRectMake(0, 0, 250, 118)]) {
        [self commonInit];
        self.confirmBlock = confirmBlock;
        self.cancelBlock = cancelBlock;
    }
    return self;
}

- (void)cancelAction{
    self.cancelBlock();
}

- (void)confirmAction{
    self.confirmBlock(self.txf.text);
}

- (void)commonInit{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 10.0;
    
    UIImageView *head = [self drawHeader];
    [self addSubview:head];
    [head mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.top.centerX.equalTo(self);
        make.height.equalTo(@40);
    }];
    
    UILabel *headText = [[UILabel alloc]init];
    headText.text = @"请输入原因";
    headText.textColor = [UIColor whiteColor];
    headText.font = [UIFont systemFontOfSize:17.0];
    [head addSubview:headText];
    [headText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(head);
    }];
    UIView *line1 = [[UIView alloc]init];
    line1.backgroundColor = [Utils colorWithHexString:@"#d9d9d9"];
    [self addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.centerX.equalTo(self);
        make.height.mas_equalTo(0.5);
        make.bottom.equalTo(self).offset(-40);
    }];
    UIView *line2 = [[UIView alloc]init];
    line2.backgroundColor = [Utils colorWithHexString:@"#d9d9d9"];
    [self addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(0.5, 40));
        make.centerX.bottom.equalTo(self);
    }];
    
    HXTextField *txf = [[HXTextField alloc]init];
    _txf = txf;
    UIView *lv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 10)];
    [_txf appearanceWithTextColor:[Utils colorWithHexString:@"333333"] textFontSize:13.0 placeHolderColor:[Utils colorWithHexString:@"#d9d9d9"] placeHolderFontSize:13.0 placeHolderText:@"请输入您的原因" leftView:lv];
    [self addSubview:_txf];
    [_txf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(head.mas_bottom);
        make.bottom.equalTo(line1.mas_top);
        make.left.right.equalTo(self);
    }];
    
    UIButton *cancel = [[UIButton alloc]init];
    _cancel = cancel;
    [_cancel setTitle:@"取消" forState:UIControlStateNormal];
    [_cancel setTitleColor:[Utils colorWithHexString:@"#00a7fa"] forState:UIControlStateNormal];
    _cancel.titleLabel.font = [UIFont systemFontOfSize:13.0];
    _cancel.backgroundColor = [UIColor whiteColor];
    _cancel.layer.cornerRadius = 10.0;
    [_cancel addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancel];
    [_cancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(self);
        make.right.equalTo(line2.mas_left);
        make.top.equalTo(line1.mas_bottom);
    }];
    
    UIButton *confirm = [[UIButton alloc]init];
    _confirm = confirm;
    [_confirm setTitle:@"确认" forState:UIControlStateNormal];
    [_confirm setTitleColor:[Utils colorWithHexString:@"#00a7fa"] forState:UIControlStateNormal];
    _confirm.titleLabel.font = [UIFont systemFontOfSize:13.0];
    _confirm.backgroundColor = [UIColor whiteColor];
    _confirm.layer.cornerRadius = 10.0;
    [_confirm addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_confirm];
    [_confirm mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(self);
        make.left.equalTo(line2.mas_right);
        make.top.equalTo(line1.mas_bottom);
    }];
}

- (UIImageView *)drawHeader{
    CGFloat width = 250;
    CGFloat height = 40;
    CGFloat radius = 10;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath*path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, width, height) byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(radius, radius)];
    [path closePath];
    UIColor *fillColor = [Utils colorWithHexString:@"00a7fa"];
    [fillColor set];
    [path fill];
    
    CGContextAddPath(ctx, path.CGPath);
    UIImageView *imgView = [[UIImageView alloc]initWithImage:UIGraphicsGetImageFromCurrentImageContext()];
    UIGraphicsEndImageContext();
    return imgView;
}

//- (void)dealloc{
//    NSLog(@"reasonView dealloc");
//}
@end
