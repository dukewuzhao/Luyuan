//
//  ImprovePersonalViewController.m
//  阿尔卑斯
//
//  Created by 同时科技 on 16/4/14.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "ImprovePersonalViewController.h"
#import "NSDate+HC.h"
#import "TFSheetView.h"
#import "PickerChoiceView.h"
#import "PhotoPickerManager_Edit.h"
@interface ImprovePersonalViewController ()<UITextFieldDelegate,UITextViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,TFSheetViewDelegate,TFPickerDelegate>

@property (nonatomic, copy) NSString *birthTime;
@property (nonatomic, weak) UILabel *manLabel;
@property (nonatomic, weak)UILabel *birthDayLab;
@property (nonatomic,weak) UITextField *nicknameField;
//@property (nonatomic,weak) UITextField *birthField;
@property (nonatomic,weak) UITextField *relaNmeField;
@property (nonatomic,weak) UITextField *idCardField;
@property (nonatomic, weak) UIImageView *mainusericon;
@property (nonatomic, weak) UIImageView *dotImage1;
@property (nonatomic, weak) UIImageView *doImage1;
@property (nonatomic,copy) NSString *gender;
@property (nonatomic, strong) TFSheetView *tfSheetView;
@end

@implementation ImprovePersonalViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    
    WS(weakSelf);
    
    [self configureNavgationItemTitle:@"注册信息"];
    
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@""] action:^{
        
        
    }];

    [self configureRightBarButtonWithTitle:@"跳过" action:^{
        
        [weakSelf improveSaveBtnClick];
        
    }];
    
    [self setupHeadView];
    
}



- (void)setupHeadView{
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0,0 , ScreenWidth, ScreenHeight * 0.3)];
    [self.view addSubview:headView];
    
    UIImageView *headimage = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - headView.height *.275, headView.height/2 - headView.height *.275, headView.height *.55, headView.height *.55)];
    headimage.userInteractionEnabled = YES;
    headimage.backgroundColor = [UIColor whiteColor];
    headimage.layer.masksToBounds = YES;
    headimage.layer.cornerRadius = headimage.height/2;
    headimage.backgroundColor = [QFTools colorWithHexString:MainColor];
    [headView addSubview:headimage];
    
    UIImageView *mainusericon = [[UIImageView alloc] initWithFrame:CGRectMake(2.5, 2.5, headimage.width - 5 , headimage.height - 5)];
    mainusericon.image = [UIImage imageNamed:@"small_default_imag2"];
    mainusericon.layer.masksToBounds = YES;
    mainusericon.userInteractionEnabled = YES;
    mainusericon.layer.cornerRadius = mainusericon.height/2;
    [headimage addSubview:mainusericon];
    self.mainusericon = mainusericon;
    
    UITapGestureRecognizer *takePhotoTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mainusericonImageClicked:)];
    takePhotoTap.numberOfTapsRequired = 1;
    [mainusericon addGestureRecognizer:takePhotoTap];
    
    UIView *nickname = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headView.frame) + 20, ScreenWidth, 45)];
    nickname.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:nickname];
    
    UIImageView *nickIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 25, 25)];
    nickIcon.layer.masksToBounds = YES;
    nickIcon.image = [UIImage imageNamed:@"user_icon_ig"];
    [nickname addSubview:nickIcon];
    
    UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(nickIcon.frame) +10, 12.5, 60, 20)];
    name.font = [UIFont systemFontOfSize:14];
    name.text = @"昵称";
    name.textColor = [UIColor blackColor];
    name.textAlignment = NSTextAlignmentLeft;
    [nickname addSubview:name];
    
    UITextField *nicknameField = [self addOneTextFieldWithTitle:nil imageName:nil imageNameWidth:10 Frame:CGRectMake(CGRectGetMaxX(name.frame), 5, ScreenWidth - 140, 35)];
    nicknameField.backgroundColor = [UIColor clearColor];
    nicknameField.text = [NSString stringWithFormat:@"%@",[QFTools getdata:@"phone_num"]];
    nicknameField.textColor = [QFTools colorWithHexString:@"999999"];
    [nickname addSubview:nicknameField];
    self.nicknameField = nicknameField;
    
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 20, 15, 8.4, 15)];
    arrow.image = [UIImage imageNamed:@"arrow"];
    [nickname addSubview:arrow];
    
    UIView *birthDay = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(nickname.frame), ScreenWidth, 45)];
    birthDay.backgroundColor =[UIColor whiteColor];
    [self.view addSubview:birthDay];
    
    UIImageView *birthIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 25, 25)];
    birthIcon.image = [UIImage imageNamed:@"icon_birth"];
    [birthDay addSubview:birthIcon];
    
    UILabel *birthLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(birthIcon.frame)+10, 12.5, 60, 20)];
    birthLable.text = @"生日";
    birthLable.textColor = [UIColor blackColor];
    birthLable.textAlignment = NSTextAlignmentLeft;
    birthLable.font = [UIFont systemFontOfSize:14];
    [birthDay addSubview:birthLable];
    
    UILabel *birthDayLab = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 260, 5,  220, 35)];
    birthDayLab.textColor = [QFTools colorWithHexString:@"999999"];
    birthDayLab.textAlignment = NSTextAlignmentRight;
    birthDayLab.font = [UIFont systemFontOfSize:14];
    birthDayLab.text = [[QFTools replyDataAndTime] substringWithRange:NSMakeRange(0, 10)];
    [birthDay addSubview:birthDayLab];
    self.birthDayLab = birthDayLab;
    birthDayLab.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ImprovebirthDayTap)];
    [birthDay addGestureRecognizer:tap2];
    
    UIImageView *arrow2 = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 20, 15, 8.4, 15)];
    arrow2.image = [UIImage imageNamed:@"arrow"];
    [birthDay addSubview:arrow2];
    
    UIView *gender = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(birthDay.frame), ScreenWidth, 45)];
    gender.backgroundColor =[UIColor whiteColor];
    [self.view addSubview:gender];
    
    UIImageView *genderIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 25, 25)];
    genderIcon.image = [UIImage imageNamed:@"icon_sex"];
    [gender addSubview:genderIcon];
    
    UILabel *genderLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(genderIcon.frame)+10, 12.5, 60, 20)];
    genderLable.text = @"性别";
    genderLable.textColor = [UIColor blackColor];
    genderLable.textAlignment = NSTextAlignmentLeft;
    genderLable.font = [UIFont systemFontOfSize:14];
    [gender addSubview:genderLable];
    
    UILabel *manLabel = [self addOneLabelWithText:@"男"];
    manLabel.font = [UIFont systemFontOfSize:14];
    manLabel.width = 100;
    manLabel.height = 20;
    manLabel.x = ScreenWidth - 140;
    manLabel.y = 12.5;
    manLabel.textAlignment = NSTextAlignmentRight;
    manLabel.textColor = [QFTools colorWithHexString:@"999999"];
    [gender addSubview:manLabel];
    self.manLabel = manLabel;
    manLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sexlabelTap)];
    [gender addGestureRecognizer:tap];
    
    UIImageView *arrow3 = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 20, 15, 8.4, 15)];
    arrow3.image = [UIImage imageNamed:@"arrow"];
    [gender addSubview:arrow3];
    
    UIView *partingline = [[UIView alloc] initWithFrame:CGRectMake(0, nickname.y, ScreenWidth, 0.5)];
    partingline.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
    [self.view addSubview:partingline];
    
    UIView *partingline2 = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(nickname.frame), ScreenWidth-15, 0.5)];
    partingline2.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
    [self.view addSubview:partingline2];
    
    UIView *partingline3 = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(birthDay.frame), ScreenWidth-15, 0.5)];
    partingline3.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
    [self.view addSubview:partingline3];
    
    UIView *partingline4 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(gender.frame), ScreenWidth, 0.5)];
    partingline4.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
    [self.view addSubview:partingline4];
    
    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(35, CGRectGetMaxY(gender.frame) +50, ScreenWidth - 70, 40)];
    [saveBtn setTitle:@"提交" forState:UIControlStateNormal];
    saveBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(improveSaveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [saveBtn.layer setCornerRadius:5.0]; // 切圆角
    [self.view addSubview:saveBtn];
}

- (UILabel *)addOneLabelWithText:(NSString *)text
{
    UILabel *tempLabel = [[UILabel alloc] init];
    tempLabel.font = FONT_YAHEI(15);
    //    tempLabel.backgroundColor = [UIColor raspberryColor];
    tempLabel.text = text;
    return tempLabel;
}

- (void)sexlabelTap{

    _tfSheetView = [[TFSheetView alloc]init];
    _tfSheetView.delegate = self;
    [_tfSheetView showInView:self.view];
    
}

-(void)ImprovebirthDayTap{
    
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


-(void)TFSheetViewchooseSex:(NSString *)sexLab{
    self.manLabel.text  = sexLab;
    if ([sexLab isEqualToString:@"男"]) {
        
        self.gender = @"1";
    }else if ([sexLab isEqualToString:@"女"]){
        self.gender = @"2";
    }

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

- (void)mainusericonImageClicked:(UITapGestureRecognizer *)gesture{

    WS(weakSelf);
    
    [[PhotoPickerManager_Edit shared]showActionSheetInView:self.view fromController:self completion:^(NSArray *image) {
        weakSelf.mainusericon.layer.cornerRadius = weakSelf.mainusericon.frame.size.width/2;
        weakSelf.mainusericon.clipsToBounds = YES;
        [weakSelf.mainusericon setImage:image[0]];
        
    } cancelBlock:^{
        
        
        
    } maxCount:1];

}


- (void)improveSaveBtnClick{
    
    if ([QFTools isBlankString:self.nicknameField.text]) {
        [SVProgressHUD showSimpleText:@"请输入昵称"];
        return;
    }else if([QFTools isBlankString:self.birthDayLab.text]){
    
        [SVProgressHUD showSimpleText:@"请输入生日"];
        return;
    
    }
    
    NSData *fileData = [[NSData alloc] init];
    NSString *imageName = @"currentImage.png";
    fileData = UIImageJPEGRepresentation(self.mainusericon.image, 0.5);
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    [fileData writeToFile:fullPath atomically:NO];
    
    LoadView *loadview = [[LoadView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    loadview.protetitle.text = @"正在登录中...";
    [self.view addSubview:loadview];
    
    if (self.dotImage1.hidden == 0) {
        
        self.gender = @"1";
    }else{
        self.gender = @"2";
    }
    
    NSString *token = [QFTools getdata:@"token"];
    NSString *_encodedImageStr = [QFTools image2String:self.mainusericon.image];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/updateuserprofile"];
    NSDictionary *parameters = @{@"token":token, @"birthday": self.birthDayLab.text,@"nick_name": self.nicknameField.text,@"icon": _encodedImageStr,@"gender":self.gender,@"real_name":@"",@"id_card_no":@""};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            [loadview removeFromSuperview];
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
            NSDictionary *data = dict[@"data"];
            NSString *icon = data[@"icon"];
            NSNumber * gender = @([self.gender integerValue]);
            
            NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:[QFTools getdata:@"phone_num"],@"username",self.birthDayLab.text,@"birthday",self.nicknameField.text,@"nick_name",gender,@"gender",icon,@"icon",@"",@"realname",@"",@"idcard",nil];
            [USER_DEFAULTS setObject:userDic forKey:userInfoDic];
            [USER_DEFAULTS synchronize];
            
            //发送自动登陆状态通知
            [NSNOTIC_CENTER postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
            
        }
        else if([dict[@"status"] intValue] == 1001){
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }else{
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
        
    }];
}



#pragma mark - 添加输入框方法
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
    //    [usernameField becomeFirstResponder];
    field.delegate = self;
    field.textColor = [QFTools colorWithHexString:@"#333333"];
    field.font = [UIFont systemFontOfSize:14];
    // 设置内容居中
    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field.textAlignment = NSTextAlignmentRight;
    field.leftViewMode = UITextFieldViewModeAlways;
    // 设置清除按钮
    field.clearButtonMode = UITextFieldViewModeWhileEditing;
    return field;
}


#pragma mark - 点击屏幕取消键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
    
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
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - 120, self.view.frame.size.width, self.view.frame.size.height);
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
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 120, self.view.frame.size.width, self.view.frame.size.height);
    //设置动画结束
    [UIView commitAnimations];
}

#pragma mark - 压缩图片 200*200
- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,50,50)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)backView{
   // [self.navigationController popToRootViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
