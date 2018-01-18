//
//  LoginViewController.m
//  JinBang
//
//  Created by QFApple on 15/2/28.
//  Copyright (c) 2015年 qf365.com. All rights reserved.
//

#import "LoginViewController.h"
#import "MobileViewController.h"
#import "ForgetViewController.h"

@interface LoginViewController () <UITextFieldDelegate>
{
    NSString *child;
    NSString *main;
}
@property (nonatomic,weak) UITextField *usernameField; // 用户名
@property (nonatomic,weak) UITextField *passwordField; // 密码
@property (nonatomic,weak) UILabel *retrieveLabel; // 找回密码
@property (nonatomic,weak) UIButton *logBtn; // 登录按钮

@end

@implementation LoginViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    [self initheadView];
    [self setupField];    // 输入框
    [self setupLogBtn];  // 登录按钮
    [self setupResBtn];  // 注册按钮
}

- (void)initheadView{
    
    UIImageView *logoImage = [[UIImageView alloc] init];
    logoImage.width = ScreenWidth *.23;
    logoImage.height = ScreenWidth * .82 * .23;
    logoImage.center = CGPointMake(ScreenWidth/2, ScreenHeight *.18);
    logoImage.image = [UIImage imageNamed:@"login_logo"];
    [self.view addSubview:logoImage];
}


#pragma mark - 用户名、密码输入框
- (void)setupField
{
    // 用户名
    CGFloat usernameFieldY = ScreenHeight *.36+ 5;
    CGFloat usernameFieldW = ScreenWidth  - 70;
    CGFloat usernameFieldH = 35;
    CGFloat usernameFieldX = 35;
    
    UITextField *usernameField = [self addOneTextFieldWithTitle:@"请输入手机号" imageName:@"" imageNameWidth:10 Frame:CGRectMake(usernameFieldX, usernameFieldY, usernameFieldW, usernameFieldH)];
    usernameField.backgroundColor = [UIColor clearColor];
    if (![QFTools isBlankString:[QFTools getuserInfo:@"username"]]){
        usernameField.text = [QFTools getuserInfo:@"username"];
    }
    [self.view addSubview:usernameField];
    self.usernameField = usernameField;
    
    UIView *lineView =[[UIView alloc] initWithFrame:CGRectMake(usernameField.x, CGRectGetMaxY(usernameField.frame), usernameFieldW, 1)];
    lineView.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
    [self.view addSubview:lineView];
    
    // 密码
    CGFloat passwordFieldY = CGRectGetMaxY(self.usernameField.frame) + 20;
    CGFloat passwordFieldW = usernameFieldW;
    CGFloat passwordFieldH = usernameFieldH;
    CGFloat passwordFieldX = usernameFieldX;
    
    UITextField *passwordField = [self addOneTextFieldWithTitle:@"请输入密码" imageName:@"" imageNameWidth:10 Frame:CGRectMake(passwordFieldX, passwordFieldY, passwordFieldW, passwordFieldH)];
    passwordField.secureTextEntry = YES;
    passwordField.backgroundColor = [UIColor clearColor];
    [self.view addSubview:passwordField];
    self.passwordField = passwordField;
    
    UIView *lineView2 =[[UIView alloc] initWithFrame:CGRectMake(usernameField.x, CGRectGetMaxY(passwordField.frame), usernameFieldW, 1)];
    lineView2.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
    [self.view addSubview:lineView2];
    
    UIButton *forgetBtn = [[UIButton alloc] init];
    forgetBtn.width = 80;
    forgetBtn.height = 35;
    forgetBtn.x = ScreenWidth - 105;
    forgetBtn.y = CGRectGetMaxY(lineView2.frame)+ 5;
    forgetBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [forgetBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
    [forgetBtn setTitleColor:[QFTools colorWithHexString:@"#c0c0c0"] forState:UIControlStateNormal];
    [forgetBtn addTarget:self action:@selector(forgetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    forgetBtn.tag = 300 + 2;
    [self.view addSubview:forgetBtn];
    
    UIView *lineView3 =[[UIView alloc] initWithFrame:CGRectMake(forgetBtn.x, CGRectGetMaxY(forgetBtn.frame), forgetBtn.width, 1)];
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
    if ([title isEqualToString:@"请输入手机号"]) {
        
        field.keyboardType = UIKeyboardTypeNumberPad;
        field.clearButtonMode = UITextFieldViewModeWhileEditing;
    }else if ([title isEqualToString:@"请输入密码"]){
    
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
    [field setValue:[QFTools colorWithHexString:@"#adaaa8"] forKeyPath:@"_placeholderLabel.textColor"];
    [field setValue:[UIFont fontWithName:@"Arial" size:14]   forKeyPath:@"_placeholderLabel.font"];
    return field;
}

#pragma mark - 登录按钮
- (void)setupLogBtn
{
    UIButton *logBtn = [[UIButton alloc] init];
    logBtn.frame = CGRectMake(ScreenWidth*.15 , CGRectGetMaxY(self.passwordField.frame) + navHeight, ScreenWidth*.7, 44);
    logBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
    [logBtn setTitle:@"登录" forState:UIControlStateNormal];
    [logBtn setTitleColor:[QFTools colorWithHexString:@"#FFFFFF"] forState:UIControlStateNormal];
    logBtn.titleLabel.font = FONT_YAHEI(16);
    logBtn.contentMode = UIViewContentModeCenter;
    [logBtn.layer setCornerRadius:5.0]; // 切圆角
    [logBtn addTarget:self action:@selector(logBtnBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logBtn];
    self.logBtn = logBtn;
    
}

#pragma mark - 注册按钮
- (void)setupResBtn{
    UIButton *ResBtn = [[UIButton alloc] init];
    ResBtn.frame = CGRectMake(ScreenWidth*.15 , CGRectGetMaxY(self.logBtn.frame) + 44, ScreenWidth*.7, 44);
   // ResBtn.backgroundColor = [QFTools colorWithHexString:@"#2791cf"];
    [ResBtn setTitle:@"新用户注册" forState:UIControlStateNormal];
    [ResBtn setTitleColor:[QFTools colorWithHexString:@"#fdc12b"] forState:UIControlStateNormal];
    ResBtn.layer.borderColor = [QFTools colorWithHexString:MainColor].CGColor;
    ResBtn.layer.borderWidth = 1.0;
    ResBtn.layer.masksToBounds = YES;
    ResBtn.layer.cornerRadius = 12.5;
    ResBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    ResBtn.contentMode = UIViewContentModeCenter;
    [ResBtn.layer setCornerRadius:5.0]; // 切圆角
    [ResBtn addTarget:self action:@selector(registerBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ResBtn];
    ResBtn.tag = 300 + 1;
  
    
}

#pragma mark - 点击登录
- (void)logBtnBtnClick
{
    
    if ([QFTools isBlankString:self.usernameField.text] || [QFTools isBlankString:self.passwordField.text]) {
        [SVProgressHUD showSimpleText:@"请输入账号密码"];
        return;
    }
    
    
    LoadView *loadview = [[LoadView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    loadview.protetitle.text = @"正在登录中";
    [self.view addSubview:loadview];

    NSString *pwd = [NSString stringWithFormat:@"%@%@%@",@"QGJ",self.passwordField.text,@"BLE"];
    NSString * md5=[QFTools md5:pwd];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/login"];
    NSDictionary *parameters = @{@"account": self.usernameField.text, @"passwd": md5.uppercaseString};
    
    AFHTTPSessionManager *manager = [QFTools sharedManager];

    [manager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dict) {
       
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            LoginDataModel *loginModel = [LoginDataModel yy_modelWithDictionary:data];
            NSString * token=loginModel.token;
            NSString * defaultlogo = loginModel.default_brand_logo;
            NSString * defaultimage = loginModel.default_model_picture;
            UserInfoModel *userinfo = loginModel.user_info;
            NSString * birthday=userinfo.birthday;
            NSString * nick_name=userinfo.nick_name;
            NSNumber * gender = [NSNumber numberWithInteger:userinfo.gender];
            NSString * icon = userinfo.icon;
            NSString * realName = userinfo.real_name;
            NSString *idcard = userinfo.id_card_no;
            NSNumber *userId = [NSNumber numberWithInteger:userinfo.user_id];
            
            NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:token,@"token",self.usernameField.text,@"phone_num",self.passwordField.text,@"password",defaultlogo,@"defaultlogo",defaultimage,@"defaultimage",userId,@"userid",nil];
            [USER_DEFAULTS setObject:userDic forKey:logInUSERDIC];
            [USER_DEFAULTS synchronize];
            
            NSDictionary *userDic2 = [NSDictionary dictionaryWithObjectsAndKeys:self.usernameField.text,@"username",birthday,@"birthday",nick_name,@"nick_name",gender,@"gender",icon,@"icon",realName,@"realname",idcard,@"idcard",nil];
            [USER_DEFAULTS setObject:userDic2 forKey:userInfoDic];
            [USER_DEFAULTS synchronize];
            
            [LVFmdbTool deleteBrandData:nil]; 
            [LVFmdbTool deleteBikeData:nil];
            [LVFmdbTool deleteModelData:nil];
            [LVFmdbTool deletePeripheraData:nil];
            [LVFmdbTool deleteFingerprintData:nil];
            
            for (BikeInfoModel *bikeInfo in loginModel.bike_info) {
                
                if (bikeInfo.owner_flag == 1) {
                    child = @"0";
                    main = bikeInfo.passwd_info.main;
                }else if (bikeInfo.owner_flag == 0){
                    
                    child = bikeInfo.passwd_info.children.firstObject;
                    main = @"0";
                }
                
                NSString *logo = bikeInfo.brand_info.logo;
                NSString *picture_b = bikeInfo.model_info.picture_b;
                
                BikeModel *pmodel = [BikeModel modalWith:bikeInfo.bike_id bikename:bikeInfo.bike_name ownerflag:bikeInfo.owner_flag hwversion:bikeInfo.hw_version firmversion:bikeInfo.firm_version keyversion:bikeInfo.key_version mac:bikeInfo.mac mainpass:main password:child bindedcount:bikeInfo.binded_count ownerphone:bikeInfo.owner_phone];
                [LVFmdbTool insertBikeModel:pmodel];
                
                if (bikeInfo.brand_info.brand_id == 0) {
                    logo = defaultlogo;
                }
                
                BrandModel *bmodel = [BrandModel modalWith:bikeInfo.bike_id brandid:bikeInfo.brand_info.brand_id brandname:bikeInfo.brand_info.brand_name logo:logo];
                [LVFmdbTool insertBrandModel:bmodel];
                
                if (bikeInfo.model_info.model_id == 0) {
                    picture_b = defaultimage;
                }
                
                ModelInfo *Infomodel = [ModelInfo modalWith:bikeInfo.bike_id modelid:bikeInfo.model_info.model_id modelname:bikeInfo.model_info.model_name batttype:bikeInfo.model_info.batt_type battvol:bikeInfo.model_info.batt_vol wheelsize:bikeInfo.model_info.wheel_size brandid:bikeInfo.model_info.brand_id pictures:bikeInfo.model_info.picture_s pictureb:bikeInfo.model_info.picture_b];
                [LVFmdbTool insertModelInfo:Infomodel];
                
                for (DeviceInfoModel *device in bikeInfo.device_info){
                    
                    PeripheralModel *permodel = [PeripheralModel modalWith:bikeInfo.bike_id deviceid:device.device_id type:device.type seq:device.seq mac:device.mac sn:device.sn firmversion:device.firm_version];
                    [LVFmdbTool insertDeviceModel:permodel];
                }
                
                for (FingerModel *fpsInfo in bikeInfo.fps){
                    
                    FingerprintModel *fingermodel = [FingerprintModel modalWith:bikeInfo.bike_id fp_id:fpsInfo.fp_id pos:fpsInfo.pos name:fpsInfo.name added_time:fpsInfo.added_time];
                    [LVFmdbTool insertFingerprintModel:fingermodel];
                }
            }
            
            NSMutableArray *bikeAry = [LVFmdbTool queryBikeData:nil];
            
            if (bikeAry.count > 0) {
                BikeModel *firstbikeinfo = bikeAry[0];
                [USER_DEFAULTS setValue:firstbikeinfo.mac.uppercaseString forKey:SETRSSI];
            }
            
            NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
            NSString* phoneModel = [[UIDevice currentDevice] model];
            NSString* identifierNumber = [[UIDevice currentDevice].identifierForVendor UUIDString] ;
            NSString*modelname =[NSString stringWithFormat:@"%@|%@|%@",phoneModel,phoneVersion,identifierNumber];
            NSString *regid = [JPUSHService registrationID];
            NSNumber *chanel = [NSNumber numberWithInt:1];
            
            if (regid == nil) {
                regid = @"";
            }
            
            NSString *URLString2 = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/pushonline"];
            NSDictionary *parameters2 = @{@"token": token, @"device_name": modelname,@"channel": chanel,@"reg_id": regid};
            
            [manager POST:URLString2 parameters:parameters2 progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dict) {
                
                SDWebImageManager *manager2 = [SDWebImageManager sharedManager];
                NSURL *url=[NSURL URLWithString:icon];
                [manager2 downloadImageWithURL:url options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    
                    //NSLog(@"显示当前进度");
                    
                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    
                    [loadview removeFromSuperview];
                    NSData *fileData = [[NSData alloc] init];
                    NSString *imageName = @"currentImage.png";
                    fileData = UIImageJPEGRepresentation(image, 0.5);
                    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
                    [fileData writeToFile:fullPath atomically:NO];
                    
                    [NSNOTIC_CENTER postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
                }];
                
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"error :%@",error);
                [loadview removeFromSuperview];
                [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
            }];

        }else if([dict[@"status"] intValue] == 1001){
            [loadview removeFromSuperview];
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }else{
            [loadview removeFromSuperview];
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
        [loadview removeFromSuperview];
    }];
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

#pragma mark - pop
- (void)leftBtnClick:(UIButton *)btn
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 找回密码
- (void)forgetBtnClick:(UIButton *)btn
{
    [self.view endEditing:YES];
    ForgetViewController *forgetVc = [[ForgetViewController alloc] init];
    [self.navigationController pushViewController:forgetVc animated:YES];
    
}

#pragma mark - 注册
- (void)registerBtnClick:(UIButton *)btn
{
    [self.view endEditing:YES];
    
    [self.navigationController pushViewController:[MobileViewController new] animated:YES];
}

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


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //设置动画的名字
    [UIView beginAnimations:@"Animation" context:nil];
    //设置动画的间隔时间
    [UIView setAnimationDuration:0.20];
    //??使用当前正在运行的状态开始下一段动画
    [UIView setAnimationBeginsFromCurrentState: YES];
    //设置视图移动的位移
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 100, self.view.frame.size.width, self.view.frame.size.height);
    //设置动画结束
    [UIView commitAnimations];
}
//在UITextField 编辑完成调用方法
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //设置动画的名字
    [UIView beginAnimations:@"Animation" context:nil];
    //设置动画的间隔时间
    [UIView setAnimationDuration:0.20];
    //??使用当前正在运行的状态开始下一段动画
    [UIView setAnimationBeginsFromCurrentState: YES];
    //设置视图移动的位移
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 100, self.view.frame.size.width, self.view.frame.size.height);
    //设置动画结束
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (self.usernameField.text.length && self.passwordField.text.length) {
        self.logBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
    }else {
        self.logBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
    }
    return YES;
    
}

-(void)dealloc{

}

@end
