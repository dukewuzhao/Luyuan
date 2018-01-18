//
//  ForgetViewController.m
//  ylss
//
//  Created by yons on 15/9/20.
//  Copyright (c) 2015年 yfapp. All rights reserved.
//

#import "ForgetViewController.h"

@interface ForgetViewController ()<UITextFieldDelegate>

@property (nonatomic,weak) UITextField *phoneNumField; // 手机号
@property (nonatomic,weak) UITextField *passwordField; // 密码
@property (nonatomic,weak) UITextField *codeField;//验证码
@property (nonatomic,assign) int num;  // 倒数计时
@property (nonatomic,weak) UIButton *nextBtn; // 提交按钮
@property (nonatomic,copy) NSString *codeStr; // 获取的验证码
@property (nonatomic,copy) NSString *phoneStr; // 填写的手机号
@property (nonatomic,weak) UIButton *codeBtn; // 获取验证码按钮
@property (nonatomic,strong) NSTimer *countDownTimer;
@end


@implementation ForgetViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.num = 60;
    // 背景色
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    
    WS(weakSelf);
    
    [self configureNavgationItemTitle:@"找回密码"];
    
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        
        [weakSelf backBtnClick];
        
    }];
    
    [self setupField]; // 添加输入框
    [self setupNextBtn];  // 提交按钮
}


-(void)backBtnClick{
    
    [self.view endEditing:YES];
    [self.countDownTimer invalidate];// 关掉计时器
    self.countDownTimer = nil;
    self.codeBtn.userInteractionEnabled = YES;
    [self.codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - 输入框
- (void)setupField
{
   // 手机号
    CGFloat usernameFieldY = 60;
    CGFloat usernameFieldW = ScreenWidth - 50;
    CGFloat usernameFieldH = 35;
    CGFloat usernameFieldX = 25;
    UITextField *phoneNumField = [self addOneTextFieldWithTitle:@"请输入手机号" imageName:nil imageNameWidth:10 Frame:CGRectMake(usernameFieldX, usernameFieldY, usernameFieldW, usernameFieldH)];
    phoneNumField.backgroundColor =[UIColor clearColor];
    [self.view addSubview:phoneNumField];
    self.phoneNumField = phoneNumField;
    
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(phoneNumField.x, CGRectGetMaxY(phoneNumField.frame), usernameFieldW, 1)];
    lineView.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
    [self.view addSubview:lineView];
    
    // 验证码
    CGFloat codeFieldY = CGRectGetMaxY(phoneNumField.frame) + 20;
    CGFloat codeFieldW = ScreenWidth - 160;
    CGFloat codeFieldH = 35;
    CGFloat codeFieldX = 25;
    
    UITextField *codeField = [self addOneTextFieldWithTitle:@"请输入验证码" imageName:nil imageNameWidth:10 Frame:CGRectMake(codeFieldX, codeFieldY, codeFieldW, codeFieldH)];
    codeField.backgroundColor = [UIColor clearColor];
    [self.view addSubview:codeField];
    self.codeField = codeField;
    
    
    UIButton *codeBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 126, codeField.y - 5, 100, 35)];
    [codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [codeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    codeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    codeBtn.contentMode = UIViewContentModeCenter;
    [codeBtn.layer setMasksToBounds:YES];//设置按钮的圆角半径不会被遮挡
    [codeBtn.layer setCornerRadius:10];
    [codeBtn.layer setBorderWidth:1];//设置边界的宽度
    //设置按钮的边界颜色
    [codeBtn.layer setBorderColor:[QFTools colorWithHexString:MainColor].CGColor];
    
    [codeBtn addTarget:self action:@selector(codeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    codeBtn.userInteractionEnabled = YES;
    [self.view addSubview:codeBtn];
    self.codeBtn = codeBtn;
    
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(codeField.x, CGRectGetMaxY(codeField.frame), usernameFieldW, 1)];
    lineView2.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
    [self.view addSubview:lineView2];
    // 密码
    CGFloat passwordFieldY = CGRectGetMaxY(codeField.frame) + 20;
    CGFloat passwordFieldW = ScreenWidth - 70;
    CGFloat passwordFieldH = 35;
    CGFloat passwordFieldX = 25;
    
    UITextField *passwordField = [self addOneTextFieldWithTitle:@"密码（6-20数字、字母）" imageName:nil imageNameWidth:10 Frame:CGRectMake(passwordFieldX, passwordFieldY, passwordFieldW, passwordFieldH)];
    passwordField.secureTextEntry = YES;
    passwordField.backgroundColor = [UIColor clearColor];
    [self.view addSubview:passwordField];
    self.passwordField = passwordField;
    
    UIView *lineView3 = [[UIView alloc] initWithFrame:CGRectMake(passwordField.x, CGRectGetMaxY(passwordField.frame), usernameFieldW, 1)];
    lineView3.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
    [self.view addSubview:lineView3];
    
}

-(void)secretShowOrHide:(UIButton *)btn{
    btn.selected = !btn.selected;
    //避免明文/密文切换后光标位置偏移
    self.passwordField.enabled = NO;    // the first one;
    self.passwordField.secureTextEntry = btn.selected;
    self.passwordField.enabled = YES;  // the second one;
    [self.passwordField becomeFirstResponder]; // the third one
    
    if (!btn.selected) {
        
        [btn setImage:[UIImage imageNamed:@"icon_pwd_show_not"] forState:UIControlStateNormal];
        
    }else{
        
        [btn setImage:[UIImage imageNamed:@"icon_pwd_show"] forState:UIControlStateNormal];
    }
    
}

#pragma mark - 获取验证码点击
- (void)codeBtnClick:(UIButton *)btn
{
    if (![QFTools isMobileNumber:self.phoneNumField.text]) {
        [SVProgressHUD showSimpleText:@"手机号码格式错误，请重新输入"];
        return;
    }
    self.codeBtn.userInteractionEnabled = NO;
    self.num = 30;
    [self.codeBtn setTitle:[NSString stringWithFormat:@"%ds后重新发送",self.num] forState:UIControlStateNormal];
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod) userInfo:nil repeats:YES];
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/requestvc"];
    NSDictionary *parameters = @{@"pn": self.phoneNumField.text};
    
    AFHTTPSessionManager *manager = [QFTools sharedManager];
    [manager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            //[SVProgressHUD showSimpleText:@"验证码已发送成功"];
            
        }
        else if([dict[@"status"] intValue] == 1001){
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }else{
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
    
    
}

#pragma mark - 倒计时
- (void)timeFireMethod{
    self.num--;
    [self.codeBtn setTitle:[NSString stringWithFormat:@"%ds重新发送",self.num] forState:UIControlStateNormal];
    if (self.num == 0) {
        [self.countDownTimer invalidate];// 关掉计时器
        self.countDownTimer = nil;
        [self.codeBtn setTitle:@"重新获取" forState:UIControlStateNormal];
        self.codeBtn.userInteractionEnabled = YES;
        self.num = 30;
    }
}

#pragma mark - 提交按钮
- (void)setupNextBtn
{
    UIButton *nextBtn = [[UIButton alloc] init];
    nextBtn.width = ScreenWidth * .58;
    nextBtn.height = 35;
    nextBtn.y = CGRectGetMaxY(self.passwordField.frame) + 50;
    nextBtn.x = ScreenWidth * .21;
    nextBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
    [nextBtn setTitle:@"提交" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[QFTools colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    nextBtn.titleLabel.font = FONT_YAHEI(16);
    nextBtn.contentMode = UIViewContentModeCenter;
    [nextBtn.layer setCornerRadius:5.0]; // 切圆角
    [nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
    self.nextBtn = nextBtn;
}

//验证验证码
- (void)nextBtnClick{
    
    if (![QFTools isMobileNumber:self.phoneNumField.text]) {
        [SVProgressHUD showSimpleText:@"请输入手机号"];
        return;
    }
    
    if (self.passwordField.text.length <6 ||self.passwordField.text.length >20){
        [SVProgressHUD showSimpleText:@"密码为6-20位字母、阿拉伯数字、英文符号或组合"];
        return;
        
    }else if ([QFTools isBlankString:self.passwordField.text]){
        [SVProgressHUD showSimpleText:@"请输入密码"];
        return;
        
    }else if ([QFTools isBlankString:self.codeField.text]){
        
        [SVProgressHUD showSimpleText:@"请输入验证码"];
        return;
        
    }
    
    [self resetpassword];
    
}// 最后的

- (void)resetpassword{
    LoadView *loadview = [[LoadView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    loadview.protetitle.text = @"正在修改密码中...";
    [self.view addSubview:loadview];
    
    NSString *pwd = [NSString stringWithFormat:@"%@%@%@",@"QGJ",self.passwordField.text,@"BLE"];
    NSString * md5=[QFTools md5:pwd];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/resetpassword"];
    NSDictionary *parameters = @{@"pn":self.phoneNumField.text,@"new_passwd": md5.uppercaseString,@"vc": self.codeField.text};
    
    AFHTTPSessionManager *manager = [QFTools sharedManager];
    
    [manager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dict) {
        [loadview removeFromSuperview];
        if ([dict[@"status"] intValue] == 0) {
            
                [SVProgressHUD showSimpleText:@"密码修改成功"];
                [self.navigationController popViewControllerAnimated:YES];
            
        }
        else if([dict[@"status"] intValue] == 1007){
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
            
        }else if([dict[@"status"] intValue] == 1006){
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
            
        }else{
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [loadview removeFromSuperview];
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
    
    
}


#pragma mark - 添加输入框
- (UITextField *)addOneTextFieldWithTitle:(NSString *)title imageName:(NSString *)imageName imageNameWidth:(CGFloat)width Frame:(CGRect)rect
{
    UITextField *field = [[UITextField alloc] init];
    [[UITextField appearance] setTintColor:[QFTools colorWithHexString:MainColor]];
    field.frame = rect;
    field.backgroundColor = [UIColor whiteColor];
    field.borderStyle = UITextBorderStyleNone;
    field.returnKeyType = UIReturnKeyDone;
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    if ([title isEqualToString:@"请输入手机号"] || [title isEqualToString:@"请输入验证码"]) {
        field.keyboardType = UIKeyboardTypeNumberPad;
        field.clearButtonMode = UITextFieldViewModeWhileEditing;
    }else if ([title isEqualToString:@"密码（6-20数字、字母）"]){
        
        UIButton *SecretBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 11, 20, 13)];
        [SecretBtn setImage:[UIImage imageNamed:@"icon_pwd_show"] forState:UIControlStateNormal];
        [SecretBtn addTarget:self action:@selector(secretShowOrHide:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:SecretBtn];
        field.rightView = SecretBtn;
        [self.passwordField becomeFirstResponder];
        field.rightViewMode = UITextFieldViewModeWhileEditing;
    }
    field.delegate = self;
    field.textColor = [UIColor blackColor];
    // 设置内容居中
    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field.leftViewMode = UITextFieldViewModeAlways;
    // 占位符
    field.placeholder = title;
    [field setValue:[QFTools colorWithHexString:@"#a7a9b0"] forKeyPath:@"_placeholderLabel.textColor"];

    return field;
}



#pragma mark - 监听输入框
#pragma mark - 监听输入框
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //明文切换密文后避免被清空
    NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.passwordField && textField.isSecureTextEntry) {
        textField.text = toBeString;
        return NO;
    }
    return YES;
    
}


#pragma mark - 点击屏幕取消键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
