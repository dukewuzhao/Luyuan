//
//  MyViewController.h
//  阿尔卑斯
//
//  Created by 同时科技 on 16/3/28.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "IdeaViewController.h"
#import "HCTextView.h"
@interface IdeaViewController () <UITextViewDelegate>
    
    @property (nonatomic, weak) HCTextView *compseView;
    
    @property (nonatomic, weak) HCTextView *phnoView;
    @property (nonatomic, weak) UIButton *nextBtn;
    
    @end

@implementation IdeaViewController
    
    
- (void)viewWillAppear:(BOOL)animated
    {
        [super viewWillAppear:animated];
    }
    
    // 即将出去后再打开 因为可能其他页面需要抽屉效果
- (void)viewWillDisappear:(BOOL)animated
    {
        [super viewWillDisappear:animated];
    }
    
    
- (void)viewDidLoad {
    [super viewDidLoad];
    
    @weakify(self);
    [self configureNavgationItemTitle:@"意见反馈"];
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
    //[self setupNavBar];
    [self setupFieldView];
    
    [self setupPhFieldView];
    [self setupNextBtn];
    
}
    
- (void)setupNavBar{
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.164 green:0.657 blue:0.915 alpha:1.000]];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
}
    
    
#pragma mark - 输入框
- (void)setupPhFieldView
    {
        UITextField *phView = [[UITextField alloc] init];
        phView.borderStyle = UITextBorderStyleRoundedRect;
        phView.returnKeyType = UIReturnKeyDone;
        HCTextView *phnoView = [[HCTextView alloc] init];
        phnoView.backgroundColor = [UIColor whiteColor];
        phnoView.textColor = [UIColor blackColor];
        phnoView.x = 10;
        phnoView.y = 180;
        phnoView.width = ScreenWidth - 20;
        phnoView.height = 40;
        phnoView.placeholder = @"请输入你的邮箱地址，以便我们回复";
        [[UITextView appearance] setTintColor:[QFTools colorWithHexString:MainColor]];
        // 设置textView可垂直滚动
        phnoView.alwaysBounceVertical = NO;
        phView.clearButtonMode = UITextFieldViewModeWhileEditing;
        phView.frame = CGRectMake(phnoView.x - 1, phnoView.y - 1, phnoView.width + 2, phnoView.height + 2);
        [phView.layer setCornerRadius:6];
        [self.view addSubview:phView];
        [self.view addSubview:phnoView];
        self.phnoView = phnoView;
    }
    
#pragma mark - 输入框
- (void)setupFieldView
    {
        UITextField *bgView = [[UITextField alloc] init];
        bgView.borderStyle = UITextBorderStyleRoundedRect;
        bgView.returnKeyType = UIReturnKeyDone;
        HCTextView *compseView = [[HCTextView alloc] init];
        compseView.backgroundColor = [UIColor whiteColor];
        compseView.textColor = [UIColor blackColor];
        compseView.x = 10;
        compseView.y = 20;
        compseView.width = ScreenWidth - 20;
        compseView.height = 144;
        compseView.placeholder = @"请输入您遇到的问题或建议";
        // 设置textView可垂直滚动
        compseView.alwaysBounceVertical = NO;
        
        bgView.frame = CGRectMake(compseView.x - 1, compseView.y - 1, compseView.width + 2, compseView.height + 2);
        [bgView.layer setCornerRadius:6];
        [self.view addSubview:bgView];
        [self.view addSubview:compseView];
        self.compseView = compseView;
    }
    
#pragma mark - 提交按钮
- (void)setupNextBtn
    {
        UIButton *nextBtn = [[UIButton alloc] init];
        nextBtn.width = self.compseView.width;
        nextBtn.x = (ScreenWidth - nextBtn.width) * 0.5;
        nextBtn.y = CGRectGetMaxY(self.phnoView.frame) + 25;
        nextBtn.height = 35;
        nextBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
        [nextBtn setTitle:@"发送" forState:UIControlStateNormal];
        [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        nextBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        nextBtn.contentMode = UIViewContentModeCenter;
        [nextBtn.layer setCornerRadius:3.0]; // 切圆角
        [nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:nextBtn];
        self.nextBtn = nextBtn;
    }
    
    
- (void)nextBtnClick
    {
        if ([QFTools isBlankString:self.compseView.text] || [QFTools isBlankString:self.phnoView.text] ) {
            
            [SVProgressHUD showSimpleText:@"意见反馈与联系方式不能为空"];
            
            return;
        }else if (![QFTools isValidateEmail:self.phnoView.text] && ![QFTools isMobileNumber:self.phnoView.text]){
            
            [SVProgressHUD showSimpleText:@"联系方式格式错误"];
            
            return;
            
        }
        
        NSString *token = [QFTools md5:[NSString stringWithFormat:@"%@%@",self.phnoView.text,self.compseView.text]];
        NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/userfeedback"];
        NSDictionary *parameters = @{@"token": token, @"contact": self.phnoView.text,@"suggestion": self.compseView.text};
        
        [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
            
            if ([dict[@"status"] intValue] == 0) {
                
                [SVProgressHUD showSimpleText:@"提交成功"];
                [self.navigationController popViewControllerAnimated:YES];
                
            }else{
                
                [SVProgressHUD showSimpleText:@"提交失败"];
            }
            
        }failure:^(NSError *error) {
            
            NSLog(@"error :%@",error);
            
        }];
    }
    
-(void)backView{
    
    [self.view endEditing:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}
    
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
    
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
    {
        [self.view endEditing:YES];
    }
    
- (void)dealloc
    {
        NSLog(@"%s dealloc",object_getClassName(self));
    }
    
    
    @end
