//
//  ManualInputViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2017/11/13.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "ManualInputViewController.h"
#import "BottomBtn.h"

@interface ManualInputViewController ()<UITextFieldDelegate>
{
    NSMutableDictionary *deviceDic;
}
@property (nonatomic,weak) UITextField *importField;
@property (nonatomic,weak) UIButton *sureBtn;
@end

@implementation ManualInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureNavgationItemTitle:@"绑定智能配件"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configureLeftBarButtonWithImage:nil action:^{
       
    }];
    
    @weakify(self);
    [self configureRightBarButtonWithImage:[UIImage imageNamed:@"signout_input"] action:^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [self setupView];
}

-(void)setupView{
    
    UILabel *PromptLal = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, ScreenWidth - 100, 20)];
    PromptLal.text = @"请输入正确的SN";
    PromptLal.textColor = [QFTools colorWithHexString:@"#666666"];
    PromptLal.font = [UIFont systemFontOfSize:12];
    PromptLal.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:PromptLal];
    
    @weakify(self);
    UITextField *importField = [self addOneTextFieldWithTitle:@"请输入SN" imageName:nil imageNameWidth:10 Frame:CGRectMake(40, 85, ScreenWidth - 80, 35)];
    importField.textColor = [UIColor blackColor];
    importField.layer.borderColor = [QFTools colorWithHexString:MainColor].CGColor;
    importField.layer.borderWidth = 1.0;
    [importField.layer setCornerRadius:5.0];
    [importField.rac_textSignal subscribeNext:^(id x) {
        @strongify(self);
        NSString *a= x;
        if (a.length >0) {
            [self.sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.sureBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
        }else{
            [self.sureBtn setTitleColor:[QFTools colorWithHexString:@"#666666"] forState:UIControlStateNormal];
            self.sureBtn.backgroundColor = [QFTools colorWithHexString:@"#d9d9d9"];
        }
        
    }];
    [self.view addSubview:importField];
    self.importField = importField;
    
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(importField.x, CGRectGetMaxY(importField.frame) + 20, importField.width, 35)];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn.layer setCornerRadius:5.0];
    sureBtn.backgroundColor = [QFTools colorWithHexString:@"#666666"];
    [self.view addSubview:sureBtn];
    self.sureBtn = sureBtn;
    
    BottomBtn *SwitchBtn = [[BottomBtn alloc] init];
    SwitchBtn.direction = @"left";
    SwitchBtn.width = 90;
    SwitchBtn.height = 35;
    SwitchBtn.x = ScreenWidth/2 - 45;
    SwitchBtn.y = CGRectGetMaxY(sureBtn.frame) + 75;
    [SwitchBtn setTitle:@"切换扫码" forState:UIControlStateNormal];
    [SwitchBtn setTitleColor:[QFTools colorWithHexString:@"#666666"] forState:UIControlStateNormal];
    [SwitchBtn setImage:[UIImage imageNamed:@"sweep_codes"] forState:UIControlStateNormal];
    SwitchBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    SwitchBtn.contentMode = UIViewContentModeCenter;
    [SwitchBtn addTarget:self action:@selector(SwitchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    SwitchBtn.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:SwitchBtn];
    
    UIView *partingline = [[UIView alloc] initWithFrame:CGRectMake(SwitchBtn.x, CGRectGetMaxY(SwitchBtn.frame)+2, SwitchBtn.width, 1)];
    partingline.backgroundColor = [QFTools colorWithHexString:@"#999999"];
    [self.view addSubview:partingline];
}

-(void)SwitchBtnClick{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sureBtnClick{
    
    if ([QFTools isBlankString:self.importField.text]) {
        
        [SVProgressHUD showSimpleText:@"条码不能为空"];
        
        return;
    }
    
    if (self.importField.text.length <12) {
        
        [SVProgressHUD showSimpleText:@"条码长度不足"];
        
        return;
    }
    
    [self checkKey];
}

- (void)checkKey{
    
    NSString *token = [QFTools getdata:@"token"];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/checkdevice"];
    NSDictionary *parameters = @{@"token": token, @"sn":self.importField.text };
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *devicedata = dict[@"data"];
            NSDictionary *device_info = devicedata[@"device_info"];
            NSNumber *default_brand_id = device_info[@"default_brand_id"];
            NSNumber *default_model_id = device_info[@"default_model_id"];
            NSNumber *device_id = device_info[@"device_id"];
            NSString *mac = device_info[@"mac"];
            NSString *prod_date = device_info[@"prod_date"];
            NSString *sn = device_info[@"sn"];
            NSNumber *type = device_info[@"type"];
            
            [NSNOTIC_CENTER addObserver:self selector:@selector(querySuccess:) name:KNotification_BindingBLEKEY object:nil];
            NSString *QuerykeySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' OR type LIKE '%zd' AND bikeid LIKE '%zd'", 2,5,self.deviceNum];
            NSMutableArray *keymodals = [LVFmdbTool queryPeripheraData:QuerykeySql];
            NSInteger number;
            if (keymodals.count == 0) {
                number = 1;
            }else if (keymodals.count == 1){
                number = 0;
                PeripheralModel *perierMod = keymodals.firstObject;
                if (perierMod.seq == 1) {
                    
                    number = 2;
                }else{
                    
                    number = 1;
                }
            }else{
                
                number = 2;
            }
            NSNumber *seq = [NSNumber numberWithInteger:number];
            
            deviceDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:default_brand_id,@"default_brand_id",default_model_id,@"default_model_id",device_id,@"device_id",mac,@"mac",prod_date,@"prod_date",seq,@"seq",sn,@"sn",type,@"type",nil];
            
            NSString *passwordHEX = [NSString stringWithFormat:@"A500000E3002011%d%@",number,mac];
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            
        }else{
            
            [SVProgressHUD showSimpleText:@"绑定失败"];
            
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        
    }];
}

-(void)querySuccess:(NSNotification*)notification{
    [NSNOTIC_CENTER removeObserver:self name:KNotification_BindingBLEKEY object:nil];
    NSString *date = notification.userInfo[@"data"];
    
    NSLog(@"%@",date);
    if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3002"]) {
        
        if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
            [SVProgressHUD showSimpleText:@"绑定失败"];
            
        }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
            
            [self bindKey];
        }
    }
}

- (void)bindKey{
    
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *bike_id= [NSNumber numberWithInt:(int)self.deviceNum];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/adddevice"];
    NSDictionary *parameters = @{@"token": token,@"bike_id":bike_id,@"device_info":deviceDic};
    NSString *seq =deviceDic[@"seq"];
    NSNumber *type =deviceDic[@"type"];
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *deviceDiction = dict[@"data"];
            NSMutableArray *deviceinfo = deviceDiction[@"device_info"];
            
            for (NSDictionary *devicedic in deviceinfo) {
                NSString *sn = devicedic[@"sn"];
                if ([self.importField.text isEqualToString:sn]) {
                    NSString *mac = devicedic[@"mac"];
                    NSString *firm_version = devicedic[@"firm_version"];
                    NSNumber *deviceid =devicedic[@"device_id"];
                    PeripheralModel *pmodel = [PeripheralModel modalWith:self.deviceNum deviceid:deviceid.intValue type:type.intValue seq:seq.intValue mac:mac sn:sn firmversion:firm_version];
                    [LVFmdbTool insertDeviceModel:pmodel];
                }
            }
            
            NSLog(@"vccount %d",self.navigationController.viewControllers.count);
            
            [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:RefreshFittingsManagement object:nil]];
            UIViewController *accVc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-3];
            [self.navigationController popToViewController:accVc animated:YES];
            
        }else{
            [SVProgressHUD showSimpleText:@"该设备已被绑定"];
            //[self.navigationController popViewControllerAnimated:YES];
            
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        
    }];
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
    [field becomeFirstResponder];
     field.keyboardType = UIKeyboardTypeNumberPad;
    field.delegate = self;
    //  field.textColor = [QFTools colorWithHexString:@"#333333"];
    // 设置内容居中
    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    UIImage *fieldImage = [UIImage imageNamed:imageName];
//    UIImageView *fieldView = [[UIImageView alloc] initWithImage:fieldImage];
//    fieldView.width = width;
//    // 图片内容居中显示
//    fieldView.contentMode = UIViewContentModeScaleAspectFit;
//    field.leftView = fieldView;
    field.leftViewMode = UITextFieldViewModeAlways;
    // 设置清除按钮
    field.clearButtonMode = UITextFieldViewModeWhileEditing;
    // 占位符
    [[UITextField appearance] setTintColor:[QFTools colorWithHexString:MainColor]];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    NSAttributedString *attri = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[QFTools colorWithHexString:@"#adaaa8"], NSParagraphStyleAttributeName:style}];
    field.attributedPlaceholder = attri;
    [field setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17]];
    [field setValue:[UIFont fontWithName:@"Arial" size:14] forKeyPath:@"_placeholderLabel.font"];
    return field;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
