//
//  BindingkeyViewController.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/7/15.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "BindingkeyViewController.h"

@interface BindingkeyViewController ()

{
    int time;
    MSWeakTimer *mytime;
    int bindingtime;
    NSString *key1;
    NSString *key2;
    NSString *key3;
    NSString *key4;
    NSString *keyvalue;
    NSInteger upperlimit;
}

@property(nonatomic,weak) UIImageView *lockImage;

@property(nonatomic,weak) UIImageView *arrow1;
@property(nonatomic,weak) UIImageView *unlockImage;
@property(nonatomic,weak) UIImageView *arrow2;
@property(nonatomic,weak) UIImageView *chargeImage;
@property(nonatomic,weak) UIImageView *arrow3;
@property(nonatomic,weak) UIImageView *callImage;
@property(nonatomic,weak) UILabel *countdown;

@property(nonatomic,weak) UILabel *binding;
@property(nonatomic,weak) UIButton *nextBtn;

@end

@implementation BindingkeyViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    time = 10;
    bindingtime = 0;
    [NSNOTIC_CENTER addObserver:self selector:@selector(bindingData:) name:KNotification_Bindingkey object:nil];
    
    [self configureNavgationItemTitle:@"钥匙配置"];
    
    @weakify(self);
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        @strongify(self);
        [self nextBtnClick];
    }];
    
    [self setupheadView];
}

- (void)setupheadView{
    
    UILabel *binding = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, ScreenWidth, 25)];
    binding.textAlignment = NSTextAlignmentCenter;
    binding.text = @"请根据APP示意图设置普通按钮上的按键功能";
    binding.textColor = [UIColor blackColor];
    binding.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:binding];
    self.binding = binding;
    
    UIImageView *lockImage = [[UIImageView alloc] initWithFrame:CGRectMake(60, CGRectGetMaxY(binding.frame) + 50, 40, 40)];
    lockImage.image = [UIImage imageNamed:@"binding_lock_key_next"];
    [self.view addSubview:lockImage];
    self.lockImage = lockImage;
    
    UIImageView *arrow1 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lockImage.frame), lockImage.y + 10, ScreenWidth - 200, 20)];
    arrow1.image = [UIImage imageNamed:@"icon_line_right_false"];
    [self.view addSubview:arrow1];
    self.arrow1 = arrow1;
    
    UIImageView *unlockImage = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 100, lockImage.y, 40, 40)];
    unlockImage.image = [UIImage imageNamed:@"binding_unlock_key"];
    [self.view addSubview:unlockImage];
    self.unlockImage = unlockImage;
    
    UIImageView *arrow2 = [[UIImageView alloc] initWithFrame:CGRectMake(unlockImage.x + 10, CGRectGetMaxY(unlockImage.frame), 20, ScreenHeight * .25)];
    arrow2.image = [UIImage imageNamed:@"icon_line_downt_false"];
    [self.view addSubview:arrow2];
    self.arrow2 = arrow2;
    
    UIImageView *chargeImage = [[UIImageView alloc] initWithFrame:CGRectMake(unlockImage.x , CGRectGetMaxY(unlockImage.frame) + ScreenHeight * .25, 40, 40)];
    [self.view addSubview:chargeImage];
    self.chargeImage = chargeImage;
    
    UIImageView *arrow3 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lockImage.frame), chargeImage.y + 10, ScreenWidth - 200, 20)];
    arrow3.image = [UIImage imageNamed:@"icon_line_left_false"];
    [self.view addSubview:arrow3];
    self.arrow3 = arrow3;
    
    UIImageView *callImage = [[UIImageView alloc] initWithFrame:CGRectMake(lockImage.x , chargeImage.y, 40, 40)];
    callImage.image = [UIImage imageNamed:@"binding_onstart_key"];
    [self.view addSubview:callImage];
    self.callImage = callImage;
    
    UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(60, ScreenHeight -navHeight- 60, ScreenWidth - 120, 35)];
    [nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [nextBtn setTitle:@"暂不绑定" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[QFTools colorWithHexString:MainColor] forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:nextBtn];
    self.nextBtn = nextBtn;
    
    UILabel *countdown = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 20, CGRectGetMaxY(unlockImage.frame) +ScreenHeight * .125 , 40, 40)];
    countdown.font = [UIFont systemFontOfSize:16];
    countdown.textAlignment = NSTextAlignmentCenter;
    countdown.textColor = [UIColor blackColor];
    countdown.text = [NSString stringWithFormat:@"%d",time];
    [self.view addSubview:countdown];
    self.countdown = countdown;
    
    if (self.keyversion.intValue == 0 || self.keyversion.intValue == 1 || self.keyversion.intValue == 2) {
        
        upperlimit = 4;
        
        switch (self.keyversion.intValue) {
            case 0:
                chargeImage.image = [UIImage imageNamed:@"binding_find_key"];
                break;
                
            case 1:
                chargeImage.image = [UIImage imageNamed:@"binding_mute_key"];
                break;
                
            case 2:
                chargeImage.image = [UIImage imageNamed:@"binding_seat_key"];
                break;
                
            default:
                break;
        }
        
    }else if (self.keyversion.intValue == 4 || self.keyversion.intValue == 5 || self.keyversion.intValue == 6 || self.keyversion.intValue == 8 || self.keyversion.intValue == 9){
        
        switch (self.keyversion.intValue) {
            case 4:
                chargeImage.image = [UIImage imageNamed:@"binding_find_key"];
                break;
                
            case 5:
                chargeImage.image = [UIImage imageNamed:@"binding_mute_key"];
                break;
                
            case 6:
                chargeImage.image = [UIImage imageNamed:@"binding_seat_key"];
                break;
             
            case 8:
                chargeImage.image = [UIImage imageNamed:@"binding_onstart_key"];
                break;
            case 9:
                chargeImage.image = [UIImage imageNamed:@"binding_onstart_key"];
                break;
            default:
                break;
        }
        
        upperlimit = 3;
        self.callImage.hidden = YES;
        self.arrow3.hidden = YES;
        
    }else if (self.keyversion.intValue == 3){
        
        upperlimit = 2;
        self.chargeImage.hidden = YES;
        self.callImage.hidden = YES;
        self.arrow2.hidden = YES;
        self.arrow3.hidden = YES;
        
    }else if (self.keyversion.intValue == 7){
        
        upperlimit = 1;
        self.unlockImage.hidden = YES;
        self.chargeImage.hidden = YES;
        self.callImage.hidden = YES;
        self.arrow1.hidden = YES;
        self.arrow2.hidden = YES;
        self.arrow3.hidden = YES;
        
    }
    mytime = [MSWeakTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeFired:) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
}

-(void)bindingData:(NSNotification *)data{
    
    NSString *date = data.userInfo[@"data"];
    
    if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1003"]) {
    
    if (!keyvalue) {
        
        keyvalue = [date substringWithRange:NSMakeRange(12, 6)];
        
    }
        
        if ([[date substringWithRange:NSMakeRange(12, 6)] isEqualToString:keyvalue]) {
            
            time = 10;
            bindingtime ++;
            NSString *passwordHEX = @"A5000007100301";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            
            if (bindingtime == 1) {
                key1 = [date substringWithRange:NSMakeRange(12, 8)];
                self.lockImage.image = [UIImage imageNamed:@"binding_lock_key_ok"];
                self.arrow1.image = [UIImage imageNamed:@"icon_line_right_true"];
                
                if (upperlimit == 1) {
                    
                    [NSNOTIC_CENTER removeObserver:self name:KNotification_Bindingkey object:nil];
                    
                    NSString *passwordHEX = [@"A500001730010" stringByAppendingFormat:@"%ld%@%@%@%@", (long)self.seq,key1, @"00000000",@"00000000",@"00000000"];
                    [[AppDelegate currentAppDelegate].device sendHexstring:passwordHEX];
                    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:[passwordHEX substringWithRange:NSMakeRange(0, 40)]]];
                    
                    [self performSelector:@selector(bindingSuccess) withObject:nil afterDelay:1.0];
                    
                    return;
                }
                
                self.unlockImage.image = [UIImage imageNamed:@"binding_unlock_key_next"];
                
            }else if (bindingtime == 2){
                
                if ([key1 isEqualToString:[date substringWithRange:NSMakeRange(12, 8)]]) {
                    [SVProgressHUD showSimpleText:@"按键重复"];
                    
                    [self endprogress];
                    
                    return;
                }
                
                key2 = [date substringWithRange:NSMakeRange(12, 8)];
                self.unlockImage.image = [UIImage imageNamed:@"binding_unlock_key_ok"];
                self.arrow2.image = [UIImage imageNamed:@"icon_line_downt_true"];
                
                if (upperlimit == 2) {
                    
                    [NSNOTIC_CENTER removeObserver:self name:KNotification_Bindingkey object:nil];
                    
                    NSString *passwordHEX = [@"A500001730010" stringByAppendingFormat:@"%ld%@%@%@%@", (long)self.seq,key1, key2,@"00000000",@"00000000"];
                    [[AppDelegate currentAppDelegate].device sendHexstring:passwordHEX];
                    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:[passwordHEX substringWithRange:NSMakeRange(0, 40)]]];
                    
                    [self performSelector:@selector(bindingSuccess) withObject:nil afterDelay:1.0];
                    
                    return;
                }
                
                switch (self.keyversion.intValue) {
                        
                    case 0:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_find_key_next"];
                        break;
                        
                    case 1:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_mute_key_next"];
                        break;
                        
                    case 2:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_seat_key_next"];
                        break;
                        
                    case 4:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_find_key_next"];
                        break;
                        
                    case 5:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_mute_key_next"];
                        break;
                        
                    case 6:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_seat_key_next"];
                        break;
                     
                    case 8:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_onstart_key_next"];
                        break;
                        
                    case 9:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_onstart_key_next"];
                        break;
                    default:
                        break;
                }
            }else if (bindingtime == 3){
                
                if ([key1 isEqualToString:[date substringWithRange:NSMakeRange(12, 8)]] || [key2 isEqualToString:[date substringWithRange:NSMakeRange(12, 8)]]) {
                    [SVProgressHUD showSimpleText:@"按键重复"];
                    
                    [self endprogress];
                    
                    return;
                }

                key3 = [date substringWithRange:NSMakeRange(12, 8)];
                
                self.arrow3.image = [UIImage imageNamed:@"icon_line_left_true"];
                
                switch (self.keyversion.intValue) {
                        
                    case 0:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_find_key_ok"];
                        break;
                        
                    case 1:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_mute_key_ok"];
                        break;
                        
                    case 2:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_seat_key_ok"];
                        break;
                        
                    case 4:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_find_key_ok"];
                        break;
                        
                    case 5:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_mute_key_ok"];
                        break;
                        
                    case 6:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_seat_key_ok"];
                        break;
                        
                    case 8:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_onstart_key_ok"];
                        break;
                    case 9:
                        self.chargeImage.image = [UIImage imageNamed:@"binding_onstart_key_ok"];
                        break;
                    default:
                        break;
                }
                
                if (upperlimit == 3) {
                    [NSNOTIC_CENTER removeObserver:self name:KNotification_Bindingkey object:nil];
                    
                    NSString *passwordHEX = [@"A500001730010" stringByAppendingFormat:@"%ld%@%@%@%@", (long)self.seq,key1, key2,key3,@"00000000"];
                    [[AppDelegate currentAppDelegate].device sendHexstring:passwordHEX];
                    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:[passwordHEX substringWithRange:NSMakeRange(0, 40)]]];
                    
                    [self performSelector:@selector(bindingSuccess) withObject:nil afterDelay:1.0];
                    
                    return;
                    
                }
                
                switch (self.keyversion.intValue) {
                    case 0:
                        self.callImage.image = [UIImage imageNamed:@"binding_onstart_key_next"];
                        break;
                        
                    case 1:
                        self.callImage.image = [UIImage imageNamed:@"binding_onstart_key_next"];
                        break;
                        
                    case 2:
                        self.callImage.image = [UIImage imageNamed:@"binding_onstart_key_next"];
                        break;
                        
                    default:
                        break;
                }
                
            }else if (bindingtime == 4){
                [mytime invalidate];
                self.countdown.hidden = YES;
                if ([key1 isEqualToString:[date substringWithRange:NSMakeRange(12, 8)]] || [key2 isEqualToString:[date substringWithRange:NSMakeRange(12, 8)]] || [key3 isEqualToString:[date substringWithRange:NSMakeRange(12, 8)]]) {
                    [SVProgressHUD showSimpleText:@"按键重复"];
                    
                    [self endprogress];
                    
                    return;
                }
                
                key4 = [date substringWithRange:NSMakeRange(12, 8)];
                switch (self.keyversion.intValue) {
                    case 0:
                        self.callImage.image = [UIImage imageNamed:@"binding_onstart_key_ok"];
                        break;
                        
                    case 1:
                        self.callImage.image = [UIImage imageNamed:@"binding_onstart_key_ok"];
                        break;
                        
                    case 2:
                        self.callImage.image = [UIImage imageNamed:@"binding_onstart_key_ok"];
                        break;
                        
                    default:
                        break;
                }
                
                [NSNOTIC_CENTER removeObserver:self name:KNotification_Bindingkey object:nil];
                NSString *passwordHEX = [@"A500001730010" stringByAppendingFormat:@"%ld%@%@%@%@", (long)self.seq,key1, key2,key3,key4];
                [[AppDelegate currentAppDelegate].device sendHexstring:passwordHEX];
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:[passwordHEX substringWithRange:NSMakeRange(0, 40)]]];
                
                [self performSelector:@selector(bindingSuccess) withObject:nil afterDelay:0.5];
            }
        }else{
        
            [SVProgressHUD showSimpleText:@"钥匙冲突"];
            
            [self endprogress];
            
            return;
        
        }
    }
}

-(void)bindingSuccess{
    self.binding.text = @"恭喜你,绑定成功";
    self.nextBtn.frame = CGRectMake(ScreenWidth/2 - 50, ScreenHeight - 60 , 100, 40);
    
    [self bindKey];
    [SVProgressHUD showSimpleText:@"普通钥匙配置成功"];

}

- (void)bindKey{
    
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *bike_id= [NSNumber numberWithInt:(int)self.deviceNum];
    NSNumber *seqnumber = [NSNumber numberWithInteger:self.seq];
    NSString *sn = @"R000000000";
    NSNumber *type = [NSNumber numberWithInt:3];
    NSDictionary *device_info = [NSDictionary dictionaryWithObjectsAndKeys:seqnumber,@"seq",sn,@"sn",type,@"type",nil];
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/adddevice"];
    NSDictionary *parameters = @{@"token": token,@"bike_id":bike_id,@"device_info":device_info};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND seq LIKE '%zd'",3,self.seq];
            NSMutableArray *modals = [LVFmdbTool queryPeripheraData:fuzzyQuerySql];
            
            if (modals.count > 0) {
                
                NSString *delateKeySql = [NSString stringWithFormat:@"DELETE FROM periphera_modals WHERE type LIKE '%zd' AND seq LIKE '%zd'",3,self.seq];
                [LVFmdbTool deletePeripheraData:delateKeySql];
            }
            
            NSDictionary *deviceDic = dict[@"data"];
            NSMutableArray *deviceinfo = deviceDic[@"device_info"];
            
            for (NSDictionary *devicedic in deviceinfo) {
                NSNumber *seq = devicedic[@"seq"];
                NSNumber *type = devicedic[@"type"];
                if (self.seq == seq.intValue && type.intValue == 3) {
                    
                    NSNumber *deviceid =devicedic[@"device_id"];
                    PeripheralModel *pmodel = [PeripheralModel modalWith:self.deviceNum deviceid:deviceid.intValue type:3 seq:self.seq mac:@"" sn:sn firmversion:@""];
                    BOOL isInsertp = [LVFmdbTool insertDeviceModel:pmodel];
                    
                    if (isInsertp) {
                        
                        [self.nextBtn setTitle:@"返回配件管理" forState:UIControlStateNormal];
                    }
                }
            }
            if ([self.delegate respondsToSelector:@selector(bidingKeyOver)]) {
                [self.delegate bidingKeyOver];
            }
            [self nextBtnClick];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        
    }];
}

- (void)timeFired:(NSTimer *)timer{
    
    time--;
    self.countdown.text = [NSString stringWithFormat:@"%d",time];
    
    if (time == 0) {
        [AppDelegate currentAppDelegate].device.bindingaccessories = NO;
        [timer invalidate];
        [SVProgressHUD showSimpleText:@"绑定超时"];
        NSString *passwordHEX = @"A5000007100300";
        [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
        [NSNOTIC_CENTER removeObserver:self name:KNotification_Bindingkey object:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }
    
}

-(void)nextBtnClick{
    [AppDelegate currentAppDelegate].device.bindingaccessories = NO;
    
    NSString *passwordHEX = @"A5000007100300";
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)endprogress{
    [AppDelegate currentAppDelegate].device.bindingaccessories = NO;
    [mytime invalidate];
    
    NSString *passwordHEX = @"A5000007100300";
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    
    [NSNOTIC_CENTER removeObserver:self name:KNotification_Bindingkey object:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}

-(void)dealloc{
    [mytime invalidate];
    mytime = nil;
}

@end
