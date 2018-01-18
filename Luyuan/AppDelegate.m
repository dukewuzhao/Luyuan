//
//  AppDelegate.m
//  RideHousekeeper
//
//  Created by 同时科技 on 16/6/20.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "AppDelegate.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "BNCoreServices.h"
#import "LoginViewController.h"
#import "QGJThirdPartService.h"
#import "SideMenuViewController.h"
#import "UIAlertView+MyAlertView.h"
#import "AddBikeViewController.h"
#import "AppDelegate+Login.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#define NAVI_TEST_APP_KEY   @"wVGOPkrxzDz0GtSAtZaFuDZZLGUyFczG"  //sdk自测APP KEY
#define NAVI_TEST_TTS_KEY   @"10625037"  //sdk自测APP KEY
#define STOREAPPID @"1336396454"

@interface AppDelegate ()<DeviceDelegate,UIAlertViewDelegate,JPUSHRegisterDelegate>
{
    NSString *child;
    NSString *main;
}
    //@property (nonatomic, strong) ABCIntroView *introView;
    @property (nonatomic, strong) NSMutableArray *macArrM;
    @property (nonatomic, strong) NSMutableArray *passwordArrM;
    @property (nonatomic, strong)UIAlertView *BluetoothAlertView;
    
@end


@implementation AppDelegate
    
- (NSMutableArray *)macArrM {
    if (!_macArrM) {
        _macArrM = [[NSMutableArray alloc] init];
    }
    return _macArrM;
}
    
- (NSMutableArray *)passwordArrM {
    if (!_passwordArrM) {
        _passwordArrM = [[NSMutableArray alloc] init];
    }
    return _passwordArrM;
}
    
#pragma mark - UIAlertViewDelegate
    
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
    {
        if (alertView.tag == 5555) {
            if (buttonIndex != [alertView cancelButtonIndex]) {
                
                if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
                    
                    NSDictionary *options = @{UIApplicationOpenURLOptionUniversalLinksOnly : @YES};
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Bluetooth"] options:options completionHandler:nil];
                } else {
                    
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Bluetooth"]];
                }
            }
        }else if (alertView.tag == 3000) {
            if (buttonIndex != [alertView cancelButtonIndex]) {
                
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/us/app/id%@?ls=1&mt=8", STOREAPPID]];
                [[UIApplication sharedApplication] openURL:url];
        }
    }
}
    
-(void)mbluetoohPowerOff:(NSNotification *)notification{
    
    int devicetag=[notification.object intValue];
    
    if(devicetag == _device.tag){
        
        self.BluetoothAlertView = [[UIAlertView alloc]initWithTitle:@"提示" message:NSLocalizedString( @"当前蓝牙未打开,是否打开", @"") delegate:self cancelButtonTitle:NSLocalizedString( @"取消", @"") otherButtonTitles:@"打开", nil];
        self.BluetoothAlertView.tag = 5555;
        [self.BluetoothAlertView show];
    }
    
    if(_device.deviceStatus>=2&&_device.deviceStatus<5){
        
        _device.deviceStatus=0;
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_UpdateDeviceStatus object:nil]];
    }
}
    
-(void)mbluetoohPowerOn:(NSNotification *)notification{
    int devicetag=[notification.object intValue];
    
    if(devicetag ==_device.tag){
        
        [self.BluetoothAlertView dismissWithClickedButtonIndex:0 animated:YES];
        NSString*deviceuuid=[USER_DEFAULTS stringForKey:Key_DeviceUUID];
        if ([[QFTools currentViewController] isKindOfClass:[AddBikeViewController class]]) {
            return;
        }
        if (deviceuuid) {
            [_device retrievePeripheralWithUUID:deviceuuid];//导入外设 根据UUID
            [_device connect];
        }
    }
    // [currentDevice performSelector:@selector(connect) withObject:nil afterDelay:2];
}
    
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    //NSArray *centralManagerIdentifiers = launchOptions[UIApplicationLaunchOptionsBluetoothCentralsKey];
    //self.window.backgroundColor = [QFTools colorWithHexString:@"#06c1ae"];
    if (@available(iOS 11.0, *)){
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(mbluetoohPowerOff:) name:KNotification_BluetoothPowerOff object:nil];
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(mbluetoohPowerOn:) name:KNotification_BluetoothPowerOn object:nil];
    
    //[NSNOTIC_CENTER addObserver:self selector:@selector(Dataupdate:) name:KNotification_Dataupdate object:nil];
    
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:NAVI_TEST_APP_KEY generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    [self networkMonitor];//网络监听
    
    _device =[[WYDevice alloc]init ];
    
    _device.deviceDelegate=self;
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(loginStateChange:) name:KNOTIFICATION_LOGINCHANGE object:nil];
    
    // 3.0.0及以后版本注册可以这样写，也可以继续用旧的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
            if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
              NSSet<UNNotificationCategory *> *categories;
              entity.categories = categories;
            }
            else {
              NSSet<UIUserNotificationCategory *> *categories;
              entity.categories = categories;
            }
    }
    
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    [JPUSHService setupWithOption:launchOptions appKey:appKey channel:channel apsForProduction:isProduction advertisingIdentifier:nil];
    [JPUSHService setLogOFF];
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
            NSLog(@"registrationID获取成功：%@",registrationID);
            
        }
        else{
            NSLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];
    
    [self updateApp];
    [self loginStateChange:nil];
    [self.window makeKeyAndVisible];
    
    [BNCoreServices_Instance initServices: NAVI_TEST_APP_KEY];
    [BNCoreServices_Instance setTTSAppId:NAVI_TEST_TTS_KEY];
    [BNCoreServices_Instance setAutoExitNavi:NO];
    [BNCoreServices_Instance startServicesAsyn:nil fail:nil];
    
    if (![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            NSLog(@"执行了计时器");
            [self logindata];
        });
    }
    
    return YES;
}


-(void)networkMonitor{
    
    //创建网络监听管理者对象
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    /*
     typedef NS_ENUM(NSInteger, AFNetworkReachabilityStatus) {
     AFNetworkReachabilityStatusUnknown          = -1,//未识别的网络
     AFNetworkReachabilityStatusNotReachable     = 0,//不可达的网络(未连接)
     AFNetworkReachabilityStatusReachableViaWWAN = 1,//2G,3G,4G...
     AFNetworkReachabilityStatusReachableViaWiFi = 2,//wifi网络
     };
     */
    //设置监听
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
            NSLog(@"未识别的网络");
            self.available = NO;
            [SVProgressHUD showSimpleText:@"未识别的网络"];
            break;
            
            case AFNetworkReachabilityStatusNotReachable:
            NSLog(@"不可达的网络(未连接)");
            self.available = NO;
            [SVProgressHUD showSimpleText:@"网络异常，请检查网络状况"];
            
            break;
            
            case AFNetworkReachabilityStatusReachableViaWWAN:
            NSLog(@"2G,3G,4G...的网络");
            self.available = YES;
            break;
            
            case AFNetworkReachabilityStatusReachableViaWiFi:
            NSLog(@"wifi的网络");
            self.available = YES;
            break;
            default:
            break;
        }
    }];
    //开始监听
    [manager startMonitoring];
}
    
- (void)getbikelist:(NSDictionary *)jpushDict{
    
    NSString *token = [QFTools getdata:@"token"];
    NSString *userid = [QFTools getdata:@"userid"];
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/getbikelist"];
    NSDictionary *parameters = @{@"token": token, @"user_id":userid};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            [LVFmdbTool deleteBrandData:nil];
            [LVFmdbTool deleteBikeData:nil];
            [LVFmdbTool deleteModelData:nil];
            [LVFmdbTool deletePeripheraData:nil];
            [LVFmdbTool deleteFingerprintData:nil];
            [self.macArrM removeAllObjects];
            [self.passwordArrM removeAllObjects];
            NSDictionary *data = dict[@"data"];
            NSMutableArray *bike_info = data[@"bike_info"];
            
            for (NSDictionary *bike in bike_info) {
                
                BikeInfoModel *bikeInfo = [BikeInfoModel yy_modelWithDictionary:bike];
                [self.macArrM addObject:bikeInfo.mac];
                
                if (bikeInfo.owner_flag == 1) {
                    child = @"0";
                    main = bikeInfo.passwd_info.main;
                    
                    NSString* masterpwd = [QFTools toHexString:(long)[main longLongValue]];
                    int masterpwdCount = 8 - (int)masterpwd.length;
                    
                    for (int i = 0; i<masterpwdCount; i++) {
                        masterpwd = [@"0" stringByAppendingFormat:@"%@",masterpwd];
                    }
                    [self.passwordArrM addObject:masterpwd];
                }else if (bikeInfo.owner_flag == 0){
                    
                    child = bikeInfo.passwd_info.children.firstObject;
                    main = @"0";
                    
                    NSString* childpwd = [QFTools toHexString:(long)[child longLongValue]];
                    int childpwdCount = 8 - (int)childpwd.length;
                    
                    for (int i = 0; i<childpwdCount; i++) {
                        childpwd = [@"0" stringByAppendingFormat:@"%@",childpwd];
                    }
                    [self.passwordArrM addObject:childpwd];
                }
                
                NSString *logo = bikeInfo.brand_info.logo;
                NSString *picture_b = bikeInfo.model_info.picture_b;
                
                BikeModel *pmodel = [BikeModel modalWith:bikeInfo.bike_id bikename:bikeInfo.bike_name ownerflag:bikeInfo.owner_flag hwversion:bikeInfo.hw_version firmversion:bikeInfo.firm_version keyversion:bikeInfo.key_version mac:bikeInfo.mac mainpass:main password:child bindedcount:bikeInfo.binded_count ownerphone:bikeInfo.owner_phone];
                [LVFmdbTool insertBikeModel:pmodel];
                
                if (bikeInfo.brand_info.brand_id == 0) {
                    logo = [QFTools getdata:@"defaultlogo"];
                }
                
                BrandModel *bmodel = [BrandModel modalWith:bikeInfo.bike_id brandid:bikeInfo.brand_info.brand_id brandname:bikeInfo.brand_info.brand_name logo:logo];
                [LVFmdbTool insertBrandModel:bmodel];
                
                if (bikeInfo.model_info.model_id == 0) {
                    picture_b = [QFTools getdata:@"defaultimage"];
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
            
            NSString*macstring = [USER_DEFAULTS stringForKey:Key_MacSTRING];
            NSDictionary *passwordDic = [USER_DEFAULTS objectForKey:passwordDIC];
            NSMutableArray *bikeAry = [LVFmdbTool queryBikeData:nil];
            if (![self.macArrM containsObject:macstring]) {
                [USER_DEFAULTS removeObjectForKey:SETRSSI];
                [USER_DEFAULTS removeObjectForKey:Key_DeviceUUID];
                [USER_DEFAULTS removeObjectForKey:Key_MacSTRING];
                [USER_DEFAULTS removeObjectForKey:passwordDIC];
                [USER_DEFAULTS synchronize];
                
                if (bikeAry.count > 0) {
                    BikeModel *firstbikeinfo = bikeAry[0];
                    [USER_DEFAULTS setValue:firstbikeinfo.mac.uppercaseString forKey:SETRSSI];
                }
                
                [self.device remove];
                
            }else{
                
                //在检测密码是否一致
                if (![self.passwordArrM containsObject:passwordDic[@"main"]]) {
                    [USER_DEFAULTS removeObjectForKey:Key_DeviceUUID];
                    [USER_DEFAULTS removeObjectForKey:passwordDIC];
                    [USER_DEFAULTS synchronize];
                }
                
                [USER_DEFAULTS setValue:macstring forKey:SETRSSI];
                
            }
            
            if ([LVFmdbTool queryBikeData:nil].count == 0) {
                
                if ([_mainController isKindOfClass:[BikeViewController class]]) {
                    
                    if (!_device.binding) {
                        [self loginStateChange:nil];
                    }
                }
            }else{
                
                if ([_mainController isKindOfClass:[ViewController class]]) {
                    
                    if (!_device.binding) {
                        [self loginStateChange:nil];
                    }
                }
            }
            
            if ([LVFmdbTool queryBikeData:nil].count > 0) {
                
                [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_RemoteJPush object:nil userInfo:jpushDict]];
            }
            
        }else if([dict[@"status"] intValue] == 1001){
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
            
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        
    }];
}

#pragma mark - 蓝牙连接回调
    
- (void)didConnect:(NSInteger)tag :(CBPeripheral *)peripheral
    {
        _device.deviceStatus=2;
        
        if (_device.binding) {
            [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_ConnectStatus object:nil]];
        }else{
            
            [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_UpdateDeviceStatus object:nil]];
        }
        
    }
    
- (void)didDisconnect:(NSInteger)tag :(CBPeripheral *)peripheral
    {
        _device.deviceStatus=0;
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_UpdateDeviceStatus object:nil]];
    }
    
    
    
#pragma mark---接收到了数据 蓝牙indication
- (void)didGetSensorData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral{
    
    NSString *result = [ConverUtil data2HexString:data];
    //NSLog(@"返回数据 :%@",result);
    NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:result,@"data", nil];
    
    if ([[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1005"]) {
        
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_QueryKeyType object:nil userInfo:dict]];
        
    }else if ([[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"5001"]){
        
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_BindingQGJSuccess object:nil userInfo:dict]];
        
    }else if ([[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3002"]){
        
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_BindingBLEKEY object:nil userInfo:dict]];
        
    }else if ([[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3004"]){
        
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_FingerPrint object:nil userInfo:dict]];
        
    }else if ([[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3005"]){
        
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_DeleteFinger object:nil userInfo:dict]];
        
    }else if ([[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3006"]){
        
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_TestFingerPress object:nil userInfo:dict]];
        
    }else if ([[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"2003"] || [[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3003"]){
        
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_QueryBleKeyData object:nil userInfo:dict]];
        
    }else if ([[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1003"]){
        
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_Bindingkey object:nil userInfo:dict]];
        
    }else if ([[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1001"] || [[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1002"] || [[result substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1004"]){
        
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_QueryData object:nil userInfo:dict]];
        
    }
    
}
    
    
#pragma mark---接收到了数据 读蓝牙中的报警器的mac地址
- (void)didGetBurglarCharData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral
    {
        
        
    }
    
    
    //蓝牙自带的读取固件版本信息
- (void)didGetEditionCharData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral
    {
        
        NSString *result = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
        NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:result,@"edition", nil];
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_UpdateeditionValue object:nil userInfo:dict]];
        
    }
    
    //蓝牙自带的读取硬件版本信息
- (void)didGetVersionCharData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral
    {
        
        NSString *version = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
        NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:version,@"version", nil];
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_VersionValue object:nil userInfo:dict]];
    }
    

#pragma mark - private
    //登陆状态改变
- (void)loginStateChange:(NSNotification *)notification
    {
        UIViewController *nav = nil;
        BOOL loginSuccess = [notification.object boolValue];
        if (![QFTools isBlankString:[QFTools getdata:@"phone_num"]] || loginSuccess) {//登陆成功加载主窗口控制器
            NSMutableArray *bikearray = [LVFmdbTool queryBikeData:nil];
            if (bikearray.count >0) {
                if ([_mainController isKindOfClass:[BikeViewController class]]) {
                    
                    nav = [[UINavigationController alloc] initWithRootViewController:_mainController];
                }else{
                    _mainController = nil;
                    _mainController = [[BikeViewController alloc] init];
                    nav = [[UINavigationController alloc] initWithRootViewController:_mainController];
                }
            }else{
                if ([_mainController isKindOfClass:[ViewController class]]) {
                    nav  = _mainController.navigationController;
                }else{
                    _mainController = nil;
                    _mainController = [[ViewController alloc] init];
                    nav = [[UINavigationController alloc] initWithRootViewController:_mainController];
                }
            }
            
        }else{//登陆失败加载登陆页面控制器
            _mainController = nil;
            LoginViewController *loginController = [[LoginViewController alloc] init];
            nav = [[UINavigationController alloc] initWithRootViewController:loginController];
        }
        
        CATransition *anima = [CATransition animation];
        anima.type = @"fade";//设置动画的类型
        anima.subtype = kCATransitionFromRight; //设置动画的方向
        anima.duration = 0.3f;
        
        self.window.rootViewController = nav;
        [[UIApplication sharedApplication].delegate.window.layer addAnimation:anima forKey:@"revealAnimation"];
    }
    
    
+ (AppDelegate *)currentAppDelegate
    {
        return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
    {
        return YES;
    }
    
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
    {
        
        return YES;
    }
    
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
    [JPUSHService registerDeviceToken:deviceToken];
}
    
    
- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings {
    
}
    
    // Called when your app has been activated by the user selecting an action from
    // a local notification.
    // A nil action identifier indicates the default action.
    // You should call the completion handler as soon as you've finished handling
    // the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forLocalNotification:(UILocalNotification *)notification
  completionHandler:(void (^)())completionHandler {
    
}
    
    // Called when your app has been activated by the user selecting an action from
    // a remote notification.
    // A nil action identifier indicates the default action.
    // You should call the completion handler as soon as you've finished handling
    // the action.
- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)userInfo
  completionHandler:(void (^)())completionHandler {
    
}
#endif
    
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [JPUSHService handleRemoteNotification:userInfo];
    NSLog(@"iOS6及以下系统收到通知:%@", [self logDic:userInfo]);
}
    
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:
(void (^)(UIBackgroundFetchResult))completionHandler {
    [JPUSHService handleRemoteNotification:userInfo];
    NSLog(@"iOS7及以上系统收到通知:%@", [self logDic:userInfo]);
    [self JPushOperation:userInfo];
    
    completionHandler(UIBackgroundFetchResultNewData);
}
    
- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification {
    
    [JPUSHService showLocalNotificationAtFront:notification identifierKey:nil];
    
}
    
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#pragma mark- JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [JPUSHService setBadge:0];
    
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"iOS10 前台收到远程通知:%@", [self logDic:userInfo]);
        [self JPushOperation:userInfo];
        
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}
    
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [JPUSHService setBadge:0];
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        NSLog(@"iOS10 收到远程通知:%@", [self logDic:userInfo]);
        [self JPushOperation:userInfo];
    }else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    completionHandler();  // 系统要求执行这个方法
}
#endif
    
    // log NSSet with UTF8
    // if not ,log will be \Uxxx
- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}
    
-(void)JPushOperation:(NSDictionary *)userInfo{
    NSLog(@"iOS7及以上系统收到通知");
    NSNumber *bikeid = userInfo[@"bike_id"];
    NSNumber *type = userInfo[@"type"];
    if ([QFTools isBlankString:[QFTools getdata:@"phone_num"]]) {
        
        return;
    }else if (type.intValue < 1 || type.intValue > 4){
        
        return;//不是车辆信息更新信息，不需要刷新本地数据
    }
    
    NSDictionary *jpushDict =[[NSDictionary alloc] initWithObjectsAndKeys:bikeid,@"bikeid",type,@"type", nil];
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self getbikelist:jpushDict];
        
        dispatch_group_leave(group);
    });
    dispatch_group_enter(group);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"second API got data");
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        //更新主界面
        
    });
}
    
- (UIInterfaceOrientationMask) application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    //id presentedViewController = [window.rootViewController presentedViewController];
    
    //NSString *className = presentedViewController ? NSStringFromClass([presentedViewController class]) : nil;
    
    // NSString *className1 = [self.window.subviews.lastObject class].description;
    
    return UIInterfaceOrientationMaskPortrait;
    
}
    
    
    //app当有电话进来或者锁屏，这时你的应用程会挂起调用
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    //[self stropTimer];
}
    
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
}
    
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}
    //app进入前台
- (void)applicationDidBecomeActive:(UIApplication *)application {
    

}
    
    //crash 会调用的接口
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    
}
    
  
    
- (void)onGetNetworkState:(int)iError
    {
        if (0 == iError) {
            NSLog(@"联网成功");
        }else{
            NSLog(@"onGetNetworkState %d",iError);
        }
        
    }
    
- (void)onGetPermissionState:(int)iError
    {
        if (0 == iError) {
            NSLog(@"授权成功");
        }else {
            NSLog(@"onGetPermissionState %d",iError);
        }
    }
    
    
    @end
