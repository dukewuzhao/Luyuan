//
//  EditFingerprintViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2017/11/21.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "EditFingerprintViewController.h"

@interface EditFingerprintViewController ()<UIAlertViewDelegate>
{
    UITextField * fingerprintFiled;
}

@property (nonatomic, strong)UIAlertView *delFingerAlertView;
@property (nonatomic, assign)BOOL isCanDelete;

@end

@implementation EditFingerprintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    [self configureNavgationItemTitle:@"编辑指纹"];
    [AppDelegate currentAppDelegate].device.bindingaccessories = YES;
    @weakify(self);
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [self configureRightBarButtonWithTitle:@"保存" action:^{
        @strongify(self);
        [self saveUserFinger];
    }];
    
    [self setupView];
    
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_DeleteFinger object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        NSNotification *userInfo = x;
        NSString *date = userInfo.userInfo[@"data"];
        if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3005"]) {

            if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                [SVProgressHUD showSimpleText:@"删除失败"];

            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                //[SVProgressHUD showSimpleText:@"删除成功"];
                [self deleteFingerPrint];
            }
        }
    }];
    
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_TestFingerPress object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        
        @strongify(self);
        NSNotification *userInfo = x;
        NSString *date = userInfo.userInfo[@"data"];
        //NSLog(@"%@",date);
        [self TestFingerpress];
        if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3006"]) {
            
            if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                self.isCanDelete = true;
            }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
                self.isCanDelete = false;
            }
        }
    }];
    [self TestFingerpress];
}

-(void)setupView{
    
    fingerprintFiled = [[UITextField alloc]init];
    fingerprintFiled.frame = CGRectMake(10, 20, ScreenWidth - 20, 45);
    fingerprintFiled.placeholder = self.fpmodel.name;
    [fingerprintFiled setValue:[QFTools colorWithHexString:@"#adaaa8"] forKeyPath:@"_placeholderLabel.textColor"];
    fingerprintFiled.layer.cornerRadius = 5;
    fingerprintFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
    fingerprintFiled.textColor = [UIColor blackColor];
    fingerprintFiled.backgroundColor = [UIColor whiteColor];
    fingerprintFiled.layer.borderColor = [UIColor colorWithRed:14/255.0 green:174/255.0 blue:131/255.0 alpha:1].CGColor;
    fingerprintFiled.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    fingerprintFiled.leftViewMode = UITextFieldViewModeAlways;
    [[UITextField appearance] setTintColor:[QFTools colorWithHexString:MainColor]];
    [self.view addSubview:fingerprintFiled];
    //[fingerprintFiled becomeFirstResponder];
    
    UILabel *promte = [[UILabel alloc] initWithFrame:CGRectMake(fingerprintFiled.x, CGRectGetMaxY(fingerprintFiled.frame)+5, fingerprintFiled.width, 20)];
    promte.textColor = [QFTools colorWithHexString:@"#999999"];
    promte.font = [UIFont systemFontOfSize:14];
    promte.text = @"限4-12字符,每个汉字为两个字符";
    [self.view addSubview:promte];
    
    @weakify(self);
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(25, ScreenHeight - navHeight - 110, ScreenWidth - 50, 45)];
    deleteBtn.backgroundColor = [UIColor redColor];
    [[deleteBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if (![[AppDelegate currentAppDelegate].device isConnected]) {
            
            [SVProgressHUD showSimpleText:@"蓝牙未连接"];
            return;
        }
        if (!self.isCanDelete) {
            [SVProgressHUD showSimpleText:@"清先移除手指"];
            return;
        }
        self.delFingerAlertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否删除该指纹" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        self.delFingerAlertView.tag =1111;
        [self.delFingerAlertView show];
        
    }];
    [deleteBtn setTitle:@"删除指纹" forState:UIControlStateNormal];
    deleteBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    deleteBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
    [deleteBtn.layer setCornerRadius:10.0]; // 切圆角
    [self.view addSubview:deleteBtn];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 1111) {
        if (buttonIndex != [alertView cancelButtonIndex]) {
            NSString *passwordHEX;
            if (self.fpmodel.pos == 10) {
                passwordHEX = [NSString stringWithFormat:@"A500000730050A"];
            }else{
                passwordHEX = [NSString stringWithFormat:@"A500000730050%d",self.fpmodel.pos];
            }
            
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
        }
    }

}
-(void)saveUserFinger{
    
    [self editFingerPrintName];
}

-(void)deleteFingerPrint{
    
    LoadView *loadview = [[LoadView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    loadview.protetitle.text = @"删除指纹中";
    [[UIApplication sharedApplication].keyWindow addSubview:loadview];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/delfingerprint"];
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *fpid = [NSNumber numberWithInteger:self.fpmodel.fp_id];
    NSNumber *bikeid = [NSNumber numberWithInteger:self.deviceNum];
    NSDictionary *parameters = @{@"token": token, @"bike_id": bikeid,@"fp_id": fpid};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            [loadview removeFromSuperview];
            [SVProgressHUD showSimpleText:@"删除指纹成功"];
            
            NSString *deleteFingerSql = [NSString stringWithFormat:@"DELETE FROM fingerprint_modals WHERE bikeid LIKE '%zd' AND pos LIKE '%zd'", self.deviceNum,self.fpmodel.pos];
            [LVFmdbTool deleteFingerprintData:deleteFingerSql];
            
            if([self.delegate respondsToSelector:@selector(deleteFingerprintSuccess)])
            {
                [self.delegate deleteFingerprintSuccess];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }else{
            [loadview removeFromSuperview];
            NSLog(@" %@",dict[@"status_info"] );
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        [loadview removeFromSuperview];
        
    }];
}

-(void)editFingerPrintName{
    
    if ([QFTools isBlankString:fingerprintFiled.text]) {
        [SVProgressHUD showSimpleText:@"请输入修改名称"];
        return;
    }
    
    LoadView *loadview = [[LoadView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    loadview.protetitle.text = @"修改指纹中";
    [[UIApplication sharedApplication].keyWindow addSubview:loadview];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/changefingerprintname"];
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *fpid = [NSNumber numberWithInteger:self.fpmodel.fp_id];
    NSNumber *pos = [NSNumber numberWithInteger:self.fpmodel.pos];
    NSNumber *bikeid = [NSNumber numberWithInteger:self.deviceNum];
    NSNumber* dTime = [NSNumber numberWithDouble:self.fpmodel.added_time];
    NSDictionary *fp_info = [NSDictionary dictionaryWithObjectsAndKeys:fpid,@"fp_id",pos,@"pos",fingerprintFiled.text,@"name",dTime,@"added_time",nil];
    NSDictionary *parameters = @{@"token": token, @"bike_id": bikeid,@"fp_info": fp_info};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            [loadview removeFromSuperview];
            [SVProgressHUD showSimpleText:@"修改指纹成功"];
            
            NSString *updateSql = [NSString stringWithFormat:@"UPDATE fingerprint_modals SET name = '%@' WHERE bikeid = '%zd' AND fp_id LIKE '%zd'",fingerprintFiled.text, self.deviceNum,self.fpmodel.fp_id];
            [LVFmdbTool modifyData:updateSql];
            
            if([self.delegate respondsToSelector:@selector(editFingerprintNameSuccess)]){
                [self.delegate editFingerprintNameSuccess];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }else{
            [loadview removeFromSuperview];
            NSLog(@" %@",dict[@"status_info"] );
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        [loadview removeFromSuperview];
        
    }];
}

-(void)TestFingerpress{
    
    NSString *passwordHEX = [NSString stringWithFormat:@"A50000063006"];
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
}



-(void)dealloc{
    [AppDelegate currentAppDelegate].device.bindingaccessories = NO;
    [self.delFingerAlertView dismissWithClickedButtonIndex:0 animated:YES];
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
