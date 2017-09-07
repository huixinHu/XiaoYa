//
//  SectionSchedule.h
//  XiaoYa
//
//  Created by commet on 2017/9/5.
//  Copyright © 2017年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^confirmBlock)(void);

@interface SectionSchedule : UIView

- (instancetype)initWithFrame:(CGRect)frame selectedDate:(NSDate*)date confirmBlock:(confirmBlock)confirm;
@end
