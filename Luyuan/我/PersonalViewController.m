//
//  PersonalViewController.m
//  阿尔卑斯
//
//  Created by 同时科技 on 16/4/6.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "PersonalViewController.h"
#import "NSDate+HC.h"
#import "PhotoPickerManager_Edit.h"
#import "TFSheetView.h"
#import "PickerChoiceView.h"

@interface PersonalViewController ()<UITextFieldDelegate,UIAlertViewDelegate,TFSheetViewDelegate,TFPickerDelegate>
    {
        NSMutableArray *pickerArray;
    }
    @property (nonatomic,weak) UITextField *nicknameField;
    @property (nonatomic,weak) UILabel *birthDayLab;
    @property (nonatomic,weak) UITextField *relaNmeField;
    @property (nonatomic,weak) UILabel *idCardField;
    @property (nonatomic, copy) NSString *birthTime;
    
    @property (nonatomic, strong) NSString *gender;
    @property (nonatomic, weak) UIImageView *userIcon;
    @property (weak, nonatomic) UIPickerView *pickerView;
    @property (nonatomic, weak) UIView *picview;
    @property (nonatomic, weak) UILabel *manLabel;
    @property (nonatomic, strong) TFSheetView *tfSheetView;
    @property (nonatomic, strong)UIAlertView *individuaAlertView;
    @end

@implementation PersonalViewController
    
- (void)viewWillAppear:(BOOL)animated
    {
        [super viewWillAppear:animated];
    }
    
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    
    @weakify(self);
    [self configureNavgationItemTitle:@"个人信息"];
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
    [self configureRightBarButtonWithTitle:@"保存" action:^{
        @strongify(self);
        if (self.nicknameField.text.length >10) {
            [SVProgressHUD showSimpleText:@"昵称长度不能超过10"];
            return;
        }
        
        if (self.relaNmeField.text.length >5) {
            [SVProgressHUD showSimpleText:@"真实姓名长度不能超过5"];
            return;
        }
        [SVProgressHUD showSimpleText:@"保存中"];
        [self saveBtnClick];
        
    }];
    
    [self initFootView];
    
}
    
- (void)saveBtnClick{
    
    NSString *realname = @"";
    NSString *idcard = @"";
    NSString *nickname = self.nicknameField.text;
    NSString *birthday = self.birthDayLab.text;
    NSString *token = [QFTools getdata:@"token"];
    NSString *base64 = [QFTools image2String:self.userIcon.image];
    if (base64 == nil) {
        base64 =  @"";
    }
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/updateuserprofile"];
    NSDictionary *parameters = @{@"token":token, @"birthday":birthday,@"nick_name":nickname,@"icon":base64,@"gender":self.gender,@"real_name":realname,@"id_card_no":idcard};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSData *fileData = [[NSData alloc] init];
            NSString *imageName = @"currentImage.png";
            fileData = UIImageJPEGRepresentation(self.userIcon.image, 1.0f);
            NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
            [fileData writeToFile:fullPath atomically:NO];
            
            [SVProgressHUD showSimpleText:@"修改成功"];
            NSDictionary *data = dict[@"data"];
            NSString *icon = data[@"icon"];
            
            NSNumber * gender = @([self.gender integerValue]);
            
            NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:[QFTools getdata:@"phone_num"],@"username",self.birthDayLab.text,@"birthday",self.nicknameField.text,@"nick_name",gender,@"gender",icon,@"icon",self.relaNmeField.text,@"realname",self.idCardField.text,@"idcard",nil];
            [USER_DEFAULTS setObject:userDic forKey:userInfoDic];
            [USER_DEFAULTS synchronize];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        else if([dict[@"status"] intValue] == 1001){
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }else{
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        
    }];
}
    
    
- (void)iconImageClicked:(UITapGestureRecognizer *)gesture {
    
    WS(weakSelf);
    
    [[PhotoPickerManager_Edit shared]showActionSheetInView:self.view fromController:self completion:^(NSArray *image) {
        weakSelf.userIcon.layer.cornerRadius = weakSelf.userIcon.frame.size.width/2;
        weakSelf.userIcon.clipsToBounds = YES;
        [weakSelf.userIcon setImage:image[0]];
        [SVProgressHUD showSimpleText:@"保存中"];
        [weakSelf saveBtnClick];
        
    } cancelBlock:^{
        
    } maxCount:1];
    
}
    
- (void)initFootView{
    
    UIView *iconImage = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight *.13)];
    iconImage.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:iconImage];
    
    UITapGestureRecognizer *takePhotoTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(iconImageClicked:)];
    takePhotoTap.numberOfTapsRequired = 1;
    [iconImage addGestureRecognizer:takePhotoTap];
    
    UILabel *cameraName = [[UILabel alloc] initWithFrame:CGRectMake(15 , 10, 45, 20)];
    cameraName.font = [UIFont systemFontOfSize:15];
    cameraName.textColor = [UIColor blackColor];
    cameraName.text = @"头像";
    cameraName.y = iconImage.height/2 - 10;
    cameraName.textAlignment = NSTextAlignmentLeft;
    [iconImage addSubview:cameraName];
    
    UIView *userimageback = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth - iconImage.height*2/3 - 42.5, iconImage.height/6 - 2.5, iconImage.height*2/3+5, iconImage.height*2/3+5)];
    userimageback.backgroundColor = [QFTools colorWithHexString:MainColor];
    userimageback.layer.masksToBounds = YES;
    userimageback.layer.cornerRadius = userimageback.height/2;
    [iconImage addSubview:userimageback];
    
    UIImageView *userIcon = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - iconImage.height*2/3 - 40, iconImage.height/6, iconImage.height*2/3, iconImage.height*2/3)];
    userIcon.backgroundColor = [UIColor whiteColor];
    userIcon.layer.masksToBounds = YES;
    userIcon.layer.cornerRadius = iconImage.height*2/6;
    if (![QFTools getphoto]) {
        
        NSURL *url=[NSURL URLWithString:[QFTools getuserInfo:@"icon"]];
        [userIcon sd_setImageWithURL:url];
        
    }else{
        
        userIcon.image = [QFTools getphoto];
        
    }
    [iconImage addSubview:userIcon];
    self.userIcon = userIcon;
    
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 20, iconImage.height/2 - 7.5, 8.4, 15)];
    arrow.image = [UIImage imageNamed:@"arrow"];
    [iconImage addSubview:arrow];
    
    
    UIView *nickname = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(iconImage.frame), ScreenWidth, 45)];
    nickname.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:nickname];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(15 , 12.5, 45, 20)];
    name.font = [UIFont systemFontOfSize:15];
    name.textColor = [UIColor blackColor];
    name.text = @"昵称";
    name.textAlignment = NSTextAlignmentLeft;
    [nickname addSubview:name];
    
    UITextField *nicknameField = [self addOneTextFieldWithTitle:nil imageName:nil imageNameWidth:10 Frame:CGRectMake(ScreenWidth - 260, 5,  220, 35)];
    nicknameField.backgroundColor = [UIColor clearColor];
    nicknameField.text = [QFTools getuserInfo:@"nick_name"];
    nicknameField.font = [UIFont systemFontOfSize:14];
    nicknameField.textColor = [QFTools colorWithHexString:@"#999999"];
    [nickname addSubview:nicknameField];
    self.nicknameField = nicknameField;
    
    UIImageView *arrow2 = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 20, 15, 8.4, 15)];
    arrow2.image = [UIImage imageNamed:@"arrow"];
    [nickname addSubview:arrow2];
    
    UIView *phone = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(nickname.frame), ScreenWidth, 45)];
    phone.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:phone];
    
    UILabel *modelLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 12.5, 80, 20)];
    modelLable.text = @"手机";
    modelLable.textColor = [UIColor blackColor];
    modelLable.textAlignment = NSTextAlignmentLeft;
    modelLable.font = [UIFont systemFontOfSize:15];
    [phone addSubview:modelLable];
    
    UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 140, 12.5, 100, 20)];
    typeLabel.text = [NSString stringWithFormat:@"%@",[QFTools getdata:@"phone_num"]];
    typeLabel.textAlignment = NSTextAlignmentRight;
    typeLabel.font = [UIFont systemFontOfSize:14];
    typeLabel.textColor = [QFTools colorWithHexString:@"#999999"];
    [phone addSubview:typeLabel];
    
    UIImageView *arrow3 = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 20, 15, 8.4, 15)];
    arrow3.image = [UIImage imageNamed:@"arrow"];
    //[phone addSubview:arrow3];
    
    UIView *birthDay = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(phone.frame), ScreenWidth, 45)];
    birthDay.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:birthDay];
    
    UILabel *birthLable = [[UILabel alloc] initWithFrame:CGRectMake(15 , 12.5, 45, 20)];
    birthLable.text = @"生日";
    birthLable.textColor = [UIColor blackColor];
    birthLable.textAlignment = NSTextAlignmentLeft;
    birthLable.font = [UIFont systemFontOfSize:15];
    [birthDay addSubview:birthLable];
    
    UILabel *birthDayLab = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 260, 5,  220, 35)];
    birthDayLab.textColor = [QFTools colorWithHexString:@"#999999"];
    birthDayLab.textAlignment = NSTextAlignmentRight;
    birthDayLab.font = [UIFont systemFontOfSize:14];
    birthDayLab.text = [QFTools getuserInfo:@"birthday"];
    [birthDay addSubview:birthDayLab];
    self.birthDayLab = birthDayLab;
    birthDayLab.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(birthDayTap)];
    [birthDay addGestureRecognizer:tap2];
    
    
    UIImageView *arrow4 = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 20, 15, 8.4, 15)];
    arrow4.image = [UIImage imageNamed:@"arrow"];
    [birthDay addSubview:arrow4];
    
    UIView *gender = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(birthDay.frame), ScreenWidth, 45)];
    gender.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:gender];
    
    UILabel *genderLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 12.5, 45, 20)];
    genderLable.text = @"性别";
    genderLable.textColor = [UIColor blackColor];
    genderLable.textAlignment = NSTextAlignmentLeft;
    genderLable.font = [UIFont systemFontOfSize:15];
    [gender addSubview:genderLable];
    
    NSString *sex;
    if ([QFTools getuserInfo:@"gender"].intValue ==1 ) {
        
        self.gender = @"1";
        sex = @"男";
    }else{
        
        sex = @"女";
        self.gender = @"2";
    }
    
    UILabel *manLabel = [self addOneLabelWithText:sex];
    manLabel.font = [UIFont systemFontOfSize:14];
    manLabel.width = 100;
    manLabel.height = 20;
    manLabel.x = ScreenWidth - 140;
    manLabel.y = 12.5;
    manLabel.textAlignment = NSTextAlignmentRight;
    manLabel.textColor = [QFTools colorWithHexString:@"#999999"];
    [gender addSubview:manLabel];
    self.manLabel = manLabel;
    manLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTap)];
    [gender addGestureRecognizer:tap1];
    
    UIImageView *arrow5 = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 20, 15, 8.4, 15)];
    arrow5.image = [UIImage imageNamed:@"arrow"];
    [gender addSubview:arrow5];
    
    UIView *partingline = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(iconImage.frame), ScreenWidth-15, 0.5)];
    partingline.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
    [self.view addSubview:partingline];
    
    UIView *partingline2 = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(nickname.frame), ScreenWidth-15, 0.5)];
    partingline2.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
    [self.view addSubview:partingline2];
    
    UIView *partingline3 = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(phone.frame), ScreenWidth-15, 0.5)];
    partingline3.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
    [self.view addSubview:partingline3];
    
    UIView *partingline4 = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(birthDay.frame), ScreenWidth-15, 0.5)];
    partingline4.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
    [self.view addSubview:partingline4];
    
    UIView *partingline5 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(gender.frame), ScreenWidth, 0.5)];
    partingline5.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
    [self.view addSubview:partingline5];
    
    UIButton *individuaBtn = [[UIButton alloc] init];
    individuaBtn.width = ScreenWidth - 150;
    individuaBtn.height = 40;
    individuaBtn.x = 75;
    individuaBtn.y = ScreenHeight - navHeight - 120;
    individuaBtn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.05];
    [individuaBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [individuaBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    individuaBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
    individuaBtn.contentMode = UIViewContentModeCenter;
    [individuaBtn.layer setCornerRadius:8.0]; // 切圆角
    [individuaBtn addTarget:self action:@selector(signout) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:individuaBtn];
    
}
    
    
-(void)birthDayTap{
    
    PickerChoiceView *picker = [[PickerChoiceView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    picker.delegate = self;
    picker.arrayType = DeteArray;
    picker.selectStr  = self.birthDayLab.text;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:picker];
}
    
#pragma mark -------- TFPickerDelegate
    
- (void)PickerSelectorIndixString:(NSString *)str{
    
    self.birthDayLab.text = str;
}
    
- (void)PickerSelectorIndixColour:(UIColor *)color{
    
    NSLog(@"p----%@",color);
}
    
    
- (void)labelTap
    {
        
        _tfSheetView = [[TFSheetView alloc]init];
        _tfSheetView.delegate = self;
        [_tfSheetView showInView:self.view];
    }
    
-(void)TFSheetViewchooseSex:(NSString *)sexLab{
    self.manLabel.text  = sexLab;
    if ([sexLab isEqualToString:@"男"]) {
        
        self.gender = @"1";
    }else if ([sexLab isEqualToString:@"女"]){
        self.gender = @"2";
    }
    
}
    
    
- (UILabel *)addOneLabelWithText:(NSString *)text
    {
        UILabel *tempLabel = [[UILabel alloc] init];
        tempLabel.font = FONT_YAHEI(15);
        //    tempLabel.backgroundColor = [UIColor raspberryColor];
        tempLabel.text = text;
        return tempLabel;
    }
    
-(NSString *)replaceStringWithAsterisk:(NSString *)originalStr startLocation:(NSInteger)startLocation lenght:(NSInteger)lenght
    {
        NSString *newStr = originalStr;
        for (int i = 0; i < lenght; i++) {
            NSRange range = NSMakeRange(startLocation, 1);
            newStr = [newStr stringByReplacingCharactersInRange:range withString:@"*"];
            startLocation ++;
        }
        return newStr;
    }
    
#pragma mark - 添加输入框
- (UITextField *)addOneTextFieldWithTitle:(NSString *)title imageName:(NSString *)imageName imageNameWidth:(CGFloat)width Frame:(CGRect)rect
    {
        UITextField *field = [[UITextField alloc] init];
        field.frame = rect;
        field.backgroundColor = [UIColor whiteColor];
        field.borderStyle = UITextBorderStyleNone;
        field.returnKeyType = UIReturnKeyDone;
        field.autocorrectionType = UITextAutocorrectionTypeNo;
        field.autocapitalizationType = UITextAutocapitalizationTypeNone;
        //    [usernameField becomeFirstResponder];
        // field.keyboardType = UIKeyboardTypeNumberPad;
        field.delegate = self;
        //  field.textColor = [QFTools colorWithHexString:@"#333333"];
        // 设置内容居中
        field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        field.textAlignment = NSTextAlignmentRight;
        field.leftViewMode = UITextFieldViewModeAlways;
        // 设置清除按钮
        field.clearButtonMode = UITextFieldViewModeWhileEditing;
        // 占位符
        field.placeholder = title;
        return field;
    }
    
-(void)signout{
    
    self.individuaAlertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否退出" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    self.individuaAlertView.tag =4000;
    [self.individuaAlertView show];
    
}
    
    
#pragma mark - UIAlertViewDelegate
    
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
    {
        if (alertView.tag == 4000) {
            if (buttonIndex != [alertView cancelButtonIndex]) {
                [self individuaBtnClick];
            }
        }
    }
    
    
- (void)individuaBtnClick
    {
        LoadView *loadview = [[LoadView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - navHeight)];
        loadview.leftx = ScreenWidth *0.3;
        loadview.protetitle.text = @"退出中";
        loadview.undery = 84;
        [self.view addSubview:loadview];
        [AppDelegate currentAppDelegate].isPop = NO;
        [LVFmdbTool deleteBrandData:nil];
        [LVFmdbTool deleteBikeData:nil];
        [LVFmdbTool deleteModelData:nil];
        [LVFmdbTool deletePeripheraData:nil];
        [self logoutApp];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [USER_DEFAULTS removeObjectForKey:logInUSERDIC];
            [USER_DEFAULTS synchronize];
            [loadview removeFromSuperview];
            [[AppDelegate currentAppDelegate].device remove];
            [USER_DEFAULTS removeObjectForKey:SETRSSI];
            [USER_DEFAULTS removeObjectForKey:Key_DeviceUUID];
            [USER_DEFAULTS removeObjectForKey:Key_MacSTRING];
            [USER_DEFAULTS removeObjectForKey:passwordDIC];
            [USER_DEFAULTS synchronize];
            
            [AppDelegate currentAppDelegate]. device.deviceStatus=0;
            [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_UpdateDeviceStatus object:nil]];
            
            NSFileManager * fileManager = [[NSFileManager alloc]init];
            NSString *imageName = @"currentImage.png";
            NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
            [fileManager removeItemAtPath:fullPath error:nil];
            [NSNOTIC_CENTER postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
            
        });
    }
    
-(void)logoutApp{
    
    NSString *token= [QFTools getdata:@"token"];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/logout"];
    NSDictionary *parameters = @{@"token": token};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        
    }failure:^(NSError *error) {
        NSLog(@"error :%@",error);
        
    }];
    
}
    
-(void)dealloc{
    
    [self.individuaAlertView dismissWithClickedButtonIndex:0 animated:YES];
}
    
-(void)backView{
    
    [self.navigationController popViewControllerAnimated:YES];
    
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
