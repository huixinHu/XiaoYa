//
//  UIAlertController+Appearance.m
//  XiaoYa
//
//  Created by commet on 17/2/14.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "UIAlertController+Appearance.h"
#import "Utils.h"
#import "UILabel+AlertActionFont.h"
@implementation UIAlertController (Appearance)

//提示框按钮样式设置
- (void)addActionTarget:(UIAlertAction*)action hexColor:(NSString *)color{
    [action setValue:[Utils colorWithHexString:color] forKey:@"titleTextColor"];
    [self addAction:action];
}

//提示框title样式设置
- (void)alertTitleAppearance_title:(NSString *)title hexColor:(NSString *)color{
    NSInteger length = [title length];
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:title];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[Utils colorWithHexString:color] range:NSMakeRange(0, length - 1)];
    [self setValue:alertControllerStr forKey:@"attributedTitle"];
}
//提示框Message样式设置
- (void)alertMessageAppearance_message:(NSString *)message hexColor:(NSString *)color{
    NSInteger length = [message length];
    NSMutableAttributedString *alertControllerStr = [[NSMutableAttributedString alloc] initWithString:message];
    [alertControllerStr addAttribute:NSForegroundColorAttributeName value:[Utils colorWithHexString:color] range:NSMakeRange(0, length - 1)];
    [self setValue:alertControllerStr forKey:@"attributedMessage"];
}

+ (UIAlertController *)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle cancelTitle:(NSString *)cancelTitle cancelBlock:(void (^ __nullable)(UIAlertAction *action))cancelHandler otherTitles:(NSArray *)otherTitles otherBlocks:(NSArray *)otherBlocks{

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    [alert alertTitleAppearance_title:title hexColor:@"#333333"];
    [alert alertMessageAppearance_message:message hexColor:@"#333333"];
    if (cancelTitle != nil) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:cancelHandler];
        [alert addActionTarget:cancelAction hexColor:@"#00A7FA"];
    }
    if (otherTitles != nil && otherTitles.count <= otherBlocks.count) {
        for (int i = 0; i < otherTitles.count; i++) {
            UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherTitles[i] style:UIAlertActionStyleDefault handler:otherBlocks[i]];
            [alert addActionTarget:otherAction hexColor:@"#00A7FA"];
        }
    }
    UILabel *appearanceLabel = [UILabel appearanceWhenContainedIn:UIAlertController.class, nil];
    UIFont *font = [UIFont systemFontOfSize:13];
    [appearanceLabel setAppearanceFont:font];
    return alert;
}
@end
