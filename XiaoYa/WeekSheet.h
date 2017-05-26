//
//  WeekSheet.h
//  XiaoYa
//
//  Created by commet on 16/10/11.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WeekSheet;
@protocol WeekSheetDelegate <NSObject>
@required
- (void)refreshNavItemTitle:(WeekSheet *)weeksheet content:(NSInteger)weekSheetRow;

@end


@interface WeekSheet : UIView
@property (nonatomic , weak) id<WeekSheetDelegate> delegate;

@end
