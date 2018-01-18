//
//  QRViewController.m
//  SmartWallitAdv
//
//  Created by AlanWang on 15/8/4.
//  Copyright (c) 2015年 AlanWang. All rights reserved.
//

#import "TwoDimensionalCodecanViewController.h"
#import "ManualInputViewController.h"
#import "BottomBtn.h"
#import "QRCodeReaderView.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define DeviceMaxHeight ([UIScreen mainScreen].bounds.size.height)
#define DeviceMaxWidth ([UIScreen mainScreen].bounds.size.width)
#define widthRate DeviceMaxWidth/320
#define IOS8 ([[UIDevice currentDevice].systemVersion intValue] >= 8 ? YES : NO)

@interface TwoDimensionalCodecanViewController ()<QRCodeReaderViewDelegate,AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UINavigationControllerDelegate>{
    
    NSString *codeNum;
    NSMutableDictionary *deviceDic;
    NSMutableDictionary *deviceList;
    QRCodeReaderView * readview;//二维码扫描对象
    BOOL isFirst;//第一次进入该页面
    BOOL isPush;//跳转到下一级页面
}

@end

@implementation TwoDimensionalCodecanViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (isFirst || isPush) {
        if (readview) {
            [self reStartScan];
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (readview) {
        [readview stop];
        readview.is_Anmotion = YES;
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (isFirst) {
        isFirst = NO;
    }
    if (isPush) {
        isPush = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    deviceList=[[NSMutableDictionary alloc]init];
    
    
    [self configureNavgationItemTitle:@"绑定智能配件"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    @weakify(self);
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        @strongify(self);
        [self backButtonEvent];
    }];
    
//    [self configureRightBarButtonWithTitle:@"相册" action:^{
//        @strongify(self);
//        [self alumbBtnEvent];
//    }];
    isFirst = YES;
    isPush = NO;
    [self InitScan];
    
    
}


- (void)checkKey{
    
    NSString *token = [QFTools getdata:@"token"];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/checkdevice"];
    NSDictionary *parameters = @{@"token": token, @"sn":codeNum };
    
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
            //AGE >= 25 OR SALARY >= 65000
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
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        
    }];
    
}

-(void)querySuccess:(NSNotification*)notification{
    
    [NSNOTIC_CENTER removeObserver:self name:KNotification_BindingBLEKEY object:nil];
    NSString *date = notification.userInfo[@"data"];
        if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3002"]) {
            
            if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
                [SVProgressHUD showSimpleText:@"绑定失败"];
                codeNum = nil;
                
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
                if ([codeNum isEqualToString:sn]) {
                    NSString *mac = devicedic[@"mac"];
                    NSString *firm_version = devicedic[@"firm_version"];
                    NSNumber *deviceid =devicedic[@"device_id"];
                    PeripheralModel *pmodel = [PeripheralModel modalWith:self.deviceNum deviceid:deviceid.intValue type:type.intValue seq:seq.intValue mac:mac sn:sn firmversion:firm_version];
                    [LVFmdbTool insertDeviceModel:pmodel];
                }
            }
            
            if ([self.delegate respondsToSelector:@selector(TwoDimensionalCodecanBidingKeySuccess)]) {
                [self.delegate TwoDimensionalCodecanBidingKeySuccess];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }else{
            [SVProgressHUD showSimpleText:@"该设备已被绑定"];
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        
    }];
    
}


#pragma mark 初始化扫描
- (void)InitScan
{
    if (readview) {
        [readview removeFromSuperview];
        readview = nil;
    }
    
    readview = [[QRCodeReaderView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - navHeight)];
    readview.is_AnmotionFinished = YES;
    readview.backgroundColor = [UIColor clearColor];
    readview.delegate = self;
    readview.alpha = 0;
    
    [self.view addSubview:readview];
    
    [UIView animateWithDuration:0.5 animations:^{
        readview.alpha = 1;
    }completion:^(BOOL finished) {
        
    }];
    
}

#pragma mark - 返回
- (void)backButtonEvent
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 相册
- (void)alumbBtnEvent
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) { //判断设备是否支持相册
        
        if (IOS8) {
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"未开启访问相册权限，现在去开启！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 411;
            [alert show];
        }
        else{
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"设备不支持访问相册，请在设置->隐私->照片中进行设置！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        return;
    }
    
    isPush = YES;
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    mediaUI.allowsEditing = YES;
    mediaUI.delegate = self;
    [[[[AppDelegate currentAppDelegate] window] rootViewController] presentViewController:mediaUI animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }];
    
    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 411) {
        if (buttonIndex != [alertView cancelButtonIndex]) {
            
            if ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0) {
                NSDictionary *options = @{UIApplicationOpenURLOptionUniversalLinksOnly : @YES};
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Photos"] options:options completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Photos"]];
                
            }
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __block UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    readview.is_Anmotion = YES;
    
    if (features.count >=1) {
        
        [picker dismissViewControllerAnimated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
            
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scannedResult = feature.messageString;
            //播放扫描二维码的声音
            SystemSoundID soundID;
            NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"noticeMusic" ofType:@"wav"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
            AudioServicesPlaySystemSound(soundID);
            
            [self accordingQcode:scannedResult];
        }];
        
    }else{
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"无法识别！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
        [picker dismissViewControllerAnimated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
            
            readview.is_Anmotion = NO;
            [readview start];
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }];
    
}

#pragma mark -QRCodeReaderViewDelegate
- (void)readerScanResult:(NSString *)result
{
    readview.is_Anmotion = YES;
    [readview stop];
    
    //播放扫描二维码的声音
    SystemSoundID soundID;
    NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"noticeMusic" ofType:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
    AudioServicesPlaySystemSound(soundID);
    
    [self accordingQcode:result];
    
    [self performSelector:@selector(reStartScan) withObject:nil afterDelay:1.5];
}

-(void)SetupBtnClickTrue{
    
    isPush = YES;
    ManualInputViewController *manualVc = [ManualInputViewController new];
    manualVc.deviceNum = self.deviceNum;
    [self.navigationController pushViewController:manualVc animated:NO];
}

#pragma mark - 扫描结果处理
- (void)accordingQcode:(NSString *)str
{
    codeNum = str;
    [self checkKey];
    
}

- (void)reStartScan
{
    readview.is_Anmotion = NO;
    
    if (readview.is_AnmotionFinished) {
        [readview loopDrawLine];
    }
    
    [readview start];
}
#pragma mark - 点击屏幕取消键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    
}

@end
