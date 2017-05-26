//
//  RemindSelect.h
//  XiaoYa
//
//  Created by commet on 16/11/30.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RemindSelect;
@protocol RemindSelectDelegate<NSObject>

//确认操作。
- (void)RemindSelectComfirmAction:(RemindSelect *)sectionSelector indexArr:(NSMutableArray *)indexArray;
//取消
- (void)RemindSelectCancelAction:(RemindSelect *)sectionSelector;
@end

@interface RemindSelect : UIView

@property (nonatomic ,weak) id <RemindSelectDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame selectedIndex:(NSArray *)indexsArray;
@end
