//
//  CourseModel.h
//  XiaoYa
//
//  Created by commet on 16/10/31.
//  Copyright © 2016年 commet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CourseModel : NSObject<NSCopying>

//@property (nonatomic, copy)   NSString *dataid;
@property (nonatomic, copy)   NSString *weeks;                //周数，字符串”，0，1，2，3...“
@property (nonatomic, copy)   NSString *weekday;              //周几,0-6,0为周一
@property (nonatomic ,copy)   NSString *time;                 //时间，第几节 “，1，2，3...”
@property (nonatomic, copy)   NSString *courseName;           //课程名称
@property (nonatomic, copy)   NSString *place;                //上课地点
@property (nonatomic ,strong) NSMutableArray *timeArray;      //把time string转化成array
@property (nonatomic ,strong) NSMutableArray *weekArray;//把weeks string转化成array

@property (nonatomic ,assign) BOOL intersects;//是否和事务有交集

- (id)initWithDict:(NSDictionary *)dic;
+ (instancetype)defaultModel;
- (BOOL)checkIfConflictComparetoAnotherCourseModel:(CourseModel *)courseModel;

@end
