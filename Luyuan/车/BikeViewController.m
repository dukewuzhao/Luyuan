//
//  BikeViewController.m
//  RideHousekeeper
//
//  Created by 同时科技 on 16/6/20.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "BikeViewController.h"
#import "AddBikeViewController.h"
#import "BindingUserViewController.h"
#import "SubmitViewController.h"
#import "FaultViewController.h"
#import "TwoDimensionalCodecanViewController.h"
#import "SideMenuViewController.h"
#import "DeviceModel.h"
#import "MapViewController.h"
#import "Constants.h"
#import "AppFilesViewController.h"
#import "UserFilesViewController.h"
#import "SSZipArchive.h"
#import "UnzipFirmware.h"
#import "Utility.h"
#import "DFUHelper.h"
#import "UIViewController+CWLateralSlide.h"
#import "LrdOutputView.h"
#import "QuartzCore/QuartzCore.h" 
#import "CustomProgress.h"
#import "FaultModel.h"
#import "DfuDownloadFile.h"
#import "ATCarouselView.h"
#import "WuPageControl.h"
#define DURATION 0.7f
//BF06258C-BF26-8740-CBDD-D02AC1B5749B
//BF06258C-BF26-8740-CBDD-D02AC1B5749B

@interface BikeViewController ()<ScanDelegate,UIAlertViewDelegate,SubmitDelegate,AddBikeDelegate,DfuDownloadFileDelegate,LrdOutputViewDelegate,ATCarouselViewDelegate>

{
    NSMutableArray *rssiList;//搜索到的车辆的model数组
    NSMutableDictionary *uuidarray;//UUID字典
    NSInteger Inductionvalue;//手机感应的rssi值
    NSString *querydate;//查询的车辆蓝牙返回信息
    NSString *downloadhttp;//固件升级包地址
    NSString *uuidstring;//要连接车辆的UUID
    NSString *editionname;//固件版本号
    
    BOOL chamberpot;//座桶是否打开
    BOOL fortification;//是否设防
    BOOL powerswitch;//电源是否打开
    BOOL riding;//是否骑行中
    
    CustomProgress *custompro;//自定义固件升级界面
    NSInteger touchCount;//座桶锁点击频率限制
}

@property (nonatomic, strong) NSString *latest_version;//最新的固件版本号
@property (nonatomic ,weak) UIWindow *backView;//固件升级的背景窗口
@property(nonatomic, weak) UIView *footView;//底部视图
@property (nonatomic ,weak) UIImageView *smartbikeimage;//车辆图片

@property (nonatomic ,weak)UILabel *voltageLab;//电压
@property (nonatomic ,weak)UILabel *bikestatedetail;//车辆健康
@property (nonatomic ,weak) UILabel *keystate;//感应状态显示
@property (nonatomic ,weak) UIImageView *phinducImg;//感应状态图片
@property (nonatomic ,weak) UILabel *biketemperature;//车辆温度
@property (nonatomic ,weak) UILabel *Preparedness;//车辆设防与撤防显示
@property (nonatomic ,weak) UILabel *batteryLab;//蓝牙钥匙电量显示
@property(nonatomic, assign) NSInteger bikeid;//车辆id
@property(nonatomic, strong) NSString* mac;//车辆mac地址
@property(nonatomic, assign) NSInteger ownerflag;//主与子用户分别
@property(nonatomic, weak) NSString* password;//设备写入密码
@property(nonatomic, weak) UIImageView *connectstate;//蓝牙钥匙连接状态图片显示
@property(nonatomic, weak) UIImageView *islocked;//撤防与设防图片
//@property(nonatomic, weak)UIImageView *bikestateimage;//车辆连接图片
@property(nonatomic, weak) UILabel *bikeprompt;
@property(nonatomic, strong) MSWeakTimer * queraTime;//0.5秒的计时器，用于查询数据
@property(nonatomic,strong)FaultModel *faultmodel;//故障model

@property (nonatomic, strong) LrdOutputView *outputView;//右上角弹出按钮
@property (nonatomic, weak) LrdCellModel *Lrdmodel;//弹出界面model
@property (nonatomic, strong) NSArray *chooseArray;//获取弹出界面model的数组

@property (strong, nonatomic)  WuPageControl *pageControl;
@property (nonatomic, strong) ATCarouselView *carousel;//切换车辆滑动界面

@property (strong, nonatomic) CBPeripheral *selectedPeripheral;//选中的固件升级的设备
@property (strong, nonatomic) DFUOperations *dfuOperations;
@property (strong, nonatomic) DFUHelper *dfuHelper;
@property (strong, nonatomic) NSString *selectedFileType;

@property (nonatomic, strong)UIAlertView *BluetoothUpgrateAlertView;

@property BOOL isTransferring;
@property BOOL isTransfered;
@property BOOL isTransferCancelled;
@property BOOL isConnected;
@property BOOL isErrorKnown;

@end

@implementation BikeViewController

@synthesize selectedPeripheral;//选中的固件升级的设备
@synthesize dfuOperations;//
@synthesize selectedFileType;//升级包格式

- (FaultModel *)faultmodel {
    if (!_faultmodel) {
        _faultmodel = [[FaultModel alloc] init];
    }
    return _faultmodel;
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [AppDelegate currentAppDelegate].device.scanDelete = self;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barTintColor = [QFTools colorWithHexString:MainColor];
    NSString*deviceuuid=[USER_DEFAULTS stringForKey:Key_DeviceUUID];
    if ([AppDelegate currentAppDelegate].isPop && [QFTools isBlankString:deviceuuid] && [AppDelegate currentAppDelegate].device.blueToothOpen && [[QFTools currentViewController] isKindOfClass:[BikeViewController class]]) {
        
        [[AppDelegate currentAppDelegate].device startScan];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSString*deviceuuid=[USER_DEFAULTS stringForKey:Key_DeviceUUID];
    //if DFU peripheral is connected and user press Back button then disconnect it
    if ([AppDelegate currentAppDelegate].isPop && [QFTools isBlankString:deviceuuid]) {
        
        [[AppDelegate currentAppDelegate].device stopScan];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [QFTools colorWithHexString:MainColor];
    PACKETS_NOTIFICATION_INTERVAL=10;
    dfuOperations = [[DFUOperations alloc] initWithDelegate:self];
    self.dfuHelper = [[DFUHelper alloc] initWithData:dfuOperations];
    
    rssiList=[[NSMutableArray alloc]init];
    uuidarray=[[NSMutableDictionary alloc]init];
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(BikeViewquerySuccess:) name:KNotification_QueryData object:nil];
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(switchDevice:) name:KNotification_SwitchDevice object:nil];
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(remoteJpush:) name:KNotification_RemoteJPush object:nil];
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(updatevalue:) name:KNotification_UpdateValue object:nil];
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(coonectSwitchBike:) name:KNotification_SwitchingVehicle object:nil];
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(queryInduction:) name:@"Inductionswitch" object:nil];
    
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_BluetoothPowerOn object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        NSString*deviceuuid=[USER_DEFAULTS stringForKey:Key_DeviceUUID];
        if ([[QFTools currentViewController] isKindOfClass:[BikeViewController class]] && [QFTools isBlankString:deviceuuid]) {
            
            [[AppDelegate currentAppDelegate].device startScan];
        }
    }];
    
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_BluetoothPowerOff object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        NSString*deviceuuid=[USER_DEFAULTS stringForKey:Key_DeviceUUID];
        if ([[QFTools currentViewController] isKindOfClass:[BikeViewController class]] && [QFTools isBlankString:deviceuuid]) {
            
            [[AppDelegate currentAppDelegate].device stopScan];
        }
    }];
    
    [self setupNavBar];
    [self setupmenu];
    [self setupMainview];
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(networkDidSetup:) name:kJPFNetworkDidSetupNotification object:nil];
    [NSNOTIC_CENTER addObserver:self selector:@selector(networkDidClose:) name:kJPFNetworkDidCloseNotification object:nil];
    [NSNOTIC_CENTER addObserver:self selector:@selector(networkDidRegister:) name:kJPFNetworkDidRegisterNotification object:nil];
    [NSNOTIC_CENTER addObserver:self selector:@selector(networkDidLogin:) name:kJPFNetworkDidLoginNotification object:nil];
    [NSNOTIC_CENTER addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    [NSNOTIC_CENTER addObserver:self selector:@selector(serviceError:) name:kJPFServiceErrorNotification object:nil];
    [NSNOTIC_CENTER addObserver:self selector:@selector(updateDeviceStatusAction:) name:KNotification_UpdateDeviceStatus object:nil];
    [NSNOTIC_CENTER addObserver:self selector:@selector(editionData:) name:KNotification_UpdateeditionValue object:nil];
    
    UIWindow *backView = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    backView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
    backView.windowLevel = UIWindowLevelAlert;
    [[UIApplication sharedApplication].keyWindow addSubview:backView];
    self.backView = backView;
    backView.hidden = YES;
    
    custompro = [[CustomProgress alloc] initWithFrame:CGRectMake(50, self.view.centerY - 10, self.view.frame.size.width-100, 20)];
    custompro.maxValue = 100;
    custompro.leftimg.image = [UIImage imageNamed:@"leftimg"];
    custompro.bgimg.image = [UIImage imageNamed:@"bgimg"];
    custompro.instruc.image = [UIImage imageNamed:@"bike"];
    //可以更改lab字体颜色
    [backView addSubview:custompro];
    
    // 注册手势驱动
    __weak typeof(self)weakSelf = self;
    [self cw_registerShowIntractiveWithEdgeGesture:YES transitionDirectionAutoBlock:^(CWDrawerTransitionDirection direction) {
        //NSLog(@"direction = %ld", direction);
        if (direction == CWDrawerTransitionDirectionLeft) { // 左侧滑出
            [weakSelf leftClick];
        } else if (direction == CWDrawerTransitionDirectionRight) { // 右侧滑出
            [weakSelf rightClick];
        }
    }];
    
}


// 导航栏左边按钮的点击事件
- (void)leftClick {
    // 自己随心所欲创建的一个控制器
    SideMenuViewController *vc = [[SideMenuViewController alloc] init];
    
    // 这个代码与框架无关，与demo相关，因为有兄弟在侧滑出来的界面，使用present到另一个界面返回的时候会有异常，这里提供各个场景的解决方式，需要在侧滑的界面present的同学可以借鉴一下！处理方式在leftViewController的viewDidAppear:方法内
    vc.drawerType = DrawerDefaultLeft;
    
    // 调用这个方法
    [self cw_showDrawerViewController:vc animationType:CWDrawerAnimationTypeDefault configuration:nil];
}

- (void)rightClick {
    
    SideMenuViewController *vc = [[SideMenuViewController alloc] init];
    
    CWLateralSlideConfiguration *conf = [CWLateralSlideConfiguration configurationWithDistance:0 maskAlpha:0.4 scaleY:0.8 direction:CWDrawerTransitionDirectionRight backImage:[UIImage imageNamed:@"0.jpg"]];
    
    [self cw_showDrawerViewController:vc animationType:0 configuration:conf];
    
}

#pragma mark - 车辆的连接状态改变的通知
-(void)updateDeviceStatusAction:(NSNotification*)notification{
    
    if([AppDelegate currentAppDelegate].device.deviceStatus == 0){
        self.bikeprompt.text = @"未连接";
        self.bikeprompt.textColor = [UIColor redColor];
        self.connectstate.image = [UIImage imageNamed:@"bluetooth_key_break"];
        self.batteryLab.hidden = YES;
        editionname = nil;
        self.biketemperature.text = @"温度";
        self.bikestatedetail.text = @"健康";
        self.voltageLab.text = @"电压";
        
    }else if([AppDelegate currentAppDelegate].device.deviceStatus>=2 &&[AppDelegate currentAppDelegate].device.deviceStatus<5){
        
        
    }else{
        editionname = nil;
        self.bikeprompt.text = @"未连接";
        self.bikeprompt.textColor = [UIColor redColor];
        self.connectstate.image = [UIImage imageNamed:@"bluetooth_key_break"];
        [self configureNavgationItemTitle:@"车辆名称"];
        self.biketemperature.text = @"温度";
        self.bikestatedetail.text = @"健康";
        self.voltageLab.text = @"电压";
    }
}

#pragma mark - 收到远程jpush的逻辑处理
-(void)remoteJpush:(NSNotification *)data{

    NSNumber *bikeid = data.userInfo[@"bikeid"];
    NSNumber *type = data.userInfo[@"type"];
    NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM induction_modals WHERE bikeid LIKE '%zd'", bikeid.intValue];
    
    NSMutableArray *inducmodals = [LVFmdbTool queryInductionData:nil];
    if (inducmodals.count != 0) {
        [LVFmdbTool deleteInductionData:deleteSql];
    }
    
    if (type.intValue == 1 || type.intValue == 2 || type.intValue == 3) {
        
    if ([[AppDelegate currentAppDelegate].device isConnected]) {
        
        if (bikeid.intValue == self.bikeid) {
            [[AppDelegate currentAppDelegate].device remove];
            self.connectstate.image = [UIImage imageNamed:@"bluetooth_key_break"];
            [USER_DEFAULTS removeObjectForKey:Key_DeviceUUID];
            [USER_DEFAULTS removeObjectForKey:Key_MacSTRING];
            [USER_DEFAULTS removeObjectForKey:SETRSSI];
            [USER_DEFAULTS removeObjectForKey:passwordDIC];
            [USER_DEFAULTS synchronize];
            self.keystate.text = @"手机遥控";
            [AppDelegate currentAppDelegate]. device.deviceStatus=0;
            self.bikeprompt.text = @"未连接";
            self.bikeprompt.textColor = [UIColor redColor];
            
            NSMutableArray *bikeAry = [LVFmdbTool queryBikeData:nil];
            if (bikeAry.count > 0) {
                BikeModel *bikemodel = bikeAry.firstObject;
                [self switchingVehicle:bikemodel.bikeid];
            }
        }
        
    }else{
        if (bikeid.intValue == self.bikeid) {
            
            [[AppDelegate currentAppDelegate].device remove];
            self.connectstate.image = [UIImage imageNamed:@"bluetooth_key_break"];
            [USER_DEFAULTS removeObjectForKey:Key_DeviceUUID];
            [USER_DEFAULTS removeObjectForKey:Key_MacSTRING];
            [USER_DEFAULTS removeObjectForKey:SETRSSI];
            [USER_DEFAULTS removeObjectForKey:passwordDIC];
            [USER_DEFAULTS synchronize];
            self.keystate.text = @"手机遥控";
            [AppDelegate currentAppDelegate]. device.deviceStatus=0;
            self.bikeprompt.text = @"未连接";
            self.bikeprompt.textColor = [UIColor redColor];
            
            NSMutableArray *bikeAry = [LVFmdbTool queryBikeData:nil];
            if (bikeAry.count > 0) {
                BikeModel *bikemodel = bikeAry.firstObject;
                [self switchingVehicle:bikemodel.bikeid];
            }
        }
     }
        
        
    }else if (type.intValue == 4){
    
        if (bikeid.intValue == self.bikeid) {
            
            NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.bikeid];
            NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
            BikeModel *bikemodel = bikemodals.firstObject;
            [self configureNavgationItemTitle:bikemodel.bikename];
        }
    }
    
    [self setupScroview];
}

#pragma mark -  手机感应距离调整通知
-(void)updatevalue:(NSNotification *)data{
    
    NSString *value = data.userInfo[@"value"];
    Inductionvalue = -value.integerValue;
    
    NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM induction_modals WHERE bikeid LIKE '%zd'", self.bikeid];
    NSMutableArray *inducmodals = [LVFmdbTool queryInductionData:nil];
    
    if (inducmodals.count != 0) {
        [LVFmdbTool deleteInductionData:deleteSql];
    }
    
    int induction = 0;
    if ([self.keystate.text isEqualToString:@"手机遥控"]) {
        
        induction = 0;
        
    }else {
        
        induction = 1;
    }
    
    InductionModel *inducmodel = [InductionModel modalWith:self.bikeid inductionValue:Inductionvalue induction:induction];
    [LVFmdbTool insertInductionModel:inducmodel];
}


#pragma mark -  获取报警器固件版本号的逻辑处理
-(void)editionData:(NSNotification *)data{
    
    NSString *passwordHEX = [NSString stringWithFormat:@"A5000007200300"];
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    
    if ([AppDelegate currentAppDelegate].device.upgrate || [AppDelegate currentAppDelegate].device.binding ) {
        
        return;
    }
    
    NSString *editiontitle = data.userInfo[@"edition"];
    
    if ([editiontitle isEqualToString:editionname] && self.bikeid == 0) {
        NSLog(@"退出更新");
        return;
    }
    
    editionname = data.userInfo[@"edition"];
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *bikeid = [NSNumber numberWithInteger:self.bikeid];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/checkfirmupdate"];
    NSDictionary *parameters = @{@"token":token, @"bike_id": bikeid};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            NSString *latest_version = data[@"latest_version"];
            NSNumber *upgrade = data[@"upgrade_flag"];
            downloadhttp = data[@"download"];
            self.latest_version = latest_version;
            if (latest_version.length == 0) {
                return ;
            }
            
            if ([[latest_version substringWithRange:NSMakeRange(0, latest_version.length - 6)] isEqualToString:[editiontitle substringWithRange:NSMakeRange(0, editiontitle.length - 6)]]) {
                
                NSString *NetworktVersion = [latest_version substringFromIndex:latest_version.length- 5];
                NSString *CurrentVersion = [editiontitle substringFromIndex:editiontitle.length- 5];
                CurrentVersion = [CurrentVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
                if (CurrentVersion.length==2) {
                    CurrentVersion  = [CurrentVersion stringByAppendingString:@"0"];
                }else if (CurrentVersion.length==1){
                    CurrentVersion  = [CurrentVersion stringByAppendingString:@"00"];
                }
                NetworktVersion = [NetworktVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
                if (NetworktVersion.length==2) {
                    NetworktVersion  = [NetworktVersion stringByAppendingString:@"0"];
                }else if (NetworktVersion.length==1){
                    NetworktVersion  = [NetworktVersion stringByAppendingString:@"00"];
                }
                
                //当前版本号大于网络版本
                if([CurrentVersion intValue] >= [NetworktVersion intValue])
                {
                    if ([[QFTools currentViewController] isKindOfClass:[SubmitViewController class]]) {
                        [SVProgressHUD showSimpleText:@"已是最新固件"];
                    }
                    return;
                }
                
                if (![latest_version isEqualToString:editiontitle]){
                    
                    if (upgrade.intValue == 0) {
                        
                        self.BluetoothUpgrateAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"检测到固件新版本(约60kb),立即更新吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"立即更新", nil];
                        self.BluetoothUpgrateAlertView.tag = 54;
                        [self.BluetoothUpgrateAlertView show];
                        
                    }else if (upgrade.intValue == 1){
                        
                        self.BluetoothUpgrateAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"检测到固件新版本(约60kb),立即更新吗" delegate:self cancelButtonTitle:nil otherButtonTitles:@"立即更新", nil];
                        self.BluetoothUpgrateAlertView.tag = 55;
                        [self.BluetoothUpgrateAlertView show];
                    }
                }
            }
        }
        else if([dict[@"status"] intValue] == 1001){
            
            //[SVProgressHUD showSimpleText:dict[@"status_info"]];
        }else{
            
            //[SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        NSLog(@"error :%@",error);
        
    }];
}

#pragma mark -  主页面alertview的回调
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (![[AppDelegate currentAppDelegate].device isConnected]) {
        
        [SVProgressHUD showSimpleText:@"蓝牙未连接"];
        return;
    }
    
    if (alertView.tag == 54) {
        if (buttonIndex != [alertView cancelButtonIndex]) {
            self.backView.hidden = NO;
            [custompro startAnimation];
            custompro.presentlab.text = @"车辆正在连接中...";
            
            DfuDownloadFile *downloadfile = [[DfuDownloadFile alloc] init];
            downloadfile.delegate = self;
            [downloadfile startDownload:downloadhttp];
            
            [AppDelegate currentAppDelegate].device.upgrate = YES;
            NSString *passwordHEX = @"A50000061004";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            
        }
    }else if (alertView.tag == 55){
    
        if (buttonIndex != [alertView cancelButtonIndex]) {
            self.backView.hidden = NO;
            [custompro startAnimation];
            custompro.presentlab.text = @"车辆正在连接中...";
            DfuDownloadFile *downloadfile = [[DfuDownloadFile alloc] init];
            downloadfile.delegate = self;
            [downloadfile startDownload:downloadhttp];
            
            [AppDelegate currentAppDelegate].device.upgrate = YES;
            NSString *passwordHEX = @"A50000061004";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
        }
    }
}

#pragma mark -  手机感应开关的通知
-(void)queryInduction:(NSNotification *)data{
    
    NSString *result = data.userInfo[@"data"];
    int induction = 0;
    if ([result isEqualToString:@"on"]) {
        self.keystate.text = @"手机感应";
        self.phinducImg.image = [UIImage imageNamed:@"inductive_display"];
        induction = 1;
    }else if ([result isEqualToString:@"off"]){
        self.keystate.text = @"手机遥控";
        self.phinducImg.image = [UIImage imageNamed:@"no_inductive_display"];
        induction = 0;
    }
    
    NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM induction_modals WHERE bikeid LIKE '%zd'", self.bikeid];
    
    NSMutableArray *inducmodals = [LVFmdbTool queryInductionData:nil];
    if (inducmodals.count != 0) {
        [LVFmdbTool deleteInductionData:deleteSql];
    }
    
    InductionModel *inducmodel = [InductionModel modalWith:self.bikeid inductionValue:Inductionvalue induction:induction];
    [LVFmdbTool insertInductionModel:inducmodel];
}

#pragma mark -  绑定车辆页面发送的切换主页面logo的通知
- (void)switchDevice:(NSNotification *)data{
    
    if ([data.userInfo[@"bikeid"] intValue] != self.bikeid) {
        
        self.keystate.text = @"手机遥控";
        self.phinducImg.image = [UIImage imageNamed:@"no_inductive_display"];
        self.bikeid = [data.userInfo[@"bikeid"] intValue];
    }
    
    [self configureNavgationItemTitle:data.userInfo[@"bikename"]];
    NSString *keyversion =data.userInfo[@"keyversion"];
    [self setupFootView:keyversion.intValue];
}

#pragma mark -  车库页面切换车辆的通知
- (void)coonectSwitchBike:(NSNotification *)data{
    
    NSInteger biketag = [data.userInfo[@"biketag"] integerValue];
    [self switchingVehicle:biketag];
    [self setupPagecontrolNumber];
}

#pragma mark -  顶部导航自定义
-(void)setupNavBar{
    
    [self configureNavgationItemTitle:@"钥匙配置"];
    
    @weakify(self);
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"open_slide_menu"] action:^{
        @strongify(self);
        [self leftClick];
    }];
    
    [self configureRightBarButtonWithImage:[UIImage imageNamed:@"add"] action:^{
        @strongify(self);
        [self showaddView];
    }];
}

#pragma mark -  LrdOutputViewcell
- (void)setupmenu{
    
    LrdCellModel *one = [[LrdCellModel alloc] initWithTitle:@"添加车辆" imageName:@""];
    LrdCellModel *two = [[LrdCellModel alloc] initWithTitle:@"分享车辆" imageName:@""];
    LrdCellModel *three = [[LrdCellModel alloc] initWithTitle:@"扫一扫" imageName:@""];
    self.chooseArray = @[one,two,three];
}

#pragma mark -  LrdOutputView
-(void)showaddView{

    CGFloat x = ScreenWidth - 15;
    CGFloat y = navHeight +5;
    _outputView = [[LrdOutputView alloc] initWithDataArray:self.chooseArray origin:CGPointMake(x, y) width:100 height:44 direction:kLrdOutputViewDirectionRight];
    _outputView.delegate = self;
    _outputView.dismissOperation = ^(){
        _outputView = nil;
    };
    [_outputView pop];
}

#pragma mark -  LrdOutputViewDelegate的回调
- (void)didSelectedAtIndexPath:(NSIndexPath *)indexPath {
    
        //LrdCellModel *model = _chooseArray[indexPath.row];
        if (indexPath.row == 0) {
            
            AddBikeViewController *addVc = [AddBikeViewController new];
            addVc.delegate = self;
            editionname = nil;
            [self.navigationController pushViewController:addVc animated:YES];
            
        }else if (indexPath.row == 1){
            
            BindingUserViewController *bindingUserVc = [BindingUserViewController new];
            bindingUserVc.bikeid = self.bikeid;
            [self.navigationController pushViewController:bindingUserVc animated:YES];
            
        }else{
    
            if (![[AppDelegate currentAppDelegate].device isConnected]) {
                
                [SVProgressHUD showSimpleText:@"蓝牙未连接"];
                return;
                
            }
            
            NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.bikeid];
            NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
            BikeModel *bikemodel = bikemodals.firstObject;
            if (bikemodel.ownerflag == 0) {
                
                [SVProgressHUD showSimpleText:@"子用户无此权限"];
                return;
                
            }
            
            NSString *QuerykeySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' OR type LIKE '%zd' AND bikeid LIKE '%zd'", 2,5,self.bikeid];
            NSMutableArray *keymodals = [LVFmdbTool queryPeripheraData:QuerykeySql];
            
            if (keymodals.count >=2) {
                [SVProgressHUD showSimpleText:@"智能设备最多配两个"];
                return;
            }
            
            TwoDimensionalCodecanViewController *scanVc = [TwoDimensionalCodecanViewController new];
            scanVc.deviceNum = self.bikeid;
            [self.navigationController pushViewController:scanVc animated:YES];
        }
}
#pragma mark -  addBikeDelegate
-(void)bidingBikeSuccess{
    
    [self setupScroview];
}

#pragma mark -  主要UI的绘制
- (void)setupMainview{

    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
    topLine.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topLine];
    
    UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0.5, ScreenWidth, ScreenHeight *.694)];
    headview.backgroundColor = [QFTools colorWithHexString:MainColor];
    [self.view addSubview:headview];
    
    self.queraTime = [MSWeakTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(queryFired:) userInfo:nil repeats:YES dispatchQueue:dispatch_get_main_queue()];
    [self performSelector:@selector(datatimeFired) withObject:nil  afterDelay:1.0];
    
    UIImageView *logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 20, ScreenWidth *.3, ScreenWidth *.3 *.378)];
    logoImage.image = [UIImage imageNamed:@"logo"];
    [headview addSubview:logoImage];
    
    UIImageView *bikestateimage = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 100, 20, 25, 25)];
    //bikestateimage.image = [UIImage imageNamed:@"vehicle_physical_examination_icon"];
    bikestateimage.image = [UIImage imageNamed:@"vehicle_physical_examination_icon"];
    [headview addSubview:bikestateimage];
    //self.bikestateimage = bikestateimage;
    
    UIView *linview2 = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(bikestateimage.frame)+22.5, 20, 1, 45)];
    linview2.backgroundColor = [UIColor whiteColor];
    [headview addSubview:linview2];
    
    UILabel *bikeprompt = [[UILabel alloc] initWithFrame:CGRectMake(linview2.x - 75,CGRectGetMaxY(bikestateimage.frame)+10, 75, 15)];
    bikeprompt.text = @"未连接";
    bikeprompt.textColor = [UIColor redColor];
    bikeprompt.textAlignment = NSTextAlignmentCenter;
    bikeprompt.font = [UIFont systemFontOfSize:17];
    [headview addSubview:bikeprompt];
    self.bikeprompt = bikeprompt;
    
    UILabel *biketemperature = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(linview2.frame)+7.5,bikestateimage.y , 50, 15)];
    biketemperature.text = @"温度";
    biketemperature.font = [UIFont systemFontOfSize:15];
    biketemperature.textColor = [UIColor whiteColor];
    [headview addSubview:biketemperature];
    self.biketemperature = biketemperature;
    
    UILabel *bikestatedetail = [[UILabel alloc]initWithFrame:CGRectMake(biketemperature.x, CGRectGetMaxY(biketemperature.frame)+3, 50, 15)];
    bikestatedetail.text = @"健康";
    bikestatedetail.font = [UIFont systemFontOfSize:16];
    bikestatedetail.textColor = [UIColor whiteColor];
    [headview addSubview:bikestatedetail];
    self.bikestatedetail = bikestatedetail;
    
    UILabel *voltageLab = [[UILabel alloc] initWithFrame:CGRectMake(biketemperature.x, CGRectGetMaxY(bikestatedetail.frame)+3, 50, 15)];
    voltageLab.textColor = [UIColor whiteColor];
    voltageLab.text = @"电压";
    voltageLab.font = [UIFont systemFontOfSize:15];
    [headview addSubview:voltageLab];
    self.voltageLab = voltageLab;
    
    UIButton *bikestatebtn = [[UIButton alloc]initWithFrame:CGRectMake(bikestateimage.x, bikestateimage.y, 50, 50)];
    [bikestatebtn addTarget:self action:@selector(bikestatebtn) forControlEvents:UIControlEventTouchUpInside];
    [headview addSubview:bikestatebtn];

    UIImageView *backview = [[UIImageView alloc] init];
    backview.contentMode = UIViewContentModeScaleAspectFill;
    backview.layer.masksToBounds = YES;
    backview.userInteractionEnabled = YES;
    backview.image = [UIImage imageNamed:@"main_blister"];
    [headview addSubview:backview];
    
    UIImageView *smartbikeimage = [[UIImageView alloc] init];
    if(ScreenHeight <= 568){
        
        backview.frame = CGRectMake(ScreenWidth*.17, ScreenHeight *.15, ScreenWidth*.66, ScreenWidth*.66);
        backview.layer.cornerRadius = ScreenWidth*.33;
        
    }else{
        if (LL_iPhoneX) {
            backview.frame = CGRectMake(ScreenWidth*.15, ScreenHeight *.16, ScreenWidth*.7, ScreenWidth*.7);
        }else{
            backview.frame = CGRectMake(ScreenWidth*.15, ScreenHeight *.12, ScreenWidth*.7, ScreenWidth*.7);
        }
        backview.layer.cornerRadius = ScreenWidth*.35;
    }
    
    smartbikeimage.frame = CGRectMake(backview.height*.14, backview.height*.15, backview.height*.6*1.2, backview.height*.6);
    smartbikeimage.backgroundColor = [UIColor clearColor];
    smartbikeimage.image = [UIImage imageNamed:@"icon_default_model"];
    smartbikeimage.userInteractionEnabled = YES;
    [backview addSubview:smartbikeimage];
    self.smartbikeimage = smartbikeimage;
    
    _pageControl = [[WuPageControl alloc] initWithFrame:CGRectMake(backview.width/2 - 50, CGRectGetMaxY(smartbikeimage.frame) +20, 100, 20)];
    [backview addSubview:_pageControl];
    _pageControl.hidden = YES;
    
    UIImageView *connectstate = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth *.125,headview.height - 77, 50, 30)];
    connectstate.image = [UIImage imageNamed:@"bluetooth_key_break"];
    [headview addSubview:connectstate];
    self.connectstate = connectstate;
    
    UILabel *batteryLab = [[UILabel alloc] initWithFrame:CGRectMake(12.5, 0, 25, 10)];
    batteryLab.textColor = [QFTools colorWithHexString:@"#0043b3"];
    batteryLab.text = @"100%";
    batteryLab.textAlignment = NSTextAlignmentCenter;
    batteryLab.font = [UIFont systemFontOfSize:8];
    [connectstate addSubview:batteryLab];
    batteryLab.hidden = YES;
    self.batteryLab = batteryLab;
    
    UILabel *Bluetoothkey = [[UILabel alloc] initWithFrame:CGRectMake(connectstate.x - 5, CGRectGetMaxY(connectstate.frame)+10, 60, 20)];
    Bluetoothkey.textColor = [UIColor whiteColor];
    Bluetoothkey.text = @"感应钥匙";
    Bluetoothkey.textAlignment = NSTextAlignmentCenter;
    Bluetoothkey.font = [UIFont systemFontOfSize:14];
    [headview addSubview:Bluetoothkey];
    
    UIImageView *islocked = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 15, headview.height - 77, 30, 30)];
    islocked.image = [UIImage imageNamed:@"unlock"];
    [headview addSubview:islocked];
    self.islocked = islocked;
    
    UILabel *Preparedness = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 30, CGRectGetMaxY(islocked.frame)+ 10, 60, 20)];
    Preparedness.text = @"已解锁";
    Preparedness.textAlignment = NSTextAlignmentCenter;
    Preparedness.font = [UIFont systemFontOfSize:14];
    Preparedness.textColor = [UIColor whiteColor];
    [headview addSubview:Preparedness];
    self.Preparedness = Preparedness;
    
    UIImageView *phinducImg = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth*.875 - 50, connectstate.y, 30, 30)];
    phinducImg.image = [UIImage imageNamed:@"no_inductive_display"];
    [headview addSubview:phinducImg];
    self.phinducImg = phinducImg;
    
    UILabel*keystate = [[UILabel alloc] initWithFrame:CGRectMake(phinducImg.x - 15, CGRectGetMaxY(phinducImg.frame) + 10, 60, 20)];
    keystate.textAlignment = NSTextAlignmentCenter;
    keystate.text = @"手机遥控";
    keystate.textColor = [UIColor whiteColor];
    keystate.font = [UIFont systemFontOfSize:14];
    [headview addSubview:keystate];
    self.keystate = keystate;
    [self setupFootView:0];
}

#pragma mark -  布置底部按钮的视图
-(void)setupFootView:(NSInteger)keyversionvalue{
    
    [self.footView removeFromSuperview];
    UIView *footview = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight*.694, ScreenWidth, ScreenHeight*.306 - navHeight)];
    footview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:footview];
    self.footView = footview;
    
    if (keyversionvalue == 2 || keyversionvalue == 6 || keyversionvalue == 9) {
        chamberpot = YES;
        for (int i = 0; i<4; i++) {
            UIButton *controlerBtn = [[UIButton alloc] initWithFrame:CGRectMake(footview.height *.2 + ((ScreenWidth - footview.height *.4 - 180)/3 + 45)*i, footview.height/2 - 30, 45, 45)];
            UILabel *bikesearch = [[UILabel alloc] initWithFrame:CGRectMake(controlerBtn.x, CGRectGetMaxY(controlerBtn.frame)+10, 45, 20)];
            controlerBtn.tag = 20+i;
            bikesearch.tag = 100+i;
            
            if (controlerBtn.tag == 20) {
                [controlerBtn setImage:[UIImage imageNamed:@"icon_bike_lock_blue"] forState:UIControlStateNormal];
            }else if (controlerBtn.tag == 21){
                [controlerBtn setImage:[UIImage imageNamed:@"open_the_switch"] forState:UIControlStateNormal];
            }else if (controlerBtn.tag == 22){
                [controlerBtn setImage:[UIImage imageNamed:@"Seat"] forState:UIControlStateNormal];
            }else if(controlerBtn.tag == 23){
                [controlerBtn setImage:[UIImage imageNamed:@"bike_nomute_icon"] forState:UIControlStateNormal];
            }
            
            if (bikesearch.tag == 100) {
                bikesearch.text = @"上锁";
            }else if (bikesearch.tag == 101){
                bikesearch.text = @"电门";
            }else if (bikesearch.tag == 102){
                bikesearch.text = @"座桶";
            }else if(bikesearch.tag == 103){
                bikesearch.text = @"静音";
            }
            bikesearch.textColor = [UIColor blackColor];
            bikesearch.textAlignment = NSTextAlignmentCenter;
            [footview addSubview:bikesearch];
            [controlerBtn addTarget:self action:@selector(controlerClick:) forControlEvents:UIControlEventTouchUpInside];
            [footview addSubview:controlerBtn];
        }
        
    }else{
        chamberpot = NO;
        for (int i = 0; i<3; i++) {
            UIButton *controlerBtn = [[UIButton alloc] initWithFrame:CGRectMake(footview.height *.33 + ((ScreenWidth - footview.height *.66 - 135)/2 +45)*i , footview.height/4, 45, 45)];
            
            UILabel *bikesearch = [[UILabel alloc] initWithFrame:CGRectMake(controlerBtn.x, CGRectGetMaxY(controlerBtn.frame)+5, 45, 15)];
            controlerBtn.tag = 20+i;
            bikesearch.tag = 100+i;
            
            if (controlerBtn.tag == 20) {
                [controlerBtn setImage:[UIImage imageNamed:@"icon_bike_lock_blue"] forState:UIControlStateNormal];
            }else if (controlerBtn.tag == 21){
                [controlerBtn setImage:[UIImage imageNamed:@"open_the_switch"] forState:UIControlStateNormal];
            }else if (controlerBtn.tag == 22){
                [controlerBtn setImage:[UIImage imageNamed:@"bike_nomute_icon"] forState:UIControlStateNormal];
            }
            if (bikesearch.tag == 100) {
                bikesearch.text = @"上锁";
            }else if (bikesearch.tag == 101){
                bikesearch.text = @"电门";
            }else if (bikesearch.tag == 102){
                bikesearch.text = @"静音";
            }
            bikesearch.textColor = [UIColor blackColor];
            bikesearch.textAlignment = NSTextAlignmentCenter;
            [footview addSubview:bikesearch];
            [controlerBtn addTarget:self action:@selector(controlerClick:) forControlEvents:UIControlEventTouchUpInside];
            [footview addSubview:controlerBtn];
            
            }
    }
    
}

#pragma mark -  有多辆车时，布置滑动视图
-(void)setupScroview{
    [_carousel removeFromSuperview];
    
    _carousel = [[ATCarouselView alloc] initWithFrame:CGRectMake(ScreenWidth/4,ScreenHeight*.15 , ScreenWidth*3/4, ScreenHeight *.4)];
    _carousel.delegate = self;
    
    if ([LVFmdbTool queryBikeData:nil].count == 1) {
        
        _carousel.images = @[[UIImage imageNamed:@"icon_default_model"]];
        _pageControl.hidden = YES;
        
    }else if ([LVFmdbTool queryBikeData:nil].count == 2){
        _pageControl.hidden = NO;
        _carousel.images = @[[UIImage imageNamed:@"icon_default_model"],[UIImage imageNamed:@"icon_default_model"]];
        
    
    }else if ([LVFmdbTool queryBikeData:nil].count == 3){
        _pageControl.hidden = NO;
        _carousel.images = @[[UIImage imageNamed:@"icon_default_model"],[UIImage imageNamed:@"icon_default_model"],[UIImage imageNamed:@"icon_default_model"]];
        
    }else if ([LVFmdbTool queryBikeData:nil].count == 4){
        _pageControl.hidden = NO;
        _carousel.images = @[[UIImage imageNamed:@"icon_default_model"],[UIImage imageNamed:@"icon_default_model"],[UIImage imageNamed:@"icon_default_model"],[UIImage imageNamed:@"icon_default_model"]];
    }else if ([LVFmdbTool queryBikeData:nil].count == 5){
        _pageControl.hidden = NO;
        _carousel.images = @[[UIImage imageNamed:@"icon_default_model"],[UIImage imageNamed:@"icon_default_model"],[UIImage imageNamed:@"icon_default_model"],[UIImage imageNamed:@"icon_default_model"],[UIImage imageNamed:@"icon_default_model"]];
    }
    
    _carousel.currentPageColor = [UIColor orangeColor];
    _carousel.pageColor = [UIColor grayColor];
    _pageControl.numberOfPages = [LVFmdbTool queryBikeData:nil].count;
    [self.view addSubview:_carousel];
    
    [self setupPagecontrolNumber];
}

-(void)setupPagecontrolNumber{
    
    NSMutableArray *bikeAry =[LVFmdbTool queryBikeData:nil];
    for (int i = 0; i< [LVFmdbTool queryBikeData:nil].count; i++) {
        BikeModel *bikemodel = bikeAry[i];
        if ([bikemodel.mac isEqualToString:[USER_DEFAULTS valueForKey:SETRSSI]]) {
            //通过匹配mac地址确定currentPage
            _pageControl.currentPage = i;
        }
    }
}


#pragma mark---ATCarouselViewDelegate回调
- (void)carouselView:(ATCarouselView *)carouselView indexOfClickedImageBtn:(NSUInteger)index {
    [self bikeImageClick];
}

- (void)carouselView:(ATCarouselView *)carouselView indexOfscrollview:(NSInteger)index{

    if ([LVFmdbTool queryBikeData:nil].count == 1) {
        
        return;
    }
    
    NSString *subtypeString;
    if (_pageControl.currentPage >index ) {
        
        subtypeString = kCATransitionFromLeft;
    }else{
        
        subtypeString = kCATransitionFromRight;
    }
    
    [self transitionWithType:kCATransitionPush WithSubtype:subtypeString ForView:self.smartbikeimage];
    NSMutableArray *bikeAry = [LVFmdbTool queryBikeData:nil];
    
    static int i = 0;
    if (i == 0) {
        self.smartbikeimage.image = [UIImage imageNamed:@"icon_default_model"];
        i = 1;
    }else if (i == 1){
        self.smartbikeimage.image = [UIImage imageNamed:@"icon_default_model"];
        i = 0;
    }else if (i == 2){
        self.smartbikeimage.image = [UIImage imageNamed:@"icon_default_model"];
        i = 0;
    }else if (i == 3){
        self.smartbikeimage.image = [UIImage imageNamed:@"icon_default_model"];
        i = 0;
    }else if (i == 4){
        self.smartbikeimage.image = [UIImage imageNamed:@"icon_default_model"];
        i = 0;
    }
    
    if (index == 0) {
        BikeModel *bikemodel = bikeAry.firstObject;
        [self switchingVehicle:bikemodel.bikeid];
    }else if (index == 1){
        
        BikeModel *bikemodel = bikeAry[1];
        [self switchingVehicle:bikemodel.bikeid];
    }else if (index == 2){
        
        BikeModel *bikemodel = bikeAry[2];
        [self switchingVehicle:bikemodel.bikeid];
    }else if (index == 3){
        
        BikeModel *bikemodel = bikeAry[3];
        [self switchingVehicle:bikemodel.bikeid];
    }else if (index == 4){
        
        BikeModel *bikemodel = bikeAry[4];
        [self switchingVehicle:bikemodel.bikeid];
    }
    _pageControl.currentPage = roundf(index);
}

#pragma CATransition动画实现
- (void) transitionWithType:(NSString *) type WithSubtype:(NSString *) subtype ForView : (UIView *) view
{
    //创建CATransition对象
    CATransition *animation = [CATransition animation];
    //设置运动时间
    animation.duration = DURATION;
    //设置运动type
    animation.type = type;
    if (subtype != nil) {
        
        //设置子类
        animation.subtype = subtype;
    }
    
    //设置运动速度
    animation.timingFunction = UIViewAnimationOptionCurveEaseInOut;
    
    [view.layer addAnimation:animation forKey:@"animation"];
}



#pragma mark -  切换车辆的push动画，UIView实现动画
- (void) animationWithView : (UIView *)view WithAnimationTransition : (UIViewAnimationTransition) transition
{
    [UIView animateWithDuration:DURATION animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationTransition:transition forView:view cache:YES];
    }];
}

#pragma mark -  改变label中部分字体的颜色和字体大小
-(void)setTextColor:(UILabel *)label FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:label.text];
    //设置字号
    [str addAttribute:NSFontAttributeName value:font range:range];
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:range];
    
    label.attributedText = str;
}

#pragma mark - 控制器释放
- (void)dealloc {
    
    [[AppDelegate currentAppDelegate].device stopScan];
    [self unObserveAllNotifications];
    [self.queraTime invalidate];
    self.queraTime = nil;
    [self.BluetoothUpgrateAlertView dismissWithClickedButtonIndex:0 animated:YES];
    NSLog(@"bikeview被释放了");
}

- (void)unObserveAllNotifications {
    
    [NSNOTIC_CENTER removeObserver:self name:kJPFNetworkDidSetupNotification object:nil];
    [NSNOTIC_CENTER removeObserver:self name:kJPFNetworkDidCloseNotification object:nil];
    [NSNOTIC_CENTER removeObserver:self name:kJPFNetworkDidRegisterNotification object:nil];
    [NSNOTIC_CENTER removeObserver:self name:kJPFNetworkDidLoginNotification object:nil];
    
    [NSNOTIC_CENTER removeObserver:self name:kJPFNetworkDidReceiveMessageNotification object:nil];
    [NSNOTIC_CENTER removeObserver:self name:kJPFServiceErrorNotification object:nil];
    [NSNOTIC_CENTER removeObserver:self name:KNotification_QueryData object:nil];
    
    [NSNOTIC_CENTER removeObserver:self name:@"Inductionswitch" object:nil];
    [NSNOTIC_CENTER removeObserver:self name:KNotification_SwitchDevice object:nil];
    [NSNOTIC_CENTER removeObserver:self name:KNotification_RemoteJPush object:nil];
    [NSNOTIC_CENTER removeObserver:self name:KNotification_UpdateValue object:nil];
    [NSNOTIC_CENTER removeObserver:self name:KNotification_SwitchingVehicle object:nil];
}

- (void)networkDidSetup:(NSNotification *)notification {
    
    NSLog(@"已连接");
}

- (void)networkDidClose:(NSNotification *)notification {
    
    NSLog(@"未连接");
    
}

- (void)networkDidRegister:(NSNotification *)notification {
        NSLog(@"已注册");
}

- (void)networkDidLogin:(NSNotification *)notification {
        NSLog(@"已登录");
    
    if ([JPUSHService registrationID]) {
        
        NSLog(@"get RegistrationID");
    }
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *title = [userInfo valueForKey:@"title"];
    NSString *content = [userInfo valueForKey:@"content"];
    NSDictionary *extra = [userInfo valueForKey:@"extras"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    NSString *currentContent = [NSString
                                stringWithFormat:
                                @"收到自定义消息:%@\ntitle:%@\ncontent:%@\nextra:%@\n",
                                [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                               dateStyle:NSDateFormatterNoStyle
                                                               timeStyle:NSDateFormatterMediumStyle],
                                title, content, [self logDic:extra]];
    NSLog(@"%@", currentContent);
    
}

// log NSSet with UTF8
// if not ,log will be \Uxxx
- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 = [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str = [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}

- (void)serviceError:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSString *error = [userInfo valueForKey:@"error"];
    NSLog(@"%@", error);
}


#pragma mark - 每0.5秒发送的查询码
-(void)queryFired:(MSWeakTimer *)timer{
    
    if (![[AppDelegate currentAppDelegate].device isConnected]) {
        //NSLog(@"time was invalite");
        return;
    }
    
    if (![AppDelegate currentAppDelegate].device.binding && ![AppDelegate currentAppDelegate].device.upgrate && ![AppDelegate currentAppDelegate].device.bindingaccessories) {
        
        NSString *passwordHEX = @"A50000061001";
        [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    }
}

#pragma mark - 进入首页后的延时，连接报警器的延时机制，给蓝牙中控启动的时间（只执行一次）
-(void)datatimeFired{
    
    NSString*deviceuuid=[USER_DEFAULTS stringForKey:Key_DeviceUUID];
    if (deviceuuid) {
        [self connectDevice];
        [self setupScroview];
        return;
    }
    
    NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE id LIKE '%zd'", 1];
    NSMutableArray *modals = [LVFmdbTool queryBikeData:fuzzyQuerySql];
    
    if (modals.count == 0) {
        return;
    }
    
        BikeModel *model = modals.firstObject;
        [self configureNavgationItemTitle:model.bikename];
        self.mac = model.mac;
        
        [USER_DEFAULTS setObject: model.mac forKey:Key_MacSTRING];
        [USER_DEFAULTS synchronize];
        self.ownerflag = model.ownerflag;
        if (model.ownerflag == 1) {
        
            self.password = model.mainpass;
            NSString* masterpwd = [QFTools toHexString:(long)[self.password longLongValue]];
            
            if(masterpwd.length !=8){
                
                int masterpwdCount = 8 - (int)masterpwd.length;
                for (int i = 0; i<masterpwdCount; i++) {
                    masterpwd = [@"0" stringByAppendingFormat:@"%@",masterpwd];
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:masterpwd,@"main",nil];
                    [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                    [USER_DEFAULTS synchronize];
                });
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:masterpwd,@"main",nil];
                    [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                    [USER_DEFAULTS synchronize];
                });
            }
            
        }else if (model.ownerflag == 0){
            
            self.password = model.password;
            NSString* childpwd = [QFTools toHexString:(long)[self.password longLongValue]];
            if(childpwd.length !=8){
                
                int childpwdCount = 8 - (int)childpwd.length;
                for (int i = 0; i<childpwdCount; i++) {
                    
                    childpwd = [@"0" stringByAppendingFormat:@"%@",childpwd];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:childpwd,@"main",nil];
                    [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                    [USER_DEFAULTS synchronize];
                });
                
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:childpwd,@"main",nil];
                    [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                    [USER_DEFAULTS synchronize];
                    
                });
            }
        }
        
        NSString *infoModalSql = [NSString stringWithFormat:@"SELECT * FROM info_modals WHERE bikeid LIKE '%zd'", model.bikeid];
        NSMutableArray *infomodals = [LVFmdbTool queryModelData:infoModalSql];
        ModelInfo *modelinfo = infomodals.firstObject;
        self.bikeid = modelinfo.bikeid;
    
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", model.bikeid];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    [self setupFootView:bikemodel.keyversion.intValue];
    
    NSString *QueryuuidSql = [NSString stringWithFormat:@"SELECT * FROM peripherauuid_modals WHERE mac LIKE '%@'", model.mac];
    NSMutableArray *uuidmodals = [LVFmdbTool queryPeripheraUUIDData:QueryuuidSql];
    PeripheralUUIDModel *peripheraluuidmodel = uuidmodals.firstObject;
    if (uuidmodals.count == 0) {
        
        [[AppDelegate currentAppDelegate].device startScan];
    }else{
        
        uuidstring = peripheraluuidmodel.uuid;
        [self showDeviceList];
    }
    
    [self setupScroview];
}

#pragma mark - 有记录的车辆，进行连接车辆
-(void)connectDevice{
    
    NSString*deviceuuid=[USER_DEFAULTS stringForKey:Key_DeviceUUID];
    NSString *uuidQuerySql = [NSString stringWithFormat:@"SELECT * FROM peripherauuid_modals WHERE uuid LIKE '%%%@%%'", deviceuuid];
    NSMutableArray *uuidmodals = [LVFmdbTool queryPeripheraUUIDData:uuidQuerySql];
    PeripheralUUIDModel *peripherauuidmodel = uuidmodals.firstObject;
    NSString *mac = peripherauuidmodel.mac;
    
    NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE mac LIKE '%%%@%%'", mac];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:fuzzyQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    self.bikeid = bikemodel.bikeid;
    
    for(BikeModel *model in bikemodals){
        
        [self configureNavgationItemTitle:model.bikename];
        self.mac = model.mac;
        
        self.ownerflag = model.ownerflag;
        if (model.ownerflag == 1) {
            
            self.password = model.mainpass;
            NSString* masterpwd = [QFTools toHexString:(long)[self.password longLongValue]];
            
            if(masterpwd.length != 8){
                
                int masterpwdCount = 8 - (int)masterpwd.length;
                for (int i = 0; i<masterpwdCount; i++) {
                    masterpwd = [@"0" stringByAppendingFormat:@"%@",masterpwd];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:masterpwd,@"main",nil];
                    [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                    [USER_DEFAULTS synchronize];
                });
                
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:masterpwd,@"main",nil];
                    [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                    [USER_DEFAULTS synchronize];
                });                
            }
            
        }else if (model.ownerflag == 0){
            
            self.password = model.password;
            NSString* masterpwd = [QFTools toHexString:(long)[self.password longLongValue]];
            if(masterpwd.length != 8){
                
                int masterpwdCount = 8 - (int)masterpwd.length;
                for (int i = 0; i<masterpwdCount; i++) {
                    masterpwd = [@"0" stringByAppendingFormat:@"%@",masterpwd];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:masterpwd,@"main",nil];
                    [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                    [USER_DEFAULTS synchronize];
                });
                
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:masterpwd,@"main",nil];
                    [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                    [USER_DEFAULTS synchronize];
                });
            }
        }
    }
    
    NSString *fuzzyinduSql = [NSString stringWithFormat:@"SELECT * FROM induction_modals WHERE bikeid LIKE '%zd'", self.bikeid];
    NSMutableArray *modals = [LVFmdbTool queryInductionData:fuzzyinduSql];
    InductionModel *indumodel = modals.firstObject;
    
    if (modals.count == 0) {
        self.keystate.text = @"手机遥控";
        self.phinducImg.image = [UIImage imageNamed:@"no_inductive_display"];
    }else if(indumodel.induction == 0){
        self.keystate.text = @"手机遥控";
        self.phinducImg.image = [UIImage imageNamed:@"no_inductive_display"];
    }else if (indumodel.induction == 1){
        self.keystate.text = @"手机感应";
        self.phinducImg.image = [UIImage imageNamed:@"inductive_display"];
    }
    
    [self setupFootView:bikemodel.keyversion.intValue];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){

        [USER_DEFAULTS setObject: self.mac forKey:Key_MacSTRING];
        [USER_DEFAULTS synchronize];
    });
}

#pragma mark - 获取到车辆的UUID后的连接
-(void)showDeviceList
{
    [[AppDelegate currentAppDelegate].device stopScan];
    
    NSString *fuzzyinduSql = [NSString stringWithFormat:@"SELECT * FROM induction_modals WHERE bikeid LIKE '%zd'", self.bikeid];
    NSMutableArray *modals = [LVFmdbTool queryInductionData:fuzzyinduSql];
    
    InductionModel *indumodel = modals.firstObject;
    
    if (modals.count == 0) {
        
        self.keystate.text = @"手机遥控";
        self.phinducImg.image = [UIImage imageNamed:@"no_inductive_display"];
    }else if(indumodel.induction == 0){
        self.keystate.text = @"手机遥控";
        self.phinducImg.image = [UIImage imageNamed:@"no_inductive_display"];
    }else if (indumodel.induction == 1){
        
        self.keystate.text = @"手机感应";
        self.phinducImg.image = [UIImage imageNamed:@"inductive_display"];
    }
    
    if (uuidstring) {
        
        [[AppDelegate currentAppDelegate].device retrievePeripheralWithUUID:uuidstring];//导入外设 根据UUID
        [[AppDelegate currentAppDelegate].device connect];
        [USER_DEFAULTS setObject: uuidstring forKey:Key_DeviceUUID];
        [USER_DEFAULTS synchronize];
        
        NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM peripherauuid_modals WHERE uuid LIKE '%@'",    uuidstring];
        NSMutableArray *modals = [LVFmdbTool queryPeripheraUUIDData:fuzzyQuerySql];
        NSString *phonenum = [QFTools getdata:@"phone_num"];
        if (modals.count == 0) {
            
            PeripheralUUIDModel *peripheramodel = [PeripheralUUIDModel modalWith:phonenum bikeid:self.bikeid mac:self.mac uuid:uuidstring];
            [LVFmdbTool insertPeripheralUUIDModel:peripheramodel];
        }
        
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:NSLocalizedString( @"请确认设备已开启或重启设备", @"") delegate:nil cancelButtonTitle:NSLocalizedString( @"确定", @"") otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark---主页车辆扫描的回调
-(void)didDiscoverPeripheral:(NSInteger)tag :(CBPeripheral *)peripheral scanData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"主页扫描电动车");
    if ([AppDelegate currentAppDelegate].device.upgrate) {
        
        if (peripheral.name.length == 7) {
            
        if([[peripheral.name substringWithRange:NSMakeRange(0, 7)]isEqualToString: @"Qgj-Ota"]){
            
            DeviceModel *model=[[DeviceModel alloc]init];
            model.peripher=peripheral;
            model.rssi = RSSI;
            [rssiList addObject:model];
            [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectDfuModel) object:nil];
            [self performSelector:@selector(connectDfuModel) withObject:nil afterDelay:2];
        }
        
        }else if (peripheral.name.length == 11){
        
            if([[peripheral.name substringWithRange:NSMakeRange(0, 11)]isEqualToString: @"Qgj-DfuTarg"]){
                
                DeviceModel *model=[[DeviceModel alloc]init];
                model.peripher=peripheral;
                model.rssi = RSSI;
                [rssiList addObject:model];
                
                [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectDfuModel) object:nil];
                [self performSelector:@selector(connectDfuModel) withObject:nil afterDelay:2];
            }
        }else if (peripheral.name.length == 8){
            
            if([[peripheral.name substringWithRange:NSMakeRange(0, 8)]isEqualToString: @"Qgj-DfuT"]){
                
                DeviceModel *model=[[DeviceModel alloc]init];
                model.peripher=peripheral;
                model.rssi = RSSI;
                [rssiList addObject:model];
                
                [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectDfuModel) object:nil];
                [self performSelector:@selector(connectDfuModel) withObject:nil afterDelay:2];
            }
        }
    }else if (![AppDelegate currentAppDelegate].device.upgrate){
    
        if (peripheral.name.length < 13) {
            
            return;
        }
        
    if([[peripheral.name substringWithRange:NSMakeRange(0, 13)]isEqualToString: @"Qgj-SmartBike"]){
        const char *valueString = [[[advertisementData objectForKey:@"kCBAdvDataManufacturerData"] description] cStringUsingEncoding: NSUTF8StringEncoding];
        
        if (valueString == NULL) {
            return;
        }
        
        NSString *title = [[NSString alloc] initWithUTF8String:valueString];
        
        if ([self.mac isEqualToString:[[title substringWithRange:NSMakeRange(5, 4)] stringByAppendingString:[title substringWithRange:NSMakeRange(10, 8)]].uppercaseString]){
            uuidstring = peripheral.identifier.UUIDString;
            [self showDeviceList];
        }
     }
   }
}


#pragma mark - 点击进入车辆故障页面
- (void)bikestatebtn{
    
    if (![[AppDelegate currentAppDelegate].device isConnected]) {

        [SVProgressHUD showSimpleText:@"蓝牙未连接"];
        return;

    }
    FaultViewController *faultVc = [FaultViewController new];
    faultVc.hidesBottomBarWhenPushed = YES;
    faultVc.motorfaultNum = self.faultmodel.motorfault;
    faultVc.rotationfaultNum = self.faultmodel.rotationfault;
    faultVc.controllerfaultNum = self.faultmodel.controllerfault;
    faultVc.brakefaultNum = self.faultmodel.brakefault;
    faultVc.lackvoltageNum = self.faultmodel.lackvoltage;
    faultVc.motordefectNum = self.faultmodel.motordefectNum;
    [self.navigationController pushViewController:faultVc animated:YES];
    
}

#pragma mark - 底部控制按钮，app主页底部的控制按钮逻辑
-(void)controlerClick:(UIButton *)btn{

    if (![[AppDelegate currentAppDelegate].device isConnected]) {
        
        [SVProgressHUD showSimpleText:@"蓝牙未连接"];
        return;
        
    }else if (querydate == nil){
    
        return;
    }
    
    NSString *binary = [QFTools getBinaryByhex:[querydate substringWithRange:NSMakeRange(12, 2)]];
    if (btn.tag == 20) {
        if ([[binary substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"0"]) {
            if (riding) {
                [SVProgressHUD showSimpleText:@"骑行状态不能设防"];
                return;
            }
            if (!self.batteryLab.hidden) {
                [SVProgressHUD showSimpleText:@"感应优先，设防无效"];
                return;
            }
            NSString *passwordHEX = @"A5000007200102";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
        }else if ([[binary substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"1"]){
            NSString *passwordHEX = @"A5000007200101";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
        }
    }else if (btn.tag == 21){
        if ([[binary substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"0"]) {
            
            if ([[binary substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"1"]){
                [SVProgressHUD showSimpleText:@"请先解锁"];
                return;
            }
            NSString *passwordHEX = @"A5000007200103";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
        }else if ([[binary substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"1"]){
            NSString *passwordHEX = @"A5000007200104";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
        }
    }else if (btn.tag == 22){
    
        if (self->fortification) {
            [SVProgressHUD showSimpleText:@"请先解锁"];
            return;
        }
        
        if (chamberpot) {
            if(touchCount<1){
                touchCount++;
                NSString *passwordHEX = @"A5000007200107";
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];;//不是频繁操作执行对应点击事件
                [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeSetting) object:nil];
                [self performSelector:@selector(timeSetting) withObject:nil afterDelay:1.0];//1秒后点击次数清零
            }else{
                
                [SVProgressHUD showSimpleText:@"点击过于频繁"];
            }
            
        }else if (!chamberpot){
            
            if ([[binary substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"0"]) {
                
                NSString *passwordHEX = @"A5000007200105";
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                
            }else if ([[binary substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"1"]) {
                
                NSString *passwordHEX = @"A5000007200106";
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            }
        }
    }
    else if (btn.tag == 23){
    
        if ([[binary substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"0"]) {
            
            NSString *passwordHEX = @"A5000007200105";
            
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            
        }else if ([[binary substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"1"]){
            
            NSString *passwordHEX = @"A5000007200106";
            
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
        }

    
  }
    
}

#pragma mark - 避免重复开启电子锁，等待几秒后的操作
-(void)timeSetting
{
    touchCount=0;
}


#pragma mark - 0.5循环秒查询蓝牙数据返回
-(void)BikeViewquerySuccess:(NSNotification *)data{
    
    UIButton*btn1=(UIButton*)[self.view viewWithTag:20];
    UIButton*btn2=(UIButton*)[self.view viewWithTag:21];
    UIButton*btn3=(UIButton*)[self.view viewWithTag:23];
    UIButton*btn4=(UIButton*)[self.view viewWithTag:22];
    
    UILabel* lab1=(UILabel*)[self.view viewWithTag:100];
    NSString *date = data.userInfo[@"data"];
    NSData *datevalue = [ConverUtil parseHexStringToByteArray:date];
    
    Byte *byte=(Byte *)[datevalue bytes];
    
    if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1001"]) {
        
        querydate = date;
        
        NSString *binary = [QFTools getBinaryByhex:[date substringWithRange:NSMakeRange(12, 2)]];
        
        NSString *bikestate = [QFTools getBinaryByhex:[date substringWithRange:NSMakeRange(28, 2)]];
        
        NSString *keystatenumber = [QFTools getBinaryByhex:[date substringWithRange:NSMakeRange(16, 2)]];
        
        [[QFTools getBinaryByhex:[date substringWithRange:NSMakeRange(22, 2)]] intValue];
        
        [[QFTools getBinaryByhex:[date substringWithRange:NSMakeRange(24, 2)]] intValue];
        
        if (byte[14] == 0) {
            self.bikestatedetail.text = @"健康";
            self.bikestatedetail.textColor = [UIColor whiteColor];
            
            self.faultmodel.motorfault = 0;
            self.faultmodel.rotationfault = 0;
            self.faultmodel.controllerfault = 0;
            self.faultmodel.brakefault = 0;
            self.faultmodel.lackvoltage = 0;
            self.faultmodel.motordefectNum = 0;
            
        }else{
        
            self.bikestatedetail.text = @"故障";
            self.bikestatedetail.textColor = [UIColor redColor];
            
            if([[bikestate substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"1"]){
                //电机故障
                self.faultmodel.motorfault = 1;
                
            }else if([[bikestate substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"0"]){
            
                self.faultmodel.motorfault = 0;
            }
            
            if([[bikestate substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"1"]){
                //转把故障
                self.faultmodel.rotationfault = 1;
                
            }else if([[bikestate substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"0"]){
                
                self.faultmodel.rotationfault = 0;
            }
            
            if([[bikestate substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"1"]){
                //控制器故障
                
                self.faultmodel.controllerfault = 1;
            }else if([[bikestate substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"0"]){
                
                self.faultmodel.controllerfault = 0;
            }
            
            if([[bikestate substringWithRange:NSMakeRange(4, 1)] isEqualToString:@"1"]){
                //控制器故障
                
                self.faultmodel.motordefectNum = 1;
            }else if([[bikestate substringWithRange:NSMakeRange(4, 1)] isEqualToString:@"0"]){
                
                self.faultmodel.motordefectNum = 0;
            }
            
            if([[bikestate substringWithRange:NSMakeRange(3, 1)] isEqualToString:@"1"]){
                //刹车故障
                self.faultmodel.brakefault = 1;
                
            }else if([[bikestate substringWithRange:NSMakeRange(3, 1)] isEqualToString:@"0"]){
                
                self.faultmodel.brakefault = 0;
            }
            
            if([[bikestate substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"1"]){
                //电池欠压故障
                self.faultmodel.lackvoltage = 1;
                
            }else if([[bikestate substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"0"]){
                
                self.faultmodel.lackvoltage = 0;
            }

        }
        
        if ([[keystatenumber substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"1"]) {
            
            self.connectstate.image = [UIImage imageNamed:@"bluetooth_key_connect"];
            self.batteryLab.hidden = NO;
        }else if ([[keystatenumber substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"0"]){
            self.batteryLab.hidden = YES;
            self.connectstate.image = [UIImage imageNamed:@"bluetooth_key_break"];
        }
        int value = byte[15];
        self.batteryLab.text = [NSString stringWithFormat:@"%d%%",value];
        float wendu = BUILD_UINT16(byte[12],byte[11]) * .1;
        float dianya = BUILD_UINT16(byte[10],byte[9]) * .1;
        
        self.biketemperature.text = [NSString stringWithFormat:@"%d ℃",(int)wendu];
        
        [self setTextColor:self.biketemperature FontNumber:[UIFont systemFontOfSize:11] AndRange:NSMakeRange(self.biketemperature.text.length - 2, 2) AndColor:[QFTools colorWithHexString:@"#ffffff"]];
        
        self.voltageLab.text = [NSString stringWithFormat:@"%d V",(int)dianya];
        [self setTextColor:self.voltageLab FontNumber:[UIFont systemFontOfSize:11] AndRange:NSMakeRange(self.voltageLab.text.length - 1, 1) AndColor:[QFTools colorWithHexString:@"#ffffff"]];
        if ([[binary substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"0"]) {
            
            [btn1 setImage:[UIImage imageNamed:@"icon_bike_lock_blue"] forState:UIControlStateNormal];
            fortification = NO;
            self.Preparedness.text = @"已解锁";
            lab1.text = @"上锁";
            
        }else if ([[binary substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"1"]){
            
            [btn1 setImage:[UIImage imageNamed:@"icon_bike_unlock_blue"] forState:UIControlStateNormal];
            fortification = YES;
            self.Preparedness.text = @"已上锁";
            lab1.text = @"解锁";
        }
        
        if (!fortification && powerswitch) {
            self.islocked.image = [UIImage imageNamed:@"riding"];
            self.Preparedness.text = @"骑行中";
            riding = YES;
        }else if (fortification && !powerswitch){
        
            self.islocked.image = [UIImage imageNamed:@"lock"];
        
        }else if (!fortification && !powerswitch){
        
            self.islocked.image = [UIImage imageNamed:@"unlock"];
        
        }
        
        
        if ([[binary substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"0"]) {
            
            [btn2 setImage:[UIImage imageNamed:@"open_the_switch"] forState:UIControlStateNormal];
            powerswitch = NO;
            riding = NO;
            
        }else{
            
            [btn2 setImage:[UIImage imageNamed:@"close_the_switch"] forState:UIControlStateNormal];
            powerswitch = YES;
        }
        
        if ([[binary substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"0"]) {
            
            if (!chamberpot) {
                
                [btn4 setImage:[UIImage imageNamed:@"bike_nomute_icon"] forState:UIControlStateNormal];
                
            }else{
            
                [btn3 setImage:[UIImage imageNamed:@"bike_nomute_icon"] forState:UIControlStateNormal];
            }
            
        }else{
            
            if (!chamberpot) {
                
                [btn4 setImage:[UIImage imageNamed:@"bike_mute_icon"] forState:UIControlStateNormal];
                
            }else{
            
                [btn3 setImage:[UIImage imageNamed:@"bike_mute_icon"] forState:UIControlStateNormal];
            }
        }
        
        int rssi = byte[13] - 255;
        if ([self.keystate.text isEqualToString:@"手机感应"]) {
            NSString *fuzzyinduSql = [NSString stringWithFormat:@"SELECT * FROM induction_modals WHERE bikeid LIKE '%zd'", self.bikeid];
            NSMutableArray *modals = [LVFmdbTool queryInductionData:fuzzyinduSql];
            InductionModel *indumodel = modals.firstObject;
            NSInteger rssivalue;
            
            if (modals == 0 || indumodel.inductionValue == 0) {
                rssivalue = -67;
            }else{
                rssivalue = indumodel.inductionValue;
            }
            
            if (rssi >= rssivalue && fortification) {
                
                if (riding) {
                    return;
                }
                
                NSString *passwordHEX = @"A5000007200101";
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                
            }else if (rssi < rssivalue - 8 && !fortification){
                
                if (riding) {
                    return;
                }
                
                NSString *passwordHEX = @"A5000007200102";
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            }
        }
        
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"6002"]){
    
       // self.bikestatedetail.text = @"车辆状态:异常";
    }else if([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1002"]){
        
        if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
            [SVProgressHUD showSimpleText:@"连接失效，请重新绑定"];
            [[AppDelegate currentAppDelegate].device remove];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                self.bikeprompt.text = @"未连接";
                self.bikeprompt.textColor = [UIColor redColor];
            });
            
        }else if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
        
            [[AppDelegate currentAppDelegate].device readDiviceInformation];
            self.bikeprompt.text = @"车辆体检";
            self.bikeprompt.textColor = [UIColor whiteColor];
            
        }
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1004"]) {
        
        if ([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"00"]) {
            
            [SVProgressHUD showSimpleText:@"进入固件升级失败"];
        }else if([[date substringWithRange:NSMakeRange(12, 2)] isEqualToString:@"01"]){
            
            [AppDelegate currentAppDelegate].device.deviceStatus=0;
            [self updateDeviceStatusAction:nil];
            [rssiList removeAllObjects];//清空设备model数组
            [[AppDelegate currentAppDelegate].device remove];
            [self performSelector:@selector(breakconnect) withObject:nil afterDelay:2];
        }
        
        [self performSelector:@selector(connectDefaultModel) withObject:nil afterDelay:30];
    }
    
}

#pragma mark - 进入固件升级先主动断开再连接
- (void)breakconnect{

    [AppDelegate currentAppDelegate]. device.deviceStatus=0;
    self.bikeprompt.text = @"未连接";
    self.bikeprompt.textColor = [UIColor redColor];
    [[AppDelegate currentAppDelegate].device startScan];
}

-(void)connectDefaultModel{

    if (self.isTransferring){
        
    
    }else{
        [SVProgressHUD showSimpleText:@"固件升级失败"];
        [[AppDelegate currentAppDelegate].device stopScan];
        [custompro stopAnimation];
        self.backView.hidden = YES;
        [AppDelegate currentAppDelegate].device.centralManager.delegate=[AppDelegate currentAppDelegate].device;
        [AppDelegate currentAppDelegate].device.peripheral.delegate=[AppDelegate currentAppDelegate].device;
        [self performSelector:@selector(connectBle) withObject:nil afterDelay:2];
    }

}

#pragma mark - 进入升级模式后连接车辆
- (void)connectDfuModel{
    
    [[AppDelegate currentAppDelegate].device stopScan];
    [custompro stopAnimation];
    if(rssiList.count>0){
        custompro.presentlab.text = @"车辆正在升级中...";
        //self.backView.hidden = NO;
        NSArray *ascendArray = [rssiList sortedArrayUsingComparator:^NSComparisonResult(DeviceModel* obj1, DeviceModel* obj2){
                                    float f1 = fabsf([obj1.rssi floatValue]);
                                    float f2 = fabsf([obj2.rssi floatValue]);
                                    if (f1 > f2)
                                    {
                                        return (NSComparisonResult)NSOrderedDescending;
                                    }
                                    if (f1 < f2)
                                    {
                                        return (NSComparisonResult)NSOrderedAscending;
                                    }
                                    return (NSComparisonResult)NSOrderedSame;
                                }];
        
        selectedPeripheral = [[ascendArray objectAtIndex:0] peripher];
        [dfuOperations setCentralManager:[AppDelegate currentAppDelegate].device.centralManager];
        [dfuOperations connectDevice:[[ascendArray objectAtIndex:0] peripher]];
        [self performSelector:@selector(connectDfuSuccess) withObject:nil afterDelay:2];
        
    }else{
        [AppDelegate currentAppDelegate].device.upgrate = NO;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:NSLocalizedString( @"请确认设备是否断电", @"") delegate:nil cancelButtonTitle:NSLocalizedString( @"确定", @"") otherButtonTitles:nil, nil];
        [alert show];
        self.backView.hidden = YES;
        [AppDelegate currentAppDelegate].device.centralManager.delegate=[AppDelegate currentAppDelegate].device;
        [AppDelegate currentAppDelegate].device.peripheral.delegate=[AppDelegate currentAppDelegate].device;
        [self performSelector:@selector(connectBle) withObject:nil afterDelay:2];
    }


}

#pragma mark - 主页面车辆点击
- (void)bikeImageClick{
    
    SubmitViewController *submitVc = [SubmitViewController new];
    submitVc.delegate = self;
    submitVc.deviceNum = self.bikeid;
    [self.navigationController pushViewController:submitVc animated:YES];
}

#pragma mark - 修改车名
-(void) addViewController:(SubmitViewController *)wuschool didAddString:(NSString *)nameText deviceTag:(NSInteger)deviceNum
{
    if (self.bikeid == deviceNum) {
        
        [self configureNavgationItemTitle:nameText];
    }
}

#pragma mark - 固件升级处理
-(void)submitBegainUpgrate{
    
    if (![[AppDelegate currentAppDelegate].device isConnected]) {

        [SVProgressHUD showSimpleText:@"蓝牙未连接"];
        return;
    }
    [[AppDelegate currentAppDelegate].device readDiviceInformation];
}

-(void)submitUnbundDevice{
    
    NSMutableArray *bikeAry = [LVFmdbTool queryBikeData:nil];
    BikeModel *bikemodel = bikeAry.firstObject;
    [self switchingVehicle:bikemodel.bikeid];//默认连接第一辆车
    
    [self setupScroview];
}

#pragma mark - 切换车辆处理
- (void)switchingVehicle:(NSInteger)bikeid{
    
    [[AppDelegate currentAppDelegate].device stopScan];
    NSString *QueryBikeSql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", bikeid];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:QueryBikeSql];
    BikeModel *model = bikemodals.firstObject;
    [self configureNavgationItemTitle:model.bikename];
    self.mac = model.mac;
    [USER_DEFAULTS setValue:model.mac forKey:SETRSSI];
    [USER_DEFAULTS setObject: model.mac forKey:Key_MacSTRING];
    [USER_DEFAULTS synchronize];
        if (self.bikeid == model.bikeid && [[AppDelegate currentAppDelegate].device isConnected]) {
            
            [SVProgressHUD showSimpleText:@"设备已连接"];
            
            return;
        }else{
        
            if ([[AppDelegate currentAppDelegate].device isConnected]) {
                
                [[AppDelegate currentAppDelegate].device remove];
                self.bikeprompt.text = @"未连接";
                self.bikeprompt.textColor = [UIColor redColor];
                self.connectstate.image = [UIImage imageNamed:@"bluetooth_key_break"];
                self.batteryLab.hidden = YES;
            }
        }
        uuidstring = nil;
        editionname = nil;
        self.ownerflag = model.ownerflag;
        if (model.ownerflag == 1) {
            
            self.password = model.mainpass;
            NSString* masterpwd = [QFTools toHexString:(long)[self.password longLongValue]];
            
            if(masterpwd.length !=8){
                int masterpwdCount = 8 - (int)masterpwd.length;
                for (int i = 0; i<masterpwdCount; i++) {
                    masterpwd = [@"0" stringByAppendingFormat:@"%@",masterpwd];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:masterpwd,@"main",nil];
                    [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                    [USER_DEFAULTS synchronize];
                });
                
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:masterpwd,@"main",nil];
                    [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                    [USER_DEFAULTS synchronize];
                });
            }
            
        }else if (model.ownerflag == 0){
            
            self.password = model.password;
            NSString* masterpwd = [QFTools toHexString:(long)[self.password longLongValue]];
            
            if(masterpwd.length !=8){
                
                int masterpwdCount = 8 - (int)masterpwd.length;
                for (int i = 0; i<masterpwdCount; i++) {
                    masterpwd = [@"0" stringByAppendingFormat:@"%@",masterpwd];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:masterpwd,@"main",nil];
                    [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                    [USER_DEFAULTS synchronize];
                });
                
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:masterpwd,@"main",nil];
                    [USER_DEFAULTS setObject:userDic forKey:passwordDIC];
                    [USER_DEFAULTS synchronize];
                });
            }
        }
    
        NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM info_modals WHERE bikeid LIKE '%zd'", model.bikeid];
        NSMutableArray *modals = [LVFmdbTool queryModelData:fuzzyQuerySql];
        ModelInfo *modelinfo = modals.firstObject;
        self.bikeid = modelinfo.bikeid;
    
    NSString *QueryuuidSql = [NSString stringWithFormat:@"SELECT * FROM peripherauuid_modals WHERE mac LIKE '%@'", model.mac];
    NSMutableArray *uuidmodals = [LVFmdbTool queryPeripheraUUIDData:QueryuuidSql];
    PeripheralUUIDModel *peripheraluuidmodel = uuidmodals.firstObject;
    if (uuidmodals.count == 0) {
        
        [[AppDelegate currentAppDelegate].device startScan];
    }else{
    
        uuidstring = peripheraluuidmodel.uuid;
        [self showDeviceList];
    }
    
    [self setupFootView:model.keyversion.intValue];
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//******************????升级文件下载代码??*******************//


#pragma mark - DfuDownloadFileDelegate
-(void)DownloadOver{


}

-(void)DownloadBreak{

    [SVProgressHUD showSimpleText:@"下载中断"];
}

//*******************???固件升级????*******************//

- (void)connectDfuSuccess{
    [rssiList removeAllObjects];
    
    self.isConnected = YES;
    self.dfuHelper.isDfuVersionExist = YES;
    
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/test.zip", pathDocuments];
    
    NSURL *URL = [NSURL URLWithString:filePath];
    
    [self onFileTypeNotSelected];
    
    // Save the URL in DFU helper
    self.dfuHelper.selectedFileURL = URL;
    
    //if (self.dfuHelper.selectedFileURL) {
    NSMutableArray *availableTypes = [[NSMutableArray alloc] initWithCapacity:4];
    
    // Read file name and size
    NSString *selectedFileName = [[URL path] lastPathComponent];
    NSData *fileData = [NSData dataWithContentsOfURL:URL];
    self.dfuHelper.selectedFileSize = fileData.length;
    
    // Get last three characters for file extension
    NSString *extension = [[selectedFileName substringFromIndex: [selectedFileName length] - 3] lowercaseString];
    if ([extension isEqualToString:@"zip"])
    {
        self.dfuHelper.isSelectedFileZipped = YES;
        self.dfuHelper.isManifestExist = NO;
        // Unzip the file. It will parse the Manifest file, if such exist, and assign firmware URLs
        [self.dfuHelper unzipFiles:URL];
        
        // Manifest file has been parsed, we can now determine the file type based on its content
        // If a type is clear (only one bin/hex file) - just select it. Otherwise give user a change to select
        NSString* type = nil;
        if (((self.dfuHelper.softdevice_bootloaderURL && !self.dfuHelper.softdeviceURL && !self.dfuHelper.bootloaderURL) ||
             (self.dfuHelper.softdeviceURL && self.dfuHelper.bootloaderURL && !self.dfuHelper.softdevice_bootloaderURL)) &&
            !self.dfuHelper.applicationURL)
        {
            type = FIRMWARE_TYPE_BOTH_SOFTDEVICE_BOOTLOADER;
        }
        else if (self.dfuHelper.softdeviceURL && !self.dfuHelper.bootloaderURL && !self.dfuHelper.applicationURL && !self.dfuHelper.softdevice_bootloaderURL)
        {
            type = FIRMWARE_TYPE_SOFTDEVICE;
        }
        else if (self.dfuHelper.bootloaderURL && !self.dfuHelper.softdeviceURL && !self.dfuHelper.applicationURL && !self.dfuHelper.softdevice_bootloaderURL)
        {
            type = FIRMWARE_TYPE_BOOTLOADER;
        }
        else if (self.dfuHelper.applicationURL && !self.dfuHelper.softdeviceURL && !self.dfuHelper.bootloaderURL && !self.dfuHelper.softdevice_bootloaderURL)
        {
            type = FIRMWARE_TYPE_APPLICATION;
        }
        
        // The type has been established?
        if (type)
        {
            // This will set the selectedFileType property
            [self onFileTypeSelected:type];
        }
        else
        {
            if (self.dfuHelper.softdeviceURL)
            {
                [availableTypes addObject:FIRMWARE_TYPE_SOFTDEVICE];
            }
            if (self.dfuHelper.bootloaderURL)
            {
                [availableTypes addObject:FIRMWARE_TYPE_BOOTLOADER];
            }
            if (self.dfuHelper.applicationURL)
            {
                [availableTypes addObject:FIRMWARE_TYPE_APPLICATION];
            }
            if (self.dfuHelper.softdevice_bootloaderURL)
            {
                [availableTypes addObject:FIRMWARE_TYPE_BOTH_SOFTDEVICE_BOOTLOADER];
            }
        }
    }
    else
    {
        // If a HEX/BIN file has been selected user needs to choose the type manually
        self.dfuHelper.isSelectedFileZipped = NO;
        [availableTypes addObjectsFromArray:@[FIRMWARE_TYPE_SOFTDEVICE, FIRMWARE_TYPE_BOOTLOADER, FIRMWARE_TYPE_APPLICATION, FIRMWARE_TYPE_BOTH_SOFTDEVICE_BOOTLOADER]];
    }
    
    [self performDFU];
}

-(void)performDFU
{
    
    [self.dfuHelper checkAndPerformDFU];
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    // The 'scan' or 'select' seque will be performed only if DFU process has not been started or was completed.
    //return !self.isTransferring;
    return YES;
}


- (void) clearUI
{
    selectedPeripheral = nil;
}

-(void)enableUploadButton
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (selectedFileType && self.dfuHelper.selectedFileSize > 0)
        {
            if ([self.dfuHelper isValidFileSelected])
            {
                NSLog(@"Valid file selected");
            }
            else
            {
                NSLog(@"Valid file not available in zip file");
                [Utility showAlert:[self.dfuHelper getFileValidationMessage]];
                return;
            }
        }
        
        if (self.dfuHelper.isDfuVersionExist)
        {
            if (selectedPeripheral && selectedFileType && self.dfuHelper.selectedFileSize > 0 && self.isConnected && self.dfuHelper.dfuVersion > 1)
            {
                if ([self.dfuHelper isInitPacketFileExist])
                {
                    // uploadButton.enabled = YES;
                }
                else
                {
                    [Utility showAlert:[self.dfuHelper getInitPacketFileValidationMessage]];
                }
            }
            else
            {
                if (selectedPeripheral && self.isConnected && self.dfuHelper.dfuVersion < 1)
                {
                    // uploadStatus.text = [NSString stringWithFormat:@"Unsupported DFU version: %d", self.dfuHelper.dfuVersion];
                }
                NSLog(@"Can't enable Upload button");
            }
        }
        else
        {
            if (selectedPeripheral && selectedFileType && self.dfuHelper.selectedFileSize > 0 && self.isConnected)
            {
                // uploadButton.enabled = YES;
            }
            else
            {
                NSLog(@"Can't enable Upload button");
            }
        }
        
    });
}


-(void)appDidEnterBackground:(NSNotification *)_notification
{
    if (self.isConnected && self.isTransferring)
    {
        [Utility showBackgroundNotification:[self.dfuHelper getUploadStatusMessage]];
    }
}

-(void)appDidEnterForeground:(NSNotification *)_notification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}



#pragma mark File Selection Delegate
-(void)onFileTypeSelected:(NSString *)type
{
    selectedFileType = type;
    //fileType.text = selectedFileType;
    if (type)
    {
        [self.dfuHelper setFirmwareType:selectedFileType];
        [self enableUploadButton];
    }
}

-(void)onFileTypeNotSelected
{
    self.dfuHelper.selectedFileURL = nil;
    //    fileName.text = nil;
    //    fileSize.text = nil;
    [self onFileTypeSelected:nil];
}

#pragma mark DFUOperations delegate methods
-(void)onDeviceConnected:(CBPeripheral *)peripheral
{
    self.isConnected = YES;
    self.dfuHelper.isDfuVersionExist = NO;
    [self enableUploadButton];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // uploadStatus.text = @"Device ready";
    });
    
    //Following if condition display user permission alert for background notification
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }
    [NSNOTIC_CENTER addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [NSNOTIC_CENTER addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)onDeviceConnectedWithVersion:(CBPeripheral *)peripheral
{
    self.isConnected = YES;
    self.dfuHelper.isDfuVersionExist = YES;
    [self enableUploadButton];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // uploadStatus.text = @"Reading DFU version...";
    });
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }
    [NSNOTIC_CENTER addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [NSNOTIC_CENTER addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - 固件升级中蓝牙断开回调
-(void)onDeviceDisconnected:(CBPeripheral *)peripheral
{   [BikeViewController cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectDefaultModel) object:nil];
    self.isTransferring = NO;
    self.isConnected = NO;
    [self connectDfuModel];
    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.dfuHelper.dfuVersion != 1)
        {
            self.isTransferCancelled = NO;
            self.isTransfered = NO;
            self.isErrorKnown = NO;
        }
        else
        {
            double delayInSeconds = 3.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [dfuOperations connectDevice:peripheral];
            });
        }
    });
}

-(void)onReadDFUVersion:(int)version
{
    self.dfuHelper.dfuVersion = version;
    NSLog(@"DFU Version: %d",self.dfuHelper.dfuVersion);
    if (self.dfuHelper.dfuVersion == 1)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
        [dfuOperations setAppToBootloaderMode];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
        [self enableUploadButton];
    }
}

-(void)onDFUStarted
{
    NSLog(@"DFU Started");
    self.isTransferring = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *uploadStatusMessage = [self.dfuHelper getUploadStatusMessage];
        if ([Utility isApplicationStateInactiveORBackground])
        {
            [Utility showBackgroundNotification:uploadStatusMessage];
        }
        else
        {
            
        }
    });
}

#pragma mark - 固件升级取消回调
-(void)onDFUCancelled
{
    NSLog(@"DFU Cancelled");
    self.isTransferring = NO;
    self.isTransferCancelled = YES;
    
    [SVProgressHUD showSimpleText:@"固件升级失败"];
    [[AppDelegate currentAppDelegate].device stopScan];
    [custompro stopAnimation];
    self.backView.hidden = YES;
    [AppDelegate currentAppDelegate].device.centralManager.delegate=[AppDelegate currentAppDelegate].device;
    [AppDelegate currentAppDelegate].device.peripheral.delegate=[AppDelegate currentAppDelegate].device;
    [self performSelector:@selector(connectBle) withObject:nil afterDelay:2];
}

-(void)onSoftDeviceUploadStarted
{
    NSLog(@"SoftDevice Upload Started");
}

-(void)onSoftDeviceUploadCompleted
{
    NSLog(@"SoftDevice Upload Completed");
}

-(void)onBootloaderUploadStarted
{
    NSLog(@"Bootloader Upload Started");
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([Utility isApplicationStateInactiveORBackground])
        {
            [Utility showBackgroundNotification:@"Uploading bootloader..."];
        }
        else
        {
            
        }
    });
}

#pragma mark - Bootloader Upload Completed
-(void)onBootloaderUploadCompleted
{
    NSLog(@"Bootloader Upload Completed");
}

#pragma mark - 固件升级中当前的进度值
-(void)onTransferPercentage:(int)percentage
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [custompro setPresent:(int)percentage];
        
    });
}

#pragma mark - 成功进入固件升级的回调
-(void)onSuccessfulFileTranferred
{
    NSLog(@"File Transferred");
    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isTransferring = NO;
        self.isTransfered = YES;
        NSString* message = [NSString stringWithFormat:@"%lu bytes transfered in %lu seconds", (unsigned long)dfuOperations.binFileSize, (unsigned long)dfuOperations.uploadTimeInSeconds];
        
        if ([Utility isApplicationStateInactiveORBackground])
        {
            [Utility showBackgroundNotification:message];
        }
        else
        {
            //[Utility showAlert:message];
            
            [AppDelegate currentAppDelegate].device.centralManager.delegate=[AppDelegate currentAppDelegate].device;
            [AppDelegate currentAppDelegate].device.peripheral.delegate=[AppDelegate currentAppDelegate].device;
            [self performSelector:@selector(connectBle) withObject:nil afterDelay:2];
            
            NSString *updateSql = [NSString stringWithFormat:@"UPDATE bike_modals SET firmversion = '%@' WHERE bikeid = '%zd'", self.latest_version,self.bikeid];
            [LVFmdbTool modifyData:updateSql];
            [self updateDeviceInfo];
        }
    });
    
}

#pragma mark - 升级完成后更新车辆版本号
- (void)updateDeviceInfo{
    
    NSMutableArray *deviceAry = [[NSMutableArray alloc] init];
    NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM info_modals WHERE bikeid LIKE '%zd'", self.bikeid];
    NSMutableArray *modals = [LVFmdbTool queryModelData:fuzzyQuerySql];
    ModelInfo *modelinfo = modals.firstObject;
    
    NSNumber *batttype = [NSNumber numberWithInt:(int)modelinfo.batttype];
    NSNumber *battvol = [NSNumber numberWithInt:(int)modelinfo.battvol];
    NSNumber *brandid = [NSNumber numberWithInt:(int)modelinfo.brandid];
    NSNumber *modelid = [NSNumber numberWithInt:(int)modelinfo.modelid];
    NSString *modelname = modelinfo.modelname;
    NSString *pictures = modelinfo.pictures;
    NSString *pictureb = modelinfo.pictureb;
    NSNumber *wheelsize = [NSNumber numberWithInt:(int)modelinfo.wheelsize];
    NSDictionary *model_info = [NSDictionary dictionaryWithObjectsAndKeys:batttype,@"batt_type",battvol,@"batt_vol",brandid,@"brand_id",modelid,@"model_id",modelname,@"model_name",pictures,@"picture_s",pictureb,@"picture_b",wheelsize,@"wheel_size",nil];
    
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.bikeid];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    NSNumber *bikeid = [NSNumber numberWithInteger:bikemodel.bikeid];
    NSString *bikename = bikemodel.bikename;
    NSNumber *bindedcount = [NSNumber numberWithInteger:bikemodel.bindedcount];
    NSNumber *ownerflag = [NSNumber numberWithInteger:bikemodel.ownerflag];
    NSString *hwversion = bikemodel.hwversion;
    NSString *firversion = self.latest_version;
    NSString *mac = bikemodel.mac;
    
    NSString *brandQuerySql = [NSString stringWithFormat:@"SELECT * FROM brand_modals WHERE bikeid LIKE '%zd'", self.bikeid];
    NSMutableArray *brandmodals = [LVFmdbTool queryBrandData:brandQuerySql];
    BrandModel *brandmodel = brandmodals.firstObject;
    NSNumber *brandid2 = [NSNumber numberWithInt:(int)brandmodel.brandid];
    NSString *brandname = brandmodel.brandname;
    NSString *logo = brandmodel.logo;
    NSDictionary *brand_info = [NSDictionary dictionaryWithObjectsAndKeys:brandid2,@"brand_id",brandname,@"brand_name",logo,@"logo",nil];
    
    NSString *peripheraQuerySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE bikeid LIKE '%zd'", self.bikeid];
    NSMutableArray *peripheramodals = [LVFmdbTool queryPeripheraData:peripheraQuerySql];
    for (PeripheralModel *peripheramodel in peripheramodals) {
        
        NSNumber *deviceId = [NSNumber numberWithInt:(int)peripheramodel.deviceid];
        NSString *firversion;
        NSString *mac ;
        NSNumber *seq = [NSNumber numberWithInt:(int)peripheramodel.seq];
        NSString *sn = peripheramodel.sn;
        NSNumber *type = [NSNumber numberWithInt:(int)peripheramodel.type];
        
        if (firversion == nil) {
            firversion = @"";
        }else{
            
            firversion = peripheramodel.firmversion;
        }
        
        if (mac == nil) {
            mac = @"";
        }else{
            
            mac = peripheramodel.mac;
        }
        
        NSDictionary *device_info=[NSDictionary dictionaryWithObjectsAndKeys:deviceId,@"device_id",seq,@"seq",sn,@"sn",type,@"type",mac,@"mac",firversion,@"firm_version",nil];
        [deviceAry addObject:device_info];
    }
    
        NSDictionary *passwd_info;
        
        if (ownerflag.intValue == 1) {
            
            NSString *main = bikemodel.mainpass;
            NSString *children = @"";
            
            NSMutableArray *childrenAry = [NSMutableArray array];
            [childrenAry addObject:children];
            passwd_info = [NSDictionary dictionaryWithObjectsAndKeys:childrenAry,@"children",main,@"main",nil];
        }else if (ownerflag.intValue == 0){
            
            NSString *children = bikemodel.password;
            NSString *main = @"";
            NSMutableArray *childrenAry = [NSMutableArray array];
            [childrenAry addObject:children];
            passwd_info = [NSDictionary dictionaryWithObjectsAndKeys:childrenAry,@"children",main,@"main",nil];
        }
        
        NSDictionary *bike_info = [NSDictionary dictionaryWithObjectsAndKeys:bikeid,@"bike_id",bikename,@"bike_name",bindedcount,@"binded_count",firversion,@"firm_version",mac,@"mac",ownerflag,@"owner_flag",hwversion,@"hwversion",brand_info,@"brand_info",model_info,@"model_info",passwd_info,@"passwd_info",deviceAry,@"device_info",nil];
        
        NSString *token = [QFTools getdata:@"token"];
        
        NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/updatebikeinfo"];
        NSDictionary *parameters = @{@"token": token, @"bike_info": bike_info};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            [SVProgressHUD showSimpleText:@"升级完成"];
            NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:firversion,@"data", nil];
            [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_FirmwareUpgradeCompleted object:nil userInfo:dict]];
        }else {
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        
    }];
}
#pragma mark - 升级完成后连接车辆
-(void)connectBle{
    self.backView.hidden = YES;
    [AppDelegate currentAppDelegate].device.upgrate = NO;
    NSString*deviceuuid=[USER_DEFAULTS stringForKey:Key_DeviceUUID];
    [[AppDelegate currentAppDelegate].device retrievePeripheralWithUUID:deviceuuid];//导入外设 根据UUID
    [[AppDelegate currentAppDelegate].device connect];
    int present = 0;
    [custompro setPresent:present];
    
}
#pragma mark - 固件升级出现错误的回调
-(void)onError:(NSString *)errorMessage
{
    NSLog(@"Error: %@", errorMessage);
    self.isErrorKnown = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        //[Utility showAlert:errorMessage];
        [self clearUI];
        
        [SVProgressHUD showSimpleText:@"固件升级失败"];
        [[AppDelegate currentAppDelegate].device stopScan];
        [custompro stopAnimation];
        self.backView.hidden = YES;
        [AppDelegate currentAppDelegate].device.centralManager.delegate=[AppDelegate currentAppDelegate].device;
        [AppDelegate currentAppDelegate].device.peripheral.delegate=[AppDelegate currentAppDelegate].device;
        [self performSelector:@selector(connectBle) withObject:nil afterDelay:2];
        
    });
}



@end
