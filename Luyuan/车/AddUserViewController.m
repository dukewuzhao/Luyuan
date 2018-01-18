//
//  AddUserViewController.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/8/26.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "AddUserViewController.h"

@interface AddUserViewController ()<UITextFieldDelegate>

@property (nonatomic,weak) UITextField *userField; // 密码

@end

@implementation AddUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    [self configureNavgationItemTitle:@"新建成员"];
    WS(weakself);
    
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        
        [weakself.navigationController popViewControllerAnimated:YES];
        
    }];
    
    [self setupview];
}

- (void)setupview{
    
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.bikeId];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    
    UIView *backview = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - ScreenWidth *.13, 30, ScreenWidth *.26, ScreenWidth *.26)];
    backview.backgroundColor = [QFTools colorWithHexString:MainColor];
    backview.layer.masksToBounds = YES;
    backview.layer.cornerRadius = ScreenWidth *.13;
    [self.view addSubview:backview];
    
    UIImageView *backIcon = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - ScreenWidth *.13, 30, ScreenWidth *.26, ScreenWidth *.26)];
    backIcon.center = backview.center;
    backIcon.image = [UIImage imageNamed:@"lvyuan_logo"];
    [self.view addSubview:backIcon];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 75, CGRectGetMaxY(backview.frame)+10, 150, 20)];
    nameLabel.text = bikemodel.bikename;
    nameLabel.textColor = [QFTools colorWithHexString:MainColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:nameLabel];

    UIView *childuser = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(nameLabel.frame)+30, ScreenWidth, 40)];
    childuser.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:childuser];
    
    UIImageView *childIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7.5, 25, 25)];
    childIcon.image = [UIImage imageNamed:@"icon_p2"];
    [childuser addSubview:childIcon];
    
    CGFloat usernameFieldY = 2.5;
    CGFloat usernameFieldW = ScreenWidth * 0.7;
    CGFloat usernameFieldH = 35;
    CGFloat usernameFieldX =  CGRectGetMaxX(childIcon.frame) + 10;
    
    UITextField *usernameField = [self addOneTextFieldWithTitle:@"请输入子用户手机号" imageName:nil imageNameWidth:5 Frame:CGRectMake(usernameFieldX, usernameFieldY, usernameFieldW, usernameFieldH)];
    usernameField.backgroundColor = [UIColor clearColor];
    usernameField.textColor = [UIColor blackColor];
    [childuser addSubview:usernameField];
    self.userField = usernameField;
    
     UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    saveBtn.frame = CGRectMake(0, CGRectGetMaxY(childuser.frame) + 30, ScreenWidth, 40);
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[QFTools colorWithHexString:MainColor] forState:UIControlStateNormal];
    [saveBtn setImage:[UIImage imageNamed:@"tab5"] forState:UIControlStateNormal];
    saveBtn.backgroundColor = [UIColor whiteColor];
    [saveBtn addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];

}

- (void)saveBtnClick{

    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(todoSomething:) object:nil];
    [self performSelector:@selector(todoSomething:) withObject:nil afterDelay:0.2f];
    

}

- (void)todoSomething:(id)sender
{
    //在这里做按钮的想做的事情。
    if ([QFTools isBlankString:self.userField.text]) {
        [SVProgressHUD showSimpleText:@"请输入手机号"];
        return;
    }
    
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *bikeid = [NSNumber numberWithInteger:self.bikeId];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/addchild"];
    NSDictionary *parameters = @{@"token":token, @"bike_id": bikeid , @"phone_num": self.userField.text};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            [SVProgressHUD showSimpleText:@"添加子用户成功"];
            
            if([self.delegate respondsToSelector:@selector(AddUserSuccess)])
            {
                [self.delegate AddUserSuccess];
            }
            
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
     field.keyboardType = UIKeyboardTypeNumberPad;
    field.delegate = self;
    //  field.textColor = [QFTools colorWithHexString:@"#333333"];
    // 设置内容居中
    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field.leftViewMode = UITextFieldViewModeAlways;
    // 设置清除按钮
    field.clearButtonMode = UITextFieldViewModeWhileEditing;
    // 占位符
    field.placeholder = title;
    [field setValue:[QFTools colorWithHexString:@"#adaaa8"] forKeyPath:@"_placeholderLabel.textColor"];
    return field;
}


#pragma mark - 点击屏幕取消键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
    
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
