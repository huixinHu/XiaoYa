//
//  CommentViewController.m
//  XiaoYa
//
//  Created by commet on 17/2/14.
//  Copyright © 2017年 commet. All rights reserved.
// 备注页

#import "CommentViewController.h"
#import "UIAlertController+Appearance.h"
#import "UILabel+AlertActionFont.h"
#import "Masonry.h"
#import "Utils.h"

@interface CommentViewController ()
@property (nonatomic , weak) UITextView *commentTv;
@property (nonatomic , copy) NSString *commentInfo;
@property (nonatomic , copy) completeBlock cmpBlock;
@end

@implementation CommentViewController

- (instancetype)initWithTextStr:(NSString *)str successBlock:(completeBlock)block{
    self = [super init];
    if (self) {
        self.commentInfo = str;
        self.cmpBlock = [block copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[Utils colorWithHexString:@"#333333"],NSFontAttributeName:[UIFont systemFontOfSize:17]};//设置标题文字样式
    self.navigationItem.title = @"备注信息";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"confirm"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(confirm)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[[UIImage imageNamed:@"cancel"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    [self commonInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)confirm{
    [self.navigationController popViewControllerAnimated:YES];
    [_commentTv resignFirstResponder];
    self.cmpBlock(self.commentTv.text);
}

- (void)cancel{
    if ([_commentTv.text isEqualToString:@""]) {
        [self.navigationController popViewControllerAnimated:YES];//返回主界面
    }else{
        __weak typeof(self) ws = self;
        void (^otherBlock)(UIAlertAction *action) = ^(UIAlertAction *action){
            [ws.navigationController popViewControllerAnimated:YES];
        };
        NSArray *otherBlocks = @[otherBlock];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认退出？" message:@"一旦退出，编辑将不会保存" preferredStyle:UIAlertControllerStyleAlert cancelTitle:@"取消" cancelBlock:nil otherTitles:@[@"确定"] otherBlocks:otherBlocks];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)commonInit{
    UITextView *commentTv = [[UITextView alloc]init];
    _commentTv = commentTv;
    _commentTv.font = [UIFont systemFontOfSize:14.0];
    _commentTv.textColor = [Utils colorWithHexString:@"#1a1a1a"];
    [self.view addSubview:_commentTv];
    // _placeholderLabel
    UILabel *placeHolderLabel = [[UILabel alloc] init];
    placeHolderLabel.text = @"输入备注内容";
    placeHolderLabel.numberOfLines = 0;
    placeHolderLabel.textColor = [Utils colorWithHexString:@"#d9d9d9"];
    [placeHolderLabel sizeToFit];
    placeHolderLabel.font = [UIFont systemFontOfSize:14.0];
    [_commentTv addSubview:placeHolderLabel];
    [_commentTv setValue:placeHolderLabel forKey:@"_placeholderLabel"];//用到运行时
    
    __weak typeof(self) weakself = self;
    [_commentTv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakself.view).with.insets(UIEdgeInsetsMake(5, 25, 5, 25));
    }];
    
    [_commentTv becomeFirstResponder];
    _commentTv.text = self.commentInfo;
    if(_commentTv.text.length){
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    //监听
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(txfChange:) name:UITextViewTextDidChangeNotification object:_commentTv];
}

-(void)txfChange:(NSNotification *)notification
{
    if (_commentTv.text.length > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;//设置导航栏右按钮可以点击
    }else
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:_commentTv];
}

@end
