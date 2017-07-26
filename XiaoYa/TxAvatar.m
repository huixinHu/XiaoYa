//
//  TxAvatar.m
//  XiaoYa
//
//  Created by commet on 2017/7/26.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "TxAvatar.h"
#import "Utils.h"
@implementation TxAvatar
static TxAvatar *_instance;

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance;
}

+ (UIImage *)avatarWithText:(NSString *)text fontSize:(CGFloat)fz longside:(CGFloat )ls{
    TxAvatar *txAvatar = [TxAvatar shareInstance];
    return [txAvatar avatarWithText:text fontSize:fz longside:ls];
}

- (UIImage *)avatarWithText:(NSString *)text fontSize:(CGFloat)fz longside:(CGFloat )ls{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(ls, ls), NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //绘制背景
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, ls, ls)];
    UIColor *fillColor = [Utils colorWithHexString:@"#f2f2f2"];
    [fillColor set];
    [path fill];
    CGContextAddPath(ctx, path.CGPath);
    //绘制文字
    NSDictionary *attrs = @{NSForegroundColorAttributeName :[Utils colorWithHexString:@"#00a7fa"] ,NSFontAttributeName :[UIFont systemFontOfSize:fz]};
    //计算文字的size
    CGSize size = [text boundingRectWithSize:CGSizeMake(ls, ls) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
//    NSString *avaText = [NSString string];
//    if (text.length > 2) {
//        avaText = [text substringWithRange:NSMakeRange(text.length - 2, 2)];
//    }else{
//        avaText = text;
//    }
    [text drawAtPoint:CGPointMake((ls-size.width)/2, (ls-size.height)/2) withAttributes:attrs];
    
    UIImage *getImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return getImage;
}


@end
