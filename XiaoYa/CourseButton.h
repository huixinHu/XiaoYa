//
//  CourseButton.h
//  XiaoYa
//
//  Created by commet on 16/11/1.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseButton : UIButton
@property (nonatomic , weak)UILabel *event;//事件
@property (nonatomic , weak)UILabel *place;//地点
@property (nonatomic , assign)BOOL isOverlap;//课程、事务是否重合的标记，决定背景图片是啥
@property (nonatomic ,strong) NSMutableArray *courseArray;
@property (nonatomic ,strong) NSMutableArray *businessArray;
@property (nonatomic ,assign) NSInteger type;//类型，事务还是课程，事务是0，课程是1
- (instancetype)initWithCourseArray:(NSArray *)courseArr businessArray:(NSArray *)businessArr btntype:(int)type;
@end
