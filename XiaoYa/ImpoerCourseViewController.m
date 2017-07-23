//
//  ImpoerCourseViewController.m
//  XiaoYa
//
//  Created by commet on 17/4/13.
//  Copyright © 2017年 commet. All rights reserved.
//

#import "ImpoerCourseViewController.h"
#import "Utils.h"
#import "Masonry.h"
#import "UIAlertController+Appearance.h"
#import "DbManager.h"
#import "TFHpple.h"

#define kScreenWidth [UIApplication sharedApplication].keyWindow.bounds.size.width
#define scaletowidth [UIApplication sharedApplication].keyWindow.bounds.size.width/750.0

@interface ImpoerCourseViewController ()<UITextFieldDelegate,NSURLSessionDataDelegate,NSURLSessionTaskDelegate>
@property (nonatomic ,weak)UIView *xuehaoView;
@property (nonatomic ,weak)UIView *mimaView;
@property (nonatomic ,weak)UIView *yanzhengmaView;
@property (nonatomic ,weak)UITextField *xuehaoTxf;
@property (nonatomic ,weak)UITextField *mimaTxf;
@property (nonatomic ,weak)UITextField *yanzhengmaTxf;
@property (nonatomic ,weak)UIImageView *checkCodeImg;

//@property (nonatomic ,strong)SessionManager *ssManager;
//@property (nonatomic ,strong)NSURLSessionDataTask *dataTask;
@property (nonatomic ,copy)NSString *viewState;
@property (nonatomic ,copy)NSString *randomStr;
@property (nonatomic ,copy)NSString *name;
@property (nonatomic ,strong)NSString *mainUrl;
@property (nonatomic ,copy)NSString *httpHost;

@property (nonatomic ,strong)DbManager *dbManager;
@property (nonatomic ,strong)NSURLSession *session;
@property (nonatomic ,strong)NSMutableData *httpData;
@end

@implementation ImpoerCourseViewController
{
    int refreshCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    refreshCount = 0;
    [self viewSetting];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataTaskMessage:) name:@"dataTaskNotification" object:nil];
    
    //-------
    [self viewStateAndRandomStrGetting];
}

- (void)viewSetting{
    [self xuehaoViewSetting];
    [self mimaSetting];
    [self yanzhengmaSetting];
    
    self.view.backgroundColor = [Utils colorWithHexString:@"#F0F0F6"];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[Utils colorWithHexString:@"#00a7fa"],NSFontAttributeName:[UIFont systemFontOfSize:17]};
    self.navigationItem.title = @"自动导入";
    UIButton *rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightBtn setImage:[UIImage imageNamed:@"confirm"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(confirm) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"cancel"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    
    //点击空白处收回键盘
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fingerTapped:)];
    [self.view addGestureRecognizer:singleTap];
}

//点击空白处收回键盘
-(void)fingerTapped:(UITapGestureRecognizer *)gestureRecognizer{
    [self.view endEditing:YES];
}

-(void)cancel{
    if (_xuehaoTxf.text.length == 0 && _mimaTxf.text.length == 0 && _yanzhengmaTxf.text.length == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        void (^otherBlock)(UIAlertAction *action) = ^(UIAlertAction *action){
            [self.navigationController popViewControllerAnimated:YES];
        };
        NSArray *otherBlocks = @[otherBlock];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认退出？" message:@"一旦退出，编辑将不会保存" preferredStyle:UIAlertControllerStyleAlert cancelTitle:@"取消" cancelBlock:nil otherTitles:@[@"确定"] otherBlocks:otherBlocks];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)confirm{
    [self.view endEditing:YES];//不写这句，在后面输入错误、点击登录时候会报错：UIKeyboardTaskQueue waitUntilAllTasksAreFinished
    [self login];
}

- (void)viewStateAndRandomStrGetting{//系统自动重定向三次
    NSURL *url = [NSURL URLWithString:@"http://jw2005.scuteo.com/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request addValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
    [request addValue:@"jw2005.scuteo.com" forHTTPHeaderField:@"Host"];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    task.taskDescription = @"getViewStateAndRandomStr";
    [task resume];
}

-(void)shuaXinYanZhengMa{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@/CheckCode.aspx",self.httpHost,self.randomStr]];
    NSMutableURLRequest *UrlRequest = [NSMutableURLRequest requestWithURL:url];
    //    UrlRequest.HTTPShouldHandleCookies = YES;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSHTTPCookie *cookie = [[cookieJar cookiesForURL:[NSURL URLWithString:self.mainUrl]]firstObject];
    [UrlRequest setValue:[NSString stringWithFormat:@"%@=%@", [cookie name], [cookie value]] forHTTPHeaderField:@"Cookie"];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:UrlRequest];
    task.taskDescription = @"getCheckCode";
    [task resume];
}

- (void)login{//这里也是系统自动重定向了
    NSString *paraStr = [NSString stringWithFormat:@"__VIEWSTATE=%@&txtUserName=%@&TextBox2=%@&txtSecretCode=%@&RadioButtonList1=学生&Button1=&lbLanguage=&hidPdrs=&hidsc=",self.viewState,self.xuehaoTxf.text,self.mimaTxf.text,self.yanzhengmaTxf.text];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@/default2.aspx",self.httpHost,self.randomStr]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
    request.HTTPBody = [paraStr dataUsingEncoding:enc];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    task.taskDescription = @"loginRefer";
    [task resume];
}

- (void)courseGetting{
    NSString *urlstr = [NSString stringWithFormat:@"http://%@/%@/xskbcx.aspx?xh=%@&xm=%@&gnmkdm=N121603",self.httpHost,self.randomStr,self.xuehaoTxf.text,self.name];
    urlstr = [urlstr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlstr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod= @"GET";
    [request addValue:[NSString stringWithFormat:@"http://%@/%@/xs_main.aspx?xh=%@",self.httpHost,self.randomStr,self.xuehaoTxf.text] forHTTPHeaderField:@"Referer"];//这句一定不能漏
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request];
    task.taskDescription = @"courseget";
    [task resume];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    completionHandler(NSURLSessionResponseAllow);
    //请求http://jw2005.scuteo.com/数据这里会有三次重定向，由系统自动完成
    if ([dataTask.taskDescription isEqualToString:@"getViewStateAndRandomStr"]) {
        //这里要用正则表达式提取比较好
        self.httpHost = response.URL.host;
//        self.randomStr = [response.URL.absoluteString substringWithRange:NSMakeRange(21, 26)];
        NSError *error;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\(.*\\)" options:0 error:&error];
        if (!error) {
            NSTextCheckingResult *match = [regex firstMatchInString:response.URL.absoluteString options:0 range:NSMakeRange(0, [response.URL.absoluteString length])];
            if (match) {
                self.randomStr = [response.URL.absoluteString substringWithRange:match.range];
                NSLog(@"%@",self.randomStr);
            }
        }else{
            NSLog(@"error-%@",error);
        }
    }
}

//拼接数据
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [data enumerateByteRangesUsingBlock:^(const void * _Nonnull bytes, NSRange byteRange, BOOL * _Nonnull stop) {
        [self.httpData appendBytes:bytes length:byteRange.length];
    }];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error != nil) {
        NSLog(@"error:%@",error);
        return;
    }
    if ([task.taskDescription isEqualToString:@"getViewStateAndRandomStr"]) {
        task = nil;
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
        NSString *transtr = [[NSString alloc]initWithData:self.httpData encoding:enc];
        NSString *htmlUTF8Str = [transtr stringByReplacingOccurrencesOfString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=gb2312\">" withString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"];
        NSData *htmlDataUTF8 = [htmlUTF8Str dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *xpathParser = [[TFHpple alloc]initWithHTMLData:htmlDataUTF8];
        NSArray *elements  = [xpathParser searchWithXPathQuery:@"//input[@name='__VIEWSTATE']"];
        for (int i=0; i<[elements count]; i++) {
            TFHppleElement *element = [elements objectAtIndex:i];
            self.viewState=[element objectForKey:@"value"];
            NSLog(@"提取到得viewstate为%@",self.viewState);
            self.viewState = [self.viewState stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
            self.viewState = [self.viewState stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
        }
        self.httpData = nil;
        [self shuaXinYanZhengMa];
    }else if ([task.taskDescription isEqualToString:@"getCheckCode"]){
        task= nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.checkCodeImg.image = [[UIImage alloc]initWithData:self.httpData];
            self.httpData = nil;
        });
    }else if ([task.taskDescription isEqualToString:@"loginRefer"]) {
        task= nil;
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
        NSString *transtr = [[NSString alloc]initWithData:self.httpData encoding:enc];
        NSString *utf8HtmlStr = [transtr stringByReplacingOccurrencesOfString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=gb2312\">" withString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"];
        NSData *htmlDataUTF8 = [utf8HtmlStr dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *xpathParser = [[TFHpple alloc]initWithHTMLData:htmlDataUTF8];
        NSArray *elements  = [xpathParser searchWithXPathQuery:@"//span[@id='xhxm']"];
        self.httpData = nil;//清空数据
        if (elements.count > 0) {
            for (int i=0; i<[elements count]; i++) {
                TFHppleElement *element = [elements objectAtIndex:i];
                NSString *content = [element text];
                self.name=[content substringToIndex:[content length]-2];
                NSLog(@"姓名为%@",self.name);
            }
            [self courseGetting];
        }else{
            NSArray *errElement = [xpathParser searchWithXPathQuery:@"//script[@language='javascript']"];
            TFHppleElement *scriptNode = errElement.lastObject;//验证码不正确
            NSString *alertMessage = [[scriptNode.content componentsSeparatedByString:@";"]firstObject];
            alertMessage = [[alertMessage componentsSeparatedByString:@"("]lastObject];
            alertMessage = [[alertMessage componentsSeparatedByString:@")"]firstObject];
            UIAlertController *alert ;
            if ([alertMessage isEqualToString:@"'用户名不存在或未按照要求参加教学活动！！'"]) {
                alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"用户名不存在或未按要求参加教学活动！！" preferredStyle:UIAlertControllerStyleAlert];
            }else if ([alertMessage isEqualToString:@"'密码错误！！'"]){
                alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"密码错误！！" preferredStyle:UIAlertControllerStyleAlert];
            }else if ([alertMessage isEqualToString:@"'验证码不正确！！'"]){
                alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"验证码不正确！！" preferredStyle:UIAlertControllerStyleAlert];
            }
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"重新输入" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
            [self shuaXinYanZhengMa];
        }
    }
    else if ([task.taskDescription isEqualToString:@"courseget"]){
        task=nil;
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding (kCFStringEncodingGB_18030_2000);
        NSString *transtr = [[NSString alloc]initWithData:self.httpData encoding:enc];
        NSString *utf8HtmlStr = [transtr stringByReplacingOccurrencesOfString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=gb2312\">" withString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"];
        NSData *htmlDataUTF8 = [utf8HtmlStr dataUsingEncoding:NSUTF8StringEncoding];
        TFHpple *xpathParser = [[TFHpple alloc]initWithHTMLData:htmlDataUTF8];
        //        NSArray *elements  = [xpathParser searchWithXPathQuery:@"//table[@id='Table1']/tr/td/child::text()"];
        
        NSArray *trNodesElements = [xpathParser searchWithXPathQuery:@"//table[@id='Table1']/tr"];
        for (TFHppleElement *trNode in trNodesElements) {
            NSArray *tdNodesElements = [trNode searchWithXPathQuery:@"//td"];
            BOOL isGetRowSpan = NO;//“第x节”文本之后的才是课程信息
            int sectionStartNumber = 0;//第几节开始，这个要做处理
            int weekDayNumber = 0;//星期几，这个不用处理，从0开始表示星期一
            for (TFHppleElement *tdNode in tdNodesElements) {
                if (isGetRowSpan) {
                    NSString *rowSpan = tdNode.attributes[@"rowspan"];
                    if (rowSpan == nil) {
                        weekDayNumber++;
                        continue;
                    }
                    NSLog(@"%@",rowSpan);
                    NSMutableArray *textcache = [NSMutableArray array];//文本数组
                    NSArray *textElements = [tdNode searchWithXPathQuery:@"//child::text()"];
                    NSMutableArray *weekIndexs = [NSMutableArray array];//把含有{}的文本（周数时间文本）的位置存储起来
                    for (int i = 0 ;i < textElements.count ;i++) {
                        NSLog(@"%@",[textElements[i] content]);
                        //把所有文本都存储起来
                        [textcache addObject:[textElements[i] content]];
                        //把含有{}的文本（周数时间文本）的位置存储起来
                        if ([[textElements[i] content] rangeOfString:@"{"].location != NSNotFound &&[[textElements[i] content] rangeOfString:@"}"].location != NSNotFound) {
                            [weekIndexs addObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInt:i]]];
                        }
                    }
                    
                    //------------------------补全文本（课程名称、周数必有，上课地点不一定有，教师名字不清楚是不是必有，假设可能没有），从后往前补全
                    //先补最后一个
                    int theLastIndex = [[weekIndexs lastObject]intValue];
                    int deltaLastOne = (int)(textcache.count - theLastIndex - 1);
                    for (int i = 0; i < 2-deltaLastOne; i++) {
                        [textcache addObject:@""];
                        //                        [textcache insertObject:@"" atIndex:textcache.count+i];
                    }
                    //从后往前补
                    if (weekIndexs.count > 1) {
                        for (int i = (int)weekIndexs.count-2; i >= 0; i--) {
                            int thePeriorIndex = [weekIndexs[i] intValue];
                            int delta = theLastIndex - thePeriorIndex;
                            for (int j = 0; j < 4-delta; j++) {
                                [textcache insertObject:@"" atIndex:theLastIndex-1+j];
                            }
                            theLastIndex = thePeriorIndex;
                        }
                    }
                    
                    //已经补全文本，4个一组表示一项课程，一次为课程名、周数、教师、地点
                    //-------------------------处理周数
                    int specialMark = 0;//单周、双周或其他
                    NSString *week = [NSString string];//周数：“n-m”
                    int startWeek = 0;//开始周
                    int endWeek = 0;//结束周
                    //                    NSArray *startWeekAndEndWeek = [NSArray array];//开始周和结束周
                    for (int i = 1; i < textcache.count - 1;i+=4) {
                        //截取{}内的周数信息
                        NSString * tempString = [[textcache[i] componentsSeparatedByString:@"{"]lastObject];
                        NSString *weekMessageStr = [[tempString componentsSeparatedByString:@"}"]firstObject];
                        if ([weekMessageStr rangeOfString:@"|"].location != NSNotFound) {//有单双周信息
                            NSArray *weekMessageArray = [weekMessageStr componentsSeparatedByString:@"|"];
                            if([[weekMessageArray lastObject]rangeOfString:@"单周"].location != NSNotFound){
                                specialMark = 1;
                            }else if ([[weekMessageArray lastObject]rangeOfString:@"双周"].location != NSNotFound){
                                specialMark = 2;
                            }
                            week = [[weekMessageArray firstObject]substringWithRange:NSMakeRange(1, [[weekMessageArray firstObject]length] - 2)];
                        }else{//没有单双周信息
                            specialMark = 0;
                            week = [weekMessageStr substringWithRange:NSMakeRange(1, weekMessageStr.length - 2)];
                        }
                        startWeek = [[[week componentsSeparatedByString:@"-"]firstObject]intValue]-1;
                        endWeek = [[[week componentsSeparatedByString:@"-"]lastObject]intValue]-1;
                        //拼接周数字符串，把每周枚举出来，用逗号分割
                        NSMutableString *str = [[NSMutableString alloc] initWithCapacity:2];
                        [str appendString:@","];
                        if (specialMark == 1||specialMark == 2) {
                            for (int j = 0; startWeek+j <= endWeek; j+=2) {
                                [str appendFormat:@"%@,",[NSNumber numberWithInt:startWeek+j]];
                            }
                        }else{
                            for (int j = 0; startWeek+j <= endWeek; j++) {
                                [str appendFormat:@"%@,",[NSNumber numberWithInt:startWeek+j]];
                            }
                        }
                        //用拼接后的周数字符串替换原来的周数信息
                        [textcache replaceObjectAtIndex:i withObject:str];
                    }
                    NSLog(@"%@",textcache);
                    
                    //-------------------------拼接节数字符串
                    int tempnum = sectionStartNumber;
                    NSMutableString *timeStr = [[NSMutableString alloc] initWithCapacity:2];
                    [timeStr appendString:@","];
                    if (sectionStartNumber > 4) {//后移一位，因为第四第五节中间有个"午间"
                        tempnum = sectionStartNumber+1;
                    }
                    for (int j = 0; j < rowSpan.intValue; j++) {
                        [timeStr appendFormat:@"%@,",[NSNumber numberWithInt:tempnum+j]];
                    }
                    
                    for (int i = 0; i < textcache.count;i+=4) {
                        NSString *sql = [NSString stringWithFormat:@"INSERT INTO course_table (courseName,weeks,weekday,time,place) VALUES ('%@','%@','%@','%@','%@');",textcache[i],textcache[i+1],[NSNumber numberWithInt:weekDayNumber],timeStr,textcache[i+3]];
                        [self.dbManager executeNonQuery:sql];
                    }
                    
                    weekDayNumber ++;
                }
                if ([tdNode.text hasPrefix:@"第"]&&[tdNode.text hasSuffix:@"节"]) {
                    isGetRowSpan = YES;
                    sectionStartNumber = [[tdNode.text substringWithRange:NSMakeRange(1, tdNode.text.length-2)]intValue];
                }
            }
            self.httpData = nil;//清空数据
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{@"refreshViews":@""};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dataTaskNotification" object:nil userInfo:userInfo];
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }
}

- (NSURLSession *)session{
    if (_session == nil) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];//如果用emp模式得不到cookie
//        configuration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyNever;
        NSDictionary *additionalHeaders = [NSDictionary dictionaryWithObjectsAndKeys:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",@"Accept",                                                      @"gzip, deflate, sdch",@"Accept-Encoding",
                                           @"zh-CN,zh;q=0.8",@"Accept-Language",
                                           @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36",@"User-Agent",@"1",@"Upgrade-Insecure-Requests", nil];
        configuration.HTTPAdditionalHeaders = additionalHeaders;
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    }
    return _session;
//    static NSURLSession *shareSession = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];//如果用emp模式得不到cookie
//        configuration.HTTPCookieAcceptPolicy = NSHTTPCookieAcceptPolicyNever;
//        NSDictionary *additionalHeaders = [NSDictionary dictionaryWithObjectsAndKeys:@"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",@"Accept",                                                      @"gzip, deflate, sdch",@"Accept-Encoding",
//                                           @"zh-CN,zh;q=0.8",@"Accept-Language",
//                                           @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36",@"User-Agent",@"1",@"Upgrade-Insecure-Requests", nil];
//        configuration.HTTPAdditionalHeaders = additionalHeaders;
//        shareSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
//    });
//    return shareSession;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler{
    NSMutableURLRequest *newrequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https:www.baidu.com"]];
    newrequest.HTTPMethod = @"GET";
    completionHandler(request);
    NSLog(@"%s,",__func__);
}

#pragma mark viewsSetting
- (void)xuehaoViewSetting{
    UIView *xuehaoView = [[UIView alloc] init];
    _xuehaoView = xuehaoView;
    xuehaoView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:xuehaoView];
    __weak typeof(self) weakself = self;
    [xuehaoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(weakself.view);
        make.centerX.equalTo(weakself.view.mas_centerX);
    }];
    
    UITextField *xuehaoTxf = [[UITextField alloc] init];
    self.xuehaoTxf = xuehaoTxf;
    _xuehaoTxf.text = @"201430252193";
    _xuehaoTxf.layer.borderColor = [[Utils colorWithHexString:@"#d9d9d9"]CGColor];
    _xuehaoTxf.layer.borderWidth = 0.5f;
    _xuehaoTxf.layer.cornerRadius = 2.0f;
    _xuehaoTxf.textColor = [Utils colorWithHexString:@"#333333"];
    _xuehaoTxf.font = [UIFont systemFontOfSize:12.0];
    _xuehaoTxf.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 1)];
    _xuehaoTxf.leftViewMode = UITextFieldViewModeAlways;
    [xuehaoView addSubview:_xuehaoTxf];
    [_xuehaoTxf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(xuehaoView.mas_centerX);
        make.centerY.equalTo(xuehaoView.mas_centerY);
        make.width.mas_equalTo(500 * scaletowidth);
        make.height.mas_equalTo(32);
    }];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSForegroundColorAttributeName] = [Utils colorWithHexString:@"#d9d9d9"];
    dict[NSFontAttributeName] = [UIFont systemFontOfSize:12.0];
    NSAttributedString *attribute = [[NSAttributedString alloc] initWithString:@"请输入教务系统密码" attributes:dict];
    [_xuehaoTxf setAttributedPlaceholder:attribute];
    _xuehaoTxf.delegate = self;
    [_xuehaoTxf addTarget:self action:@selector(textFiledDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    UILabel *xuehaoLab = [[UILabel alloc] init];
    xuehaoLab.text = @"学号";
    xuehaoLab.font = [UIFont systemFontOfSize:12.0];
    xuehaoLab.textColor = [Utils colorWithHexString:@"#333333"];
    [xuehaoView addSubview:xuehaoLab];
    [xuehaoLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_xuehaoTxf.mas_centerY);
        make.right.equalTo(_xuehaoTxf.mas_left).offset(-20*scaletowidth);
    }];
    
    UIView *line1 = [[UIView alloc]init];
    line1.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [xuehaoView addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(weakself.view);
        make.height.mas_equalTo(0.5);
        make.top.equalTo(xuehaoView.mas_top);
    }];
    UIView *line2 = [[UIView alloc]init];
    line2.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [xuehaoView addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(weakself.view);
        make.height.mas_equalTo(0.5);
        make.bottom.equalTo(xuehaoView.mas_bottom);
    }];
}

- (void)mimaSetting{
    UIView *mimaView = [[UIView alloc] init];
    _mimaView = mimaView;
    mimaView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:mimaView];
    __weak typeof(self) weakself = self;
    [mimaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(_xuehaoView.mas_bottom).offset(12);
        make.centerX.equalTo(weakself.view.mas_centerX);
    }];
    
    UITextField *mimaTxf = [[UITextField alloc] init];
    _mimaTxf = mimaTxf;
    _mimaTxf.text = @"bmelhf2807301";
    _mimaTxf.layer.borderColor = [[Utils colorWithHexString:@"#d9d9d9"]CGColor];
    _mimaTxf.layer.borderWidth = 0.5f;
    _mimaTxf.layer.cornerRadius = 2.0f;
    _mimaTxf.textColor = [Utils colorWithHexString:@"#333333"];
    _mimaTxf.font = [UIFont systemFontOfSize:12.0];
    _mimaTxf.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 1)];
    _mimaTxf.leftViewMode = UITextFieldViewModeAlways;
    [_mimaView addSubview:_mimaTxf];
    [_mimaTxf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_mimaView.mas_centerX);
        make.centerY.equalTo(_mimaView.mas_centerY);
        make.width.mas_equalTo(500 * scaletowidth);
        make.height.mas_equalTo(32);
    }];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSForegroundColorAttributeName] = [Utils colorWithHexString:@"#d9d9d9"];
    dict[NSFontAttributeName] = [UIFont systemFontOfSize:12.0];
    NSAttributedString *attribute = [[NSAttributedString alloc] initWithString:@"请输入教务系统密码" attributes:dict];
    [_mimaTxf setAttributedPlaceholder:attribute];
    _mimaTxf.delegate = self;
    [_mimaTxf addTarget:self action:@selector(textFiledDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    UILabel *mimaLab = [[UILabel alloc] init];
    mimaLab.text = @"密码";
    mimaLab.font = [UIFont systemFontOfSize:12.0];
    mimaLab.textColor = [Utils colorWithHexString:@"#333333"];
    [_mimaView addSubview:mimaLab];
    [mimaLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_mimaTxf.mas_centerY);
        make.right.equalTo(_mimaTxf.mas_left).offset(-20*scaletowidth);
    }];
    
    UIView *line1 = [[UIView alloc]init];
    line1.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [_mimaView addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(weakself.view);
        make.height.mas_equalTo(0.5);
        make.top.equalTo(_mimaView.mas_top);
    }];
    UIView *line2 = [[UIView alloc]init];
    line2.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [_mimaView addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(weakself.view);
        make.height.mas_equalTo(0.5);
        make.bottom.equalTo(_mimaView.mas_bottom);
    }];
}

- (void)yanzhengmaSetting{
    UIView *yanzhengmaView = [[UIView alloc] init];
    _yanzhengmaView = yanzhengmaView;
    _yanzhengmaView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_yanzhengmaView];
    __weak typeof(self) weakself = self;
    [_yanzhengmaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(kScreenWidth);
        make.top.equalTo(_mimaView.mas_bottom).offset(12);
        make.centerX.equalTo(weakself.view.mas_centerX);
    }];
    
    UITextField *yanzhengmaTxf = [[UITextField alloc] init];
    _yanzhengmaTxf = yanzhengmaTxf;
    _yanzhengmaTxf.layer.borderColor = [[Utils colorWithHexString:@"#d9d9d9"]CGColor];
    _yanzhengmaTxf.layer.borderWidth = 0.5f;
    _yanzhengmaTxf.layer.cornerRadius = 2.0f;
    _yanzhengmaTxf.textColor = [Utils colorWithHexString:@"#333333"];
    _yanzhengmaTxf.font = [UIFont systemFontOfSize:12.0];
    _yanzhengmaTxf.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 1)];
    _yanzhengmaTxf.leftViewMode = UITextFieldViewModeAlways;
    [_yanzhengmaView addSubview:_yanzhengmaTxf];
    [_yanzhengmaTxf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_mimaTxf.mas_left);
        make.centerY.equalTo(_yanzhengmaView.mas_centerY);
        make.width.mas_equalTo(250 * scaletowidth);
        make.height.mas_equalTo(32);
    }];
    _yanzhengmaTxf.delegate = self;
    [_yanzhengmaTxf addTarget:self action:@selector(textFiledDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    UILabel *yanzhengLab = [[UILabel alloc] init];
    yanzhengLab.text = @"验证码";
    yanzhengLab.font = [UIFont systemFontOfSize:12.0];
    yanzhengLab.textColor = [Utils colorWithHexString:@"#333333"];
    [_yanzhengmaView addSubview:yanzhengLab];
    [yanzhengLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_yanzhengmaTxf.mas_centerY);
        make.right.equalTo(_yanzhengmaTxf.mas_left).offset(-20*scaletowidth);
    }];
    
    UIImageView *checkCodeImg = [[UIImageView alloc]init];
    _checkCodeImg = checkCodeImg;
    [_yanzhengmaView addSubview:_checkCodeImg];
    [_checkCodeImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(32);
        make.width.mas_equalTo(85);
        make.centerY.equalTo(_yanzhengmaView.mas_centerY);
        make.left.equalTo(_yanzhengmaTxf.mas_right).offset(5);
    }];
    
    UIButton *updateYanzheng = [[UIButton alloc]init];
    [updateYanzheng addTarget:self action:@selector(shuaXinYanZhengMa) forControlEvents:UIControlEventTouchUpInside];
    [updateYanzheng setTitle:@"刷新" forState:UIControlStateNormal];
    [updateYanzheng setTitleColor:[Utils colorWithHexString:@"#00a7fa"] forState:UIControlStateNormal];
    updateYanzheng.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [_yanzhengmaView addSubview:updateYanzheng];
    [updateYanzheng mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 40));
        make.centerY.equalTo(_yanzhengmaView.mas_centerY);
        make.left.equalTo(_checkCodeImg.mas_right).offset(5);
    }];
    
    UIView *line1 = [[UIView alloc]init];
    line1.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [_yanzhengmaView addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(weakself.view);
        make.height.mas_equalTo(0.5);
        make.top.equalTo(_yanzhengmaView.mas_top);
    }];
    UIView *line2 = [[UIView alloc]init];
    line2.backgroundColor = [Utils colorWithHexString:@"d9d9d9"];
    [_yanzhengmaView addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.left.equalTo(weakself.view);
        make.height.mas_equalTo(0.5);
        make.bottom.equalTo(_yanzhengmaView.mas_bottom);
    }];
}

#pragma mark textFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    //返回一个BOOL值，指明是否允许在按下回车键时结束编辑
    [textField resignFirstResponder];
    return YES;
}

- (void)textFiledDidChange:(UITextField *)textField{
    [self rightBarBtnCanBeSelected];
}

- (void)rightBarBtnCanBeSelected{
    if (_xuehaoTxf.text.length > 0 && _mimaTxf.text.length > 0 && _yanzhengmaTxf.text.length > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (SessionManager *)ssManager{
//    if (_ssManager == nil) {
//        _ssManager = [SessionManager shareSession];
//    }
//    return _ssManager;
//}

- (NSString *)randomStr{
    if (_randomStr == nil) {
        _randomStr = [NSString string];
    }
    return _randomStr;
}

- (NSString *)viewState{
    if (_viewState == nil) {
        _viewState = [NSString string];
    }
    return _viewState;
}

- (NSString *)httpHost{
    if (_httpHost == nil) {
        _httpHost = [NSString string];
    }
    return _httpHost;
}
- (NSString *)mainUrl{
    if (_mainUrl == nil) {
        _mainUrl = [NSString string];
    }
    return _mainUrl;
}
- (DbManager *)dbManager{
    if (_dbManager == nil) {
        _dbManager = [DbManager shareInstance];
    }
    return _dbManager;
}
- (NSMutableData *)httpData{
    if (_httpData == nil) {
        _httpData = [NSMutableData data];
    }
    return _httpData;
}
@end
