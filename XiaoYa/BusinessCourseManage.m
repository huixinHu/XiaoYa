//
//  BusinessCourseManage.m
//  XiaoYa
//
//  Created by commet on 16/11/28.
//  Copyright © 2016年 commet. All rights reserved.
//

#import "BusinessCourseManage.h"
#import "BusinessViewController.h"
#import "CourseViewController.h"
#import "Utils.h"
#import "Masonry.h"
#import "UILabel+AlertActionFont.h"
#import <objc/runtime.h>
#import "DbManager.h"
#import "DateUtils.h"
#import "NSDate+Calendar.h"
#import "UIAlertController+Appearance.h"
#import "CourseModel.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
@interface BusinessCourseManage ()<UIScrollViewDelegate>
@property (nonatomic ,weak)UISegmentedControl *segCtrl;
@property (nonatomic ,weak)UIScrollView *mainScrollView;

@property (nonatomic ,strong)NSArray *controllersArray;//子控制器数组
@property (nonatomic ,strong)NSDate *firstDateOfTerm;
@property (nonatomic ,strong)BusinessViewController *bsVc;
@property (nonatomic ,strong)CourseViewController *courseVc;

@end

@implementation BusinessCourseManage

- (instancetype)initWithControllersArray:(NSArray *)controllersArray firstDateOfTerm:(NSDate *)firstDateOfTerm{
    if(self = [super init]){
        self.controllersArray = [controllersArray mutableCopy];
        self.firstDateOfTerm = firstDateOfTerm;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self initViews];
    [self setupChildViewControllers];
    _bsVc = self.controllersArray[0];
    _courseVc = self.controllersArray[1];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"confirm"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(confirm)];
//    self.navigationItem.rightBarButtonItem.enabled = NO;//在编辑框有输入时才允许点击
    UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightBtn setImage:[UIImage imageNamed:@"confirm"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"cancel"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
}

//课程和事务公用这两个按钮
- (void)confirm{
    if (_segCtrl.selectedSegmentIndex == 0) {//如果是事务界面。在这个类文件里面执行的，都是直接插入数据而不是修改原有数据的
        [_bsVc dataStore];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            DbManager *dbManger = [DbManager shareInstance];
//            NSInteger dateDistance = [DateUtils dateDistanceFromDate:_bsVc.currentDate toDate:self.firstDateOfTerm];
//            NSInteger week = dateDistance / 7;//存入数据库的week从0-n；
//            //储存往后五年的时间
//            NSMutableArray *dateString = [Utils dateStringArrayFromDate:_bsVc.currentDate yearDuration:5 repeatIndex:_bsVc.repeatIndex];
//            //修改覆盖数据
//            if (_bsVc.sectionArray.count > 0) {
////                找出将要被覆盖的事务
//                NSMutableString *sqlTime = [NSMutableString string];
//                for (int i = 0; i < _bsVc.sectionArray.count; i++) {
//                    [sqlTime appendString:[NSString stringWithFormat:@"time LIKE '%%,%d,%%' or ",[_bsVc.sectionArray[i] intValue]]];
//                }
//                sqlTime = (NSMutableString*)[sqlTime substringToIndex:sqlTime.length - 3];
//                //往后五年的每一条数据都要拿出来剔除覆盖
//                for (int i = 0; i < dateString.count; i ++) {
//                    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_201601 WHERE date = '%@' and (%@);",dateString[i],sqlTime];
//                    NSArray *dataQuery = [dbManger executeQuery:sql];
//                    if (dataQuery.count > 0) {
//                        for (int j = 0; j < dataQuery.count ; j++) {
//                            //转换成模型
//                            NSMutableDictionary *busDict = [NSMutableDictionary dictionaryWithDictionary:dataQuery[j]];
//                            BusinessModel *model = [[BusinessModel alloc] initWithDict:busDict];
//                            //每条事务数据，删去重复的时间段（被覆盖掉了）得到新的事务时间段
//                            NSMutableArray *tempArray = [model.timeArray mutableCopy];
//                            for (int k = 0 ; k < _bsVc.sectionArray.count; k++) {
//                                if ([tempArray containsObject:_bsVc.sectionArray[k]]) {
//                                    [tempArray removeObject:_bsVc.sectionArray[k]];
//                                }
//                            }
//                            if (tempArray.count != 0) {//tempArray.count=0意味着现事务把原事务整个都覆盖掉了，所以原事务直接删
//                                //对新的事务节数时间段进行连续性分割
//                                NSMutableArray *sections = [Utils subSectionArraysFromArray:tempArray];
//                                //然后插入更新后的事务
//                                [dbManger beginTransaction];
//                                for (int k = 0; k < sections.count; k++) {
//                                    NSMutableArray *newSection = sections[k];
//                                    NSString *newTimeStr = [self appendStringWithArray:newSection];
//                                    NSString *sql = [NSString stringWithFormat:@"INSERT INTO t_201601 (description,comment,date,time,repeat) VALUES ('%@','%@','%@','%@',6);",model.desc,model.comment,dateString[i],newTimeStr];//一律改成不重复
//                                    [dbManger executeNonQuery:sql];
//                                }
//                                [dbManger commitTransaction];
//                            }
//                        }
//                        //删除旧的事务数据
//                        NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM t_201601 WHERE date = '%@' and (%@);",dateString[i],sqlTime];
//                        [dbManger executeNonQuery:deleteSql];
//                    }
//                }
//            }
//            
//            //插入新事务
//            [dbManger beginTransaction];
//            NSInteger timeArrCount = [_bsVc.sections count];
//            for (int i = 0; i <timeArrCount; i ++) {
//                NSMutableArray *section = _bsVc.sections[i];
//                NSString *timeStr = [self appendStringWithArray:section];
//                for (int k = 0; k < dateString.count; k ++) {
//                    NSString *sql = [NSString stringWithFormat:@"INSERT INTO t_201601 (description,comment,date,time,repeat) VALUES ('%@','%@','%@','%@',%ld);",_bsVc.busDescription.text,_bsVc.commentInfo,dateString[k],timeStr,_bsVc.repeatIndex];//注意VALUES字符串赋值要有单引号
//                    [dbManger executeNonQuery:sql];
//                }
//            }
//            [dbManger commitTransaction];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.delegate BusinessCourseManage:self week:week];
//                [self.navigationController popViewControllerAnimated:YES];
//            });
//        });
    }else{//如果是课程界面
        [_courseVc dataStore];
//        if([self checkIfConflict]){
//            void (^otherBlock)(UIAlertAction *action) = ^(UIAlertAction *action){
//            };
//            NSArray *otherBlocks = @[otherBlock];
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"课程时间冲突" preferredStyle:UIAlertControllerStyleAlert cancelTitle:nil cancelBlock:nil otherTitles:@[@"确定"] otherBlocks:otherBlocks];
//            [self presentViewController:alert animated:YES completion:nil];
//        }else{
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                DbManager *dbManger = [DbManager shareInstance];
//                //1.先修改被覆盖的数据
//                for (int i = 0; i < _courseVc.courseview_array.count; i++) {
//                    CourseModel *courseModel = _courseVc.courseview_array[i];
//                    NSMutableString *sqlweek = [NSMutableString string];
//                    NSMutableString *sqlTime = [NSMutableString string];
//                    for (int j = 0; j < courseModel.weekArray.count; j++) {
//                        [sqlweek appendString:[NSString stringWithFormat:@"weeks LIKE '%%,%@,%%' or ",courseModel.weekArray[j]]];
//                    }
//                    sqlweek = (NSMutableString*)[sqlweek substringToIndex:sqlweek.length - 3];
//                    for (int j = 0; j < courseModel.timeArray.count; j++) {
//                        [sqlTime appendString:[NSString stringWithFormat:@"time LIKE '%%,%@,%%' or ",courseModel.timeArray[j]]];
//                    }
//                    sqlTime = (NSMutableString*)[sqlTime substringToIndex:sqlTime.length - 3];
//                    
//                    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM course_table WHERE weekday = '%@' and (%@) and (%@);",courseModel.weekday,sqlweek,sqlTime];
//                    NSArray *dataQuery = [dbManger executeQuery:sql];//查找出重合数据
//                    if (dataQuery.count > 0) {
//                        for (int j = 0; j < dataQuery.count ; j++) {
//                            NSMutableDictionary *courseDict = [NSMutableDictionary dictionaryWithDictionary:dataQuery[j]];
//                            CourseModel *newModel = [[CourseModel alloc] initWithDict:courseDict];
//                            //每条课程数据，删去重复的时间段（被覆盖掉了）得到新的课程时间段
//                            //节数
//                            NSMutableArray *newTimeArray = [newModel.timeArray mutableCopy];
//                            for (int k = 0 ; k < courseModel.timeArray.count; k++) {
//                                if ([newTimeArray containsObject:courseModel.timeArray[k]]) {
//                                    [newTimeArray removeObject:courseModel.timeArray[k]];
//                                }
//                            }
//                            //周数
//                            NSMutableArray *newWeekArray1 = [newModel.weekArray mutableCopy];//没被覆盖的部分，有可能是空
//                            NSMutableArray *newWeekarray2 = [NSMutableArray array];//被覆盖的部分,一定非空
//                            for (int k = 0; k < courseModel.weekArray.count; k++) {
//                                if ([newWeekArray1 containsObject:courseModel.weekArray[k]]) {
//                                    [newWeekArray1 removeObject:courseModel.weekArray[k]];
//                                    [newWeekarray2 addObject:courseModel.weekArray[k]];
//                                }
//                            }
//                            
//                            if (newWeekArray1.count == 0) {//周数全覆盖
//                                if (newTimeArray.count != 0) {//newTimeArray.count=0意味着现课程把原课程节数都覆盖掉了，所以原课程直接删
//                                    NSString *newWeekStr2 = [self appendStringWithArray:newWeekarray2];
//                                    //对新的课程节数时间段进行连续性分割
//                                    NSMutableArray *sections = [Utils subSectionArraysFromArray:newTimeArray];
//                                    //然后插入更新后周数覆盖部分的课程
//                                    [dbManger beginTransaction];
//                                    for (int k = 0; k < sections.count; k++) {
//                                        NSMutableArray *newSection = sections[k];
//                                        NSString *newTimeStr = [self appendStringWithArray:newSection];
//                                        NSString *sql = [NSString stringWithFormat:@"INSERT INTO course_table (courseName,weeks,weekday,time,place) VALUES ('%@','%@','%@','%@','%@');",newModel.courseName,newWeekStr2,newModel.weekday,newTimeStr,newModel.place];
//                                        [dbManger executeNonQuery:sql];
//                                    }
//                                    [dbManger commitTransaction];
//                                }
//                            }else{//周数不全覆盖
//                                NSString *newWeekStr1 = [self appendStringWithArray:newWeekArray1];
//                                //1.对周数没有覆盖的部分：
//                                NSString *sql = [NSString stringWithFormat:@"INSERT INTO course_table (courseName,weeks,weekday,time,place) VALUES ('%@','%@','%@','%@','%@');",newModel.courseName,newWeekStr1,newModel.weekday,newModel.time,newModel.place];
//                                [dbManger executeNonQuery:sql];
//                                //2.对周数覆盖的部分：
//                                if (newTimeArray.count != 0) {
//                                    NSString *newWeekStr2 = [self appendStringWithArray:newWeekarray2];
//                                    //对新的课程节数时间段进行连续性分割
//                                    NSMutableArray *sections = [Utils subSectionArraysFromArray:newTimeArray];
//                                    //然后插入更新后周数覆盖部分的课程
//                                    [dbManger beginTransaction];
//                                    for (int k = 0; k < sections.count; k++) {
//                                        NSMutableArray *newSection = sections[k];
//                                        NSString *newTimeStr = [self appendStringWithArray:newSection];
//                                        NSString *sql = [NSString stringWithFormat:@"INSERT INTO course_table (courseName,weeks,weekday,time,place) VALUES ('%@','%@','%@','%@','%@');",newModel.courseName,newWeekStr2,newModel.weekday,newTimeStr,newModel.place];
//                                        [dbManger executeNonQuery:sql];
//                                    }
//                                    [dbManger commitTransaction];
//                                }
//                            }
//                            
//    //                        NSString *newWeekStr1 = [self appendStringWithArray:newWeekArray1];
//    //                        //插入更新后的没被覆盖的部分(只更改了周数)
//    //                        NSString *sql = [NSString stringWithFormat:@"INSERT INTO course_table (courseName,weeks,weekday,time,place) VALUES ('%@','%@','%@','%@','%@');",newModel.courseName,newWeekStr1,newModel.weekday,newModel.time,newModel.place];
//    //                        [dbManger executeNonQuery:sql];
//    //                        
//    //                        if (newTimeArray.count != 0) {//newTimeArray.count=0意味着现课程把原课程整个都覆盖掉了，所以原课程直接删
//    //                            NSString *newWeekStr2 = [self appendStringWithArray:newWeekarray2];
//    //                            //对新的课程节数时间段进行连续性分割
//    //                            NSMutableArray *sections = [Utils subSectionArraysFromArray:newTimeArray];
//    //                            //然后插入更新后周数覆盖部分的课程
//    //                            [dbManger beginTransaction];
//    //                            for (int k = 0; k < sections.count; k++) {
//    //                                NSMutableArray *newSection = sections[k];
//    //                                NSString *newTimeStr = [self appendStringWithArray:newSection];
//    //                                NSString *sql = [NSString stringWithFormat:@"INSERT INTO course_table (courseName,weeks,weekday,time,place) VALUES ('%@','%@','%@','%@','%@');",newModel.courseName,newWeekStr2,newModel.weekday,newTimeStr,newModel.place];
//    //                                [dbManger executeNonQuery:sql];
//    //                            }
//    //                            [dbManger commitTransaction];
//    //                        }
//                        }
//                        //删除旧的事务数据
//                        NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM course_table WHERE weekday = '%@' and (%@) and (%@);",courseModel.weekday,sqlweek,sqlTime];
//                        [dbManger executeNonQuery:deleteSql];
//                    }
//                    
//                    //插入新事务
//                    NSMutableArray *arr = [Utils subSectionArraysFromArray:courseModel.timeArray];
//                    NSString *weekstr = [self appendStringWithArray:courseModel.weekArray];
//                    [dbManger beginTransaction];
//                    for (int m = 0; m < arr.count; m ++) {
//                        NSMutableArray *section = arr[m];
//                        NSString *timeStr = [self appendStringWithArray:section];
//                        NSString *sql = [NSString stringWithFormat:@"INSERT INTO course_table (courseName,weeks,weekday,time,place) VALUES ('%@','%@','%@','%@','%@');",courseModel.courseName,weekstr,courseModel.weekday,timeStr,courseModel.place];//注意VALUES字符串赋值要有单引号
//                        [dbManger executeNonQuery:sql];
//                        
//                    }
//                    [dbManger commitTransaction];
//                }
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.navigationController popViewControllerAnimated:YES];
//                });
//            });
//        }
    }
}

- (void)cancel{
    if (_segCtrl.selectedSegmentIndex == 0) {//如果是事务界面
        if ([_bsVc.busDescription.text isEqualToString:@""] && _bsVc.sectionArray.count == 0) {
            [self.navigationController popViewControllerAnimated:YES];//返回主界面
        }else{
            void (^otherBlock)(UIAlertAction *action) = ^(UIAlertAction *action){
                [self.navigationController popViewControllerAnimated:YES];
            };
            NSArray *otherBlocks = @[otherBlock];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认退出？" message:@"一旦退出，编辑将不会保存" preferredStyle:UIAlertControllerStyleAlert cancelTitle:@"取消" cancelBlock:nil otherTitles:@[@"确定"] otherBlocks:otherBlocks];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }else{//如果是课程界面
        void (^otherBlock)(UIAlertAction *action) = ^(UIAlertAction *action){
            [self.navigationController popViewControllerAnimated:YES];
        };
        NSArray *otherBlocks = @[otherBlock];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认退出？" message:@"一旦退出，编辑将不会保存" preferredStyle:UIAlertControllerStyleAlert cancelTitle:@"取消" cancelBlock:nil otherTitles:@[@"确定"] otherBlocks:otherBlocks];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

//kvc 获取所有key值
- (NSArray *)getAllIvar:(id)object
{
    NSMutableArray *array = [NSMutableArray array];
    
    unsigned int count;
    Ivar *ivars = class_copyIvarList([object class], &count);
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        const char *keyChar = ivar_getName(ivar);
        NSString *keyStr = [NSString stringWithCString:keyChar encoding:NSUTF8StringEncoding];
        @try {
            id valueStr = [object valueForKey:keyStr];
            NSDictionary *dic = nil;
            if (valueStr) {
                dic = @{keyStr : valueStr};
            } else {
                dic = @{keyStr : @"值为nil"};
            }
            [array addObject:dic];
        }
        @catch (NSException *exception) {}
    }
    return [array copy];
}

//初始化视图
- (void)initViews{
    [self settingSegmentedControl];
    [self settingMainScrollView];
}

//初始化子控制器
- (void)setupChildViewControllers{
    for (UIViewController *vc in self.controllersArray) {
        [self addChildViewController:vc];
    }
}

//分段控件
- (void)settingSegmentedControl{
    UISegmentedControl *segCtrl = [[UISegmentedControl alloc]initWithItems:@[@"事务",@"课程"]];
    _segCtrl = segCtrl;
    _segCtrl.frame = CGRectMake(0, 0, 166, 30);
    _segCtrl.layer.masksToBounds = YES;
    _segCtrl.layer.cornerRadius = 0.1;
    _segCtrl.selectedSegmentIndex = 0;
    _segCtrl.tintColor = [Utils colorWithHexString:@"#00a7fa"];
    [_segCtrl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:17], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [_segCtrl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:17], NSFontAttributeName, nil] forState:UIControlStateSelected];
    
    [_segCtrl addTarget:self action:@selector(change:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = _segCtrl;
}

//点击不同分段有不同的事件响应
- (void)change:(UISegmentedControl *)sender
{
    CGPoint offset = self.mainScrollView.contentOffset;
    offset.x = sender.selectedSegmentIndex * self.mainScrollView.frame.size.width;
    [self.mainScrollView setContentOffset:offset animated:YES];
}

- (void)settingMainScrollView {
    UIScrollView *mainScrollView = [[UIScrollView alloc]init];
    _mainScrollView =  mainScrollView;
    _mainScrollView.bounces = NO;
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    _mainScrollView.showsVerticalScrollIndicator = NO;
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.contentSize = CGSizeMake(kScreenWidth * 2, 0);
    _mainScrollView.delegate = self;
    [self.view addSubview:_mainScrollView];
    
    __weak typeof(self)weakself = self;
    [_mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakself.view);
    }];
    
    [self.view updateConstraintsIfNeeded];
    [self.view layoutIfNeeded];
    
    //push进来默认选中第一个 添加第一个控制器的view
    UIViewController *pageOneVC = self.controllersArray[0];
    pageOneVC.view.frame = CGRectMake(0, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height);
    [_mainScrollView addSubview:pageOneVC.view];
}

#pragma mark UIScrollViewDelegate
/**
 *  滚动完毕就会调用,如果不是人为拖拽scrollView导致滚动完毕，才会调用这个方法.由setContentOffset:animated: 或者 scrollRectToVisible:animated: 方法触发
 */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    int index = scrollView.contentOffset.x / _mainScrollView.frame.size.width;
    UIViewController *willShowChildVc = self.controllersArray[index];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // 如果这个子控制器的view已经添加过了，就直接返回
    // 未添加过，添加子控制器的view
    if (willShowChildVc.isViewLoaded == NO){
        willShowChildVc.view.frame = CGRectMake(scrollView.contentOffset.x, 0, _mainScrollView.frame.size.width, _mainScrollView.frame.size.height);
        [scrollView addSubview:willShowChildVc.view];
    }
    if (index == 0) {
        [_bsVc rightBarBtnCanBeSelect];
    }else{
        [_courseVc rightBarBtnCanBeSelected];
    }
}

/**
 *  滚动完毕就会调用.如果是人为拖拽scrollView导致滚动完毕，才会调用这个方法
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger pageNum = scrollView.contentOffset.x / _mainScrollView.frame.size.width;
    _segCtrl.selectedSegmentIndex = pageNum;//选中segment对应的某项
    // 添加子控制器的view
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

@end
