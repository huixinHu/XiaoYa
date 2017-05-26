//
//  CourseModel.m
//  XiaoYa
//
//  Created by commet on 16/10/31.
//  Copyright © 2016年 commet. All rights reserved.
//

#import "CourseModel.h"
#import "NSDate+Calendar.h"
@implementation CourseModel
- (id)initWithDict:(NSDictionary *)dic
{
    if (self = [super init]) {
        if (dic != nil) {
//            self.dataid = [dic objectForKey:@"id"];
            self.weeks = [dic objectForKey:@"weeks"];
            self.weekday = [dic objectForKey:@"weekday"];
            self.time = [dic objectForKey:@"time"];
            self.courseName = [dic objectForKey:@"courseName"];
            self.place = [dic objectForKey:@"place"];
            
            self.timeArray = [NSMutableArray array];
            if (self.time.length != 0) {
                NSString *subTimeStr = [self.time substringWithRange:NSMakeRange(1, self.time.length - 2)];//截去头尾“,”
                NSArray * tempArray = [subTimeStr componentsSeparatedByString:@","];//以“,”切割
                self.timeArray = [tempArray mutableCopy];
            }

            self.weekArray = [[[self.weeks substringWithRange:NSMakeRange(1, self.weeks.length - 2)] componentsSeparatedByString:@","]mutableCopy];
            self.intersects = NO;
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone{
    CourseModel *model = [[CourseModel alloc]init];
    model.weeks = self.weeks;
    model.weekday = self.weekday;
    model.time = self.time;
    model.courseName = self.courseName;
    model.place = self.place;
    model.weekArray = self.weekArray;
    model.timeArray = self.timeArray;
    return model;
}

+ (instancetype)defaultModel{//是否用instanceType?
    NSMutableDictionary *modelDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"",@"time",@",0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,",@"weeks",@"0",@"weekday",@"",@"courseName",@"",@"place",nil];
    CourseModel *defaultModel = [[CourseModel alloc]initWithDict:modelDict];
    int weekday = [[NSDate date]dayOfWeek];//1是周日，2是周一 ==>转成0-6，0是周一
    if (weekday == 1) {
        weekday =6;
    }else{
        weekday = weekday - 2;
    }
    defaultModel.weekday = [NSString stringWithFormat:@"%d",weekday];
    return defaultModel;
}

//检查冲突
- (BOOL)checkIfConflictComparetoAnotherCourseModel:(CourseModel *)courseModel
{
    if(![self.weekday isEqualToString: courseModel.weekday]) return NO;
    
    NSMutableSet *weeksSet = [[NSMutableSet alloc] init];
    [weeksSet addObjectsFromArray:self.weekArray];
    [weeksSet addObjectsFromArray:courseModel.weekArray];
    if(weeksSet.count == (_weekArray.count + courseModel.weekArray.count)) return NO;
    
    NSMutableSet *courseTimeSet = [[NSMutableSet alloc] init];
    [courseTimeSet addObjectsFromArray:_timeArray];
    [courseTimeSet addObjectsFromArray:courseModel.timeArray];
    if(courseTimeSet.count == (_timeArray.count + courseModel.timeArray.count)) return NO;
    
    return YES;
}
@end
