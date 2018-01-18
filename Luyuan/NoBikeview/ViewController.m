//
//  ViewController.m
//  RideHousekeeper
//
//  Created by 同时科技 on 16/6/20.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "ViewController.h"
#import "BindBikeTableViewCell.h"
#import "AView.h"
#import "UIView+i7Rotate360.h"
#import "PersonalCenterViewController.h"
#import "SearchBleModel.h"

@interface ViewController ()<ScanDelegate,UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    NSMutableArray *rssiList;
    NSMutableDictionary *uuidarray;
    NSArray *ascendArray;
    NSString *macstring;
    
}

@property (strong, nonatomic) CAShapeLayer *shapeLayer;
@property(nonatomic,weak) UITableView *choseView;
@property(nonatomic,weak) UIButton *upBtn;
@property(nonatomic,weak) UILabel *search;
@property(nonatomic,weak)UIImageView *giftImage;

@property(nonatomic) LoadView *loadview;
@property (nonatomic)AView *aView;
@property(nonatomic,strong) NSString *firmedition;//固件版本号
@property(nonatomic,strong) NSString *keyVersion;//钥匙版本号
@property(nonatomic,strong) NSString *deviceVersion;//硬件钥匙版本号
@property(nonatomic,strong) NSString *brandName;//品牌名称
@property(nonatomic,strong) NSNumber *brandid;//车辆品牌id

@property(nonatomic,strong) NSNumber *bikeid;//车辆id
@property(nonatomic,strong) NSString *bikeName;//车辆名称
@property(nonatomic,strong)NSString *masterpwd;//主密码
@property(nonatomic,strong)NSString *logo;//品牌logo
//@property(nonatomic,strong) NSString *deviceuuid;//默认的蓝牙设备uuid

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ffffff"];
    [[AppDelegate currentAppDelegate].device remove];
    rssiList=[[NSMutableArray alloc]init];
    uuidarray=[[NSMutableDictionary alloc]init];
    
    @weakify(self);
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"addbike_user"] action:^{
        
        @strongify(self);
        PersonalCenterViewController *personVc = [PersonalCenterViewController new];
        [self.navigationController pushViewController:personVc animated:YES];
    }];
    
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_reloadTableViewData object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        NSNotification *userInfo = x;
        SearchBleModel *bleModel = userInfo.userInfo[@"searchmodel"];
        
        if ([self->rssiList containsObject: bleModel]) {
            
            [self->rssiList removeObject:bleModel];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.choseView reloadData];
        });
    }];
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(mbluetoohPowerOff:) name:KNotification_BluetoothPowerOff object:nil];
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(mbluetoohPowerOn:) name:KNotification_BluetoothPowerOn object:nil];
    
    [self setuptableview];
    
    if (![USER_DEFAULTS boolForKey:@"firstBinding"]) {
        [USER_DEFAULTS setBool:YES forKey:@"firstBinding"];
    
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        backView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
        [[UIApplication sharedApplication].keyWindow addSubview:backView];
        
        UIImageView *guideview = [[UIImageView alloc] initWithFrame:CGRectMake(20, ScreenHeight*.15, ScreenWidth - 40, (ScreenWidth - 40)/.92)];
        guideview.image = [UIImage imageNamed:@"icon_first_search_content"];
        [backView addSubview:guideview];
        
        UIButton *clickBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 50, CGRectGetMaxY(guideview.frame)+ 40, 100, 27)];
        [clickBtn setImage:[UIImage imageNamed:@"icon_anla"] forState:UIControlStateNormal];
        [[clickBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            [backView removeFromSuperview];
        }];
        [backView addSubview:clickBtn];
    }
    
    [self startblescan];
}

-(void)mbluetoohPowerOff:(NSNotification *)notification{
    
    int devicetag=[notification.object intValue];
    if(devicetag == [AppDelegate currentAppDelegate].device.tag){
        if (![AppDelegate currentAppDelegate].device.binding) {
            [[AppDelegate currentAppDelegate].device stopScan];
            [rssiList removeAllObjects];
            [uuidarray removeAllObjects];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.choseView reloadData];
            });
            [self.aView stopRotate360Animation];
        }
    }
}

-(void)mbluetoohPowerOn:(NSNotification *)notification{
    int devicetag=[notification.object intValue];
    if(devicetag == [AppDelegate currentAppDelegate].device.tag){
        
        if (![AppDelegate currentAppDelegate].device.binding) {
            [[AppDelegate currentAppDelegate].device startBackstageScan];
            [self.aView rotate360WithDuration:2.0 repeatCount:HUGE_VALF timingMode:i7Rotate360TimingModeLinear];
        }
    }
}

- (void)setuptableview{
    
    UIImageView *qgjlogo = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 65, 0, 130, 34)];
    qgjlogo.image = [UIImage imageNamed:@"addbikelogo"];
    [self.view addSubview:qgjlogo];
    
    UILabel *search = [[UILabel alloc] initWithFrame:CGRectMake(20,CGRectGetMaxY(qgjlogo.frame)+5, ScreenWidth - 40, 30)];
    search.textAlignment = NSTextAlignmentCenter;
    search.text = @"正在搜索车辆";
    search.textColor = [QFTools colorWithHexString:@"999999"];
    search.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:search];
    self.search = search;
    
    UIImageView *giftImage = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - ScreenWidth *.3, CGRectGetMaxY(search.frame) + 20, ScreenWidth * .6 , ScreenWidth*.6)];
    giftImage.image = [UIImage imageNamed:@"find_bg"];
    [self.view addSubview:giftImage];
    self.giftImage = giftImage;
    
    AView *aView = [[AView alloc] initWithImage:[UIImage imageNamed:@"turnaround"]];
    aView.frame = CGRectMake(giftImage.x - 2.5, giftImage.y - 2.5,giftImage.width+5,giftImage.height+5);
    aView.userInteractionEnabled = NO;
    [aView rotate360WithDuration:2.0 repeatCount:HUGE_VALF timingMode:i7Rotate360TimingModeLinear];
    [self.view addSubview:aView];
    self.aView = aView;
    
    UITableView *choseView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(giftImage.frame) + ScreenHeight *.05, ScreenWidth, ScreenHeight * .3)];
    choseView.delegate = self;
    choseView.dataSource = self;
    [choseView registerClass:[BindBikeTableViewCell class] forCellReuseIdentifier:@"VCBindingCell"];
    choseView.backgroundColor = [UIColor clearColor];
    choseView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [choseView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:choseView];
    self.choseView = choseView;
    
    
    UIView *footview = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight-70 - navHeight, ScreenWidth, 70)];
    footview.backgroundColor = [QFTools colorWithHexString:MainColor];
    [self.view addSubview:footview];
    
    UILabel *prompt = [[UILabel alloc] initWithFrame:CGRectMake(15, 5, ScreenWidth - 30, 60)];
    prompt.text = @"1.请长按普通钥匙解锁键，直到车辆发出“嘟嘟嘟”声\n2.点击搜索到的车辆，即可自动完成绑定";
    prompt.numberOfLines = 0;
    prompt.textColor = [QFTools colorWithHexString:@"#ffffff"];
    prompt.font = [UIFont systemFontOfSize:13];
    prompt.textAlignment = NSTextAlignmentLeft;
    prompt.attributedText = [self getAttributedStringWithString:@"1.请长按普通钥匙解锁键，直到车辆发出“嘟嘟嘟”声\n2.点击搜索到的车辆，即可自动完成绑定" lineSpace:5];
    [footview addSubview:prompt];
}

-(NSAttributedString *)getAttributedStringWithString:(NSString *)string lineSpace:(CGFloat)lineSpace {
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace; // 调整行间距
    NSRange range = NSMakeRange(0, [string length]);
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    return attributedString;
}

- (void)startblescan{
    [AppDelegate currentAppDelegate].device.scanDelete = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        
        [[AppDelegate currentAppDelegate].device startBackstageScan];
    });
}


#pragma mark -- TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    
    return rssiList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 45.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 1.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headerView = [UIView new];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *footerView = [UIView new];
    return footerView;
}

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    
    view.tintColor = [QFTools colorWithHexString:@"#cccccc"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"VCBindingCell";
    BindBikeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    ascendArray = [rssiList sortedArrayUsingComparator:^NSComparisonResult(SearchBleModel* obj1, SearchBleModel* obj2)
                   {
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
    
    
    UIImageView *image = cell.Icon;
    
    SearchBleModel *model = [ascendArray objectAtIndex:indexPath.section];
    
    if (model.rssi.intValue <= -95) {
        
        image.image = [UIImage imageNamed:@"icon_signal1"];
    }else if (model.rssi.intValue > -90 && model.rssi.intValue <= -85){
        
        image.image = [UIImage imageNamed:@"icon_signal2"];
    }else if (model.rssi.intValue > -85 && model.rssi.intValue <= -80){
        
        image.image = [UIImage imageNamed:@"icon_signal3"];
    }else{
        
        image.image = [UIImage imageNamed:@"icon_signal4"];
    }
    
    cell.IntelligenceBike.text = @"智能车辆";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
        if (![AppDelegate currentAppDelegate].available) {
            [SVProgressHUD showSimpleText:@"网络未连接"];
            return;
        }
        
        if (![AppDelegate currentAppDelegate].device.blueToothOpen) {
            [SVProgressHUD showSimpleText:@"蓝牙未开启"];
            return;
        }
        
        NSString *title = [[ascendArray objectAtIndex:indexPath.section] titlename];
        NSString *name = [title substringWithRange:NSMakeRange(1, 8)];
        if ([name isEqualToString: @"0000a501"]) {
            
            if ([[ascendArray objectAtIndex:indexPath.section] searchCount] == 0) {
                [SVProgressHUD showSimpleText:@"设备已断电"];
                return;
            }
            
            for (int i=0; i < [rssiList count];i++ ) {
                [[rssiList objectAtIndex:indexPath.section] stopSearchBle];
            }
            [AppDelegate currentAppDelegate].device.binding = YES;//进入绑定模式
            [NSNOTIC_CENTER addObserver:self selector:@selector(vcUpdateNewDeviceStatusAction:) name:KNotification_ConnectStatus object:nil];
            [self.aView stopRotate360Animation];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [[AppDelegate currentAppDelegate].device stopScan];
            [self performSelector:@selector(vcOvertime) withObject:nil afterDelay:10];
            self.loadview = [[LoadView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
            
            CGFloat height = ScreenHeight;
            if(height <= 568){
                self.loadview.leftx = ScreenWidth *0.25;
                self.loadview.undery = ScreenHeight *0.06;
            }else{
                self.loadview.leftx = ScreenWidth *0.3;
                self.loadview.undery = ScreenHeight *0.09;
            }
            
            self.loadview.protetitle.text = @"绑定车辆中";
            [self.view addSubview:self.loadview];
            
            [AppDelegate currentAppDelegate]. device.peripheral=[[ascendArray objectAtIndex:indexPath.section] peripher];
            [[AppDelegate currentAppDelegate].device connect];
            macstring = [[title substringWithRange:NSMakeRange(10, 8)] stringByAppendingString:[title substringWithRange:NSMakeRange(19, 4)]];
        }
}

#pragma mark---扫描的回调
-(void)didDiscoverPeripheral:(NSInteger)tag :(CBPeripheral *)peripheral scanData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (peripheral.name.length < 13) {
        return;
    }
    if([[peripheral.name substringWithRange:NSMakeRange(0, 13)]isEqualToString: @"Qgj-SmartBike"]){
        const char *valueString = [[[advertisementData objectForKey:@"kCBAdvDataManufacturerData"] description] cStringUsingEncoding: NSUTF8StringEncoding];
        if (valueString == NULL) {
            return;
        }
        NSString *title = [[NSString alloc] initWithUTF8String:valueString];
        
        if (title.length < 9) {
            return;
        }
        NSString *name = [title substringWithRange:NSMakeRange(1, 8)];
        
        if ([name isEqualToString: @"0000a501"] && [QFTools isBlankString:macstring]) {
            
            if(![uuidarray objectForKey:[[title substringWithRange:NSMakeRange(10, 8)] stringByAppendingString:[title substringWithRange:NSMakeRange(19, 4)]]]){
                
                SearchBleModel *model=[[SearchBleModel alloc]init];
                model.peripher=peripheral;
                model.rssi = RSSI;
                model.titlename = title;
                [rssiList addObject:model];
                [uuidarray setObject:model forKey:[[title substringWithRange:NSMakeRange(10, 8)] stringByAppendingString:[title substringWithRange:NSMakeRange(19, 4)]]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.choseView reloadData];
                });
            }else if([uuidarray objectForKey:[[title substringWithRange:NSMakeRange(10, 8)] stringByAppendingString:[title substringWithRange:NSMakeRange(19, 4)]]]){
                
                SearchBleModel *model = [uuidarray objectForKey:[[title substringWithRange:NSMakeRange(10, 8)] stringByAppendingString:[title substringWithRange:NSMakeRange(19, 4)]]];
                if (RSSI.intValue >0 ) {
                    model.rssi = [NSNumber numberWithInt:-64];;
                }else{
                    model.rssi = RSSI;
                }
                
                model.searchCount = 1;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.choseView reloadData];
                });
            }
        }else if (![name isEqualToString: @"0000a501"] && [QFTools isBlankString:macstring]) {
            
            if([uuidarray objectForKey:[[title substringWithRange:NSMakeRange(5, 4)] stringByAppendingString:[title substringWithRange:NSMakeRange(10, 8)]]]){
                
                SearchBleModel *model = [uuidarray objectForKey:[[title substringWithRange:NSMakeRange(5, 4)] stringByAppendingString:[title substringWithRange:NSMakeRange(10, 8)]]];
                [rssiList removeObject:model];
                [uuidarray removeObjectForKey:[[title substringWithRange:NSMakeRange(5, 4)] stringByAppendingString:[title substringWithRange:NSMakeRange(10, 8)]]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.choseView reloadData];
                });
            }
        }
    }
}


-(void)vcUpdateNewDeviceStatusAction:(NSNotification*)notification{
    
    [NSNOTIC_CENTER removeObserver:self name:KNotification_ConnectStatus object:nil];
    if([AppDelegate currentAppDelegate].device.deviceStatus == 0){
        
    }else if([AppDelegate currentAppDelegate].device.deviceStatus == 2){
        
        [ViewController cancelPreviousPerformRequestsWithTarget:self selector:@selector(vcOvertime) object:nil];
        [[AppDelegate currentAppDelegate].device stopScan];
        //数据通知
        [NSNOTIC_CENTER addObserver:self selector:@selector(vcQueryFirmEditionData:) name:KNotification_UpdateeditionValue object:nil];
        [NSNOTIC_CENTER addObserver:self selector:@selector(vcQueryKeyVersionData:) name:KNotification_VersionValue object:nil];
        [NSNOTIC_CENTER addObserver:self selector:@selector(vcQueryKeyType:) name:KNotification_QueryKeyType object:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            [[AppDelegate currentAppDelegate].device readDiviceInformation];
        });
    }
}

-(void)vcOvertime{
    
    [self.loadview removeFromSuperview];
    [NSNOTIC_CENTER removeObserver:self name:KNotification_ConnectStatus object:nil];
    [[AppDelegate currentAppDelegate].device remove];
    [SVProgressHUD showSimpleText:@"绑定超时"];
    [self VcnextBtnClick];
}


-(void)vcQueryFirmEditionData:(NSNotification *)data{
    
    [NSNOTIC_CENTER removeObserver:self name:KNotification_UpdateeditionValue object:nil];
    self.firmedition = data.userInfo[@"edition"];
    [[AppDelegate currentAppDelegate].device readDiviceVersion];
    [self performSelector:@selector(checkdevicenew) withObject:nil afterDelay:2];
}

-(void)checkdevicenew{

    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/checkdevicenew"];
    NSString *token = [QFTools getdata:@"token"];
    NSDictionary *parameters = @{@"token": token,@"sn":macstring.uppercaseString};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            NSDictionary *device_info = data[@"device_info"];
            self.brandid = device_info[@"default_brand_id"];
            [self getDefaultBikeBrand];
            
        }else if([dict[@"status"] intValue] == 1017){
            
            self.brandName = @"骑管家";
            self.logo = [QFTools getdata:@"defaultlogo"];
            self.brandid = [NSNumber numberWithInt:0];
            [self addVcbikebinding];
        }else{
            
            [self vcOvertime];
        }
        
    }failure:^(NSError *error) {
        NSLog(@"error :%@",error);
        [self vcOvertime];
        
    }];
}

-(void)getDefaultBikeBrand{
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/getbrandlist"];
    NSString *token = [QFTools getdata:@"token"];
    NSDictionary *parameters = @{@"token": token,@"firm_version":self.firmedition,@"mac":macstring.uppercaseString};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            NSMutableArray *userinfo = data[@"brands"];
            for (NSDictionary *dataDict in userinfo) {
                NSNumber *brand = dataDict[@"brand_id"];
                if (brand.intValue == self.brandid.intValue) {
                    self.brandName = dataDict[@"brand_name"];
                    self.logo = dataDict[@"logo"];
                }else if (self.brandid.intValue == 0){
                    
                    self.brandName = @"骑管家";
                    self.logo = [QFTools getdata:@"defaultlogo"];
                }
            }
            
            [self addVcbikebinding];
        }else if([dict[@"status"] intValue] == 1001){
            
            [self vcOvertime];
        }else{
            [self vcOvertime];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        [self vcOvertime];
        
    }];
}


- (void)addVcbikebinding{
    
    if(self.deviceVersion == nil){
        
        self.deviceVersion = @"";//硬件版本号
    }
    
    if(self.keyVersion == nil){
        
        self.keyVersion = @"1";//钥匙版本号
    }
    
    if ([LVFmdbTool queryBikeData:nil].count == 5) {
        
        [SVProgressHUD showSimpleText:@"最多同时只能绑定5辆车"];
        return;
    }
    
    NSNumber *modelid = [NSNumber numberWithInt:0];
    NSNumber *batttype = [NSNumber numberWithInt:0];
    NSNumber *wheelsize = [NSNumber numberWithInt:0];
    NSNumber *battvol = [NSNumber numberWithInt:0];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/bindbike"];
    NSString *token = [QFTools getdata:@"token"];
    NSDictionary *brand_info=[NSDictionary dictionaryWithObjectsAndKeys:self.brandid,@"brand_id",self.brandName,@"brand_name",nil];
    NSDictionary *model_info=[NSDictionary dictionaryWithObjectsAndKeys:modelid,@"model_id",@"自定义",@"model_name",batttype,@"batt_type",battvol,@"batt_vol",wheelsize,@"wheel_size",nil];
    NSDictionary *bike_info=[NSDictionary dictionaryWithObjectsAndKeys:self.firmedition,@"firm_version",self.deviceVersion,@"hw_version",self.keyVersion,@"key_version",macstring.uppercaseString,@"mac",model_info,@"model_info",brand_info,@"brand_info",nil];
    NSDictionary *parameters = @{@"token": token,@"bike_info":bike_info};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            [USER_DEFAULTS setValue:macstring.uppercaseString forKey:SETRSSI];
            [USER_DEFAULTS setObject: macstring.uppercaseString forKey:Key_MacSTRING];
            [USER_DEFAULTS synchronize];
            
            NSDictionary *data = dict[@"data"];
            NSDictionary *bike_info = data[@"bike_info"];
            BikeInfoModel *bikeInfo = [BikeInfoModel yy_modelWithDictionary:bike_info];
            NSString *child = @"0";
            NSString *main = bikeInfo.passwd_info.main;
            
            BikeModel *pmodel = [BikeModel modalWith:bikeInfo.bike_id bikename:bikeInfo.bike_name ownerflag:bikeInfo.owner_flag hwversion:bikeInfo.hw_version firmversion:bikeInfo.firm_version keyversion:bikeInfo.key_version mac:bikeInfo.mac mainpass:main password:child bindedcount:bikeInfo.binded_count ownerphone:[QFTools getdata:@"phone_num"]];
            [LVFmdbTool insertBikeModel:pmodel];
            
            BrandModel *bmodel = [BrandModel modalWith:bikeInfo.bike_id brandid:bikeInfo.brand_info.brand_id brandname:bikeInfo.brand_info.brand_name logo:self.logo];
            [LVFmdbTool insertBrandModel:bmodel];
            
            if (bikeInfo.model_info.model_id == 0) {
                
                bikeInfo.model_info.picture_b = [QFTools getdata:@"defaultimage"];
                
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
            self.bikeName = bikeInfo.bike_name;
            self.bikeid = [NSNumber numberWithInteger:bikeInfo.bike_id];
            
            self.masterpwd = [QFTools toHexString:(long)[bikeInfo.passwd_info.main longLongValue]];
            NSString *childpwdone = [QFTools toHexString:(long)[bikeInfo.passwd_info.children[0] longLongValue]];
            NSString *childpwdtwo = [QFTools toHexString:(long)[bikeInfo.passwd_info.children[1] longLongValue]];
            NSString *childpwdthree = [QFTools toHexString:(long)[bikeInfo.passwd_info.children[2] longLongValue]];
            NSString *childpwdfour = [QFTools toHexString:(long)[bikeInfo.passwd_info.children[3] longLongValue]];
            NSString *childpwdfive = [QFTools toHexString:(long)[bikeInfo.passwd_info.children[4] longLongValue]];
            
            if (self.masterpwd.length !=8) {
                int masterpwdCount = 8 - (int)self.masterpwd.length;
                for (int i = 0; i<masterpwdCount; i++) {
                    self.masterpwd = [@"0" stringByAppendingFormat:@"%@",self.masterpwd];
                }
            }
            
            if (childpwdone.length !=8) {
                int childpwdoneCount = 8 - (int)childpwdone.length;
                for (int i = 0; i<childpwdoneCount; i++) {
                    childpwdone = [@"0" stringByAppendingFormat:@"%@", childpwdone];
                }
            }
            
            if (childpwdtwo.length !=8) {
                int childpwdtwoCount = 8 - (int)childpwdtwo.length;
                for (int i = 0; i<childpwdtwoCount; i++) {
                    childpwdtwo = [@"0" stringByAppendingFormat:@"%@", childpwdtwo];
                }
            }
            
            if (childpwdthree.length !=8) {
                int childpwdthreeCount = 8 - (int)childpwdthree.length;
                for (int i = 0; i<childpwdthreeCount; i++) {
                    childpwdthree = [@"0" stringByAppendingFormat:@"%@",childpwdthree];
                }
            }
            
            if (childpwdfour.length !=8) {
                int childpwdfourCount = 8 - (int)childpwdfour.length;
                for (int i = 0; i<childpwdfourCount; i++) {
                    childpwdfour = [@"0" stringByAppendingFormat:@"%@",childpwdfour];
                }
            }
            
            if (childpwdfive.length !=8) {
                int childpwdfiveCount = 8 - (int)childpwdfive.length;
                for (int i = 0; i<childpwdfiveCount; i++) {
                    childpwdfive = [@"0" stringByAppendingFormat:@"%@",childpwdfive];
                }
            }
            
            NSString *passwordHEX = [@"A500001E5001" stringByAppendingFormat:@"%@%@%@%@%@%@", self.masterpwd, childpwdone,childpwdtwo,childpwdthree, childpwdfour,childpwdfive];
            [[AppDelegate currentAppDelegate].device sendHexstring:passwordHEX];
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:[passwordHEX substringWithRange:NSMakeRange(0, 40)]]];
            
            [NSNOTIC_CENTER addObserver:self selector:@selector(VcboundSuccess:) name:KNotification_BindingQGJSuccess object:nil];
            //[NSNOTIC_CENTER addObserver:self selector:@selector(Vcconnectdevice:) name:KNotification_ConnectStatus object:nil];
            [self performSelector:@selector(Vcbindingfail) withObject:nil afterDelay:30];
        }
        else if([dict[@"status"] intValue] == 1001){
            [self vcOvertime];
        }else{
            [self vcOvertime];
        }
        
    }failure:^(NSError *error) {
        
        [self vcOvertime];
    }];
}

-(void)VcboundSuccess:(NSNotification *)data{
    
    [NSNOTIC_CENTER removeObserver:self name:KNotification_BindingQGJSuccess object:nil];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(Vcbindingfail) object:nil];
    NSString *date = data.userInfo[@"data"];
    if ([[date substringWithRange:NSMakeRange(8, 6)] isEqualToString:@"500101"]){

        [[AppDelegate currentAppDelegate].device remove];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
            
            [self bikeBindSuccess];
        });
        
    }else if([[date substringWithRange:NSMakeRange(8, 6)] isEqualToString:@"500100"]){
        [self removebikeDB];
        [self VcnextBtnClick];
    }
}


-(void)bikeBindSuccess{
    [self.loadview removeFromSuperview];
    [AppDelegate currentAppDelegate].device.binding = NO;
    [NSNOTIC_CENTER postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
    [SVProgressHUD showSimpleText:@"绑定成功"];
}

-(void) removebikeDB{
    
    NSString *deleteBikeSql = [NSString stringWithFormat:@"DELETE FROM bike_modals WHERE bikeid LIKE '%zd'", self.bikeid];
    [LVFmdbTool deleteBikeData:deleteBikeSql];
    
    NSString *deleteBrandSql = [NSString stringWithFormat:@"DELETE FROM brand_modals WHERE bikeid LIKE '%zd'", self.bikeid];
    [LVFmdbTool deleteBrandData:deleteBrandSql];
    
    NSString *deleteInfoSql = [NSString stringWithFormat:@"DELETE FROM info_modals WHERE bikeid LIKE '%zd'", self.bikeid];
    [LVFmdbTool deleteModelData:deleteInfoSql];
    
    NSString *deletePeripherSql = [NSString stringWithFormat:@"DELETE FROM periphera_modals WHERE bikeid LIKE '%zd'", self.bikeid];
    [LVFmdbTool deletePeripheraData:deletePeripherSql];
}

- (void)Vcbindingfail{
    
    [NSNOTIC_CENTER removeObserver:self name:KNotification_BindingQGJSuccess object:nil];
    [NSNOTIC_CENTER removeObserver:self name:KNotification_ConnectStatus object:nil];
    [self removebikeDB];
    macstring = nil;
    [SVProgressHUD showSimpleText:@"绑定失败"];
    [[AppDelegate currentAppDelegate].device stopScan];
    [self.loadview removeFromSuperview];
    self.search.hidden = YES;
    self.giftImage.image = [UIImage imageNamed:@"binding_fail"];
    self.upBtn.hidden = YES;
    self.aView.hidden = YES;
    [AppDelegate currentAppDelegate].device.binding = NO;
    [rssiList removeAllObjects];
    [uuidarray removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.choseView reloadData];
    });
    
    UIButton *scanAgainBtn = [[UIButton alloc] initWithFrame:CGRectMake(75, ScreenHeight - 120, ScreenWidth - 150, 45)];
    [scanAgainBtn setTitle:@"重新搜索" forState:UIControlStateNormal];
    [scanAgainBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    scanAgainBtn.backgroundColor = [UIColor clearColor];
    scanAgainBtn.contentMode = UIViewContentModeCenter;
    [scanAgainBtn.layer setCornerRadius:10.0]; // 切圆角
    [scanAgainBtn.layer setBorderColor:[QFTools colorWithHexString:MainColor].CGColor];
    [scanAgainBtn.layer setBorderWidth:1];
    [scanAgainBtn.layer setMasksToBounds:YES];
    [scanAgainBtn addTarget:self action:@selector(vcScanAgain:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanAgainBtn];
    
}

-(void)vcScanAgain:(UIButton *)btn{
    
    [btn removeFromSuperview];
    [self.aView rotate360WithDuration:2.0 repeatCount:HUGE_VALF timingMode:i7Rotate360TimingModeLinear];
    [[AppDelegate currentAppDelegate].device startBackstageScan];
    self.giftImage.image = [UIImage imageNamed:@"find_bg"];
    self.search.hidden = NO;
    self.aView.hidden = NO;
    self.upBtn.hidden = NO;
}

//获取钥匙版本号
-(void)vcQueryKeyVersionData:(NSNotification *)data{
    
    [NSNOTIC_CENTER removeObserver:self name:KNotification_VersionValue object:nil];
    self.deviceVersion = data.userInfo[@"version"];
    [self getKeyType];
}

//发送钥匙码
-(void)getKeyType{
    
    NSString *passwordHEX = @"A50000061005";
    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
}

-(void)vcQueryKeyType:(NSNotification*)notification{
    
    [NSNOTIC_CENTER removeObserver:self name:KNotification_QueryKeyType object:nil];
    NSString *date = notification.userInfo[@"data"];
    
    if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1005"]) {
        
        self.keyVersion = [date substringWithRange:NSMakeRange(13, 1)];
    }
}

-(void)VcnextBtnClick{
    
    [self.loadview removeFromSuperview];
    [[AppDelegate currentAppDelegate].device remove];
    [AppDelegate currentAppDelegate].device.binding = NO;
    self.aView.hidden = YES;
    self.search.hidden = YES;
    self.giftImage.image = [UIImage imageNamed:@"binding_fail"];
    self.upBtn.hidden = YES;
    macstring = nil;//mac地址置空，避免下次扫描直接连接
    [rssiList removeAllObjects];
    [uuidarray removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.choseView reloadData];
    });
    
    UIButton *scanAgainBtn = [[UIButton alloc] initWithFrame:CGRectMake(75, ScreenHeight - 120, ScreenWidth - 150, 45)];
    [scanAgainBtn setTitle:@"重新搜索" forState:UIControlStateNormal];
    [scanAgainBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    scanAgainBtn.backgroundColor = [UIColor clearColor];
    scanAgainBtn.contentMode = UIViewContentModeCenter;
    [scanAgainBtn.layer setCornerRadius:10.0];
    [scanAgainBtn.layer setBorderColor:[QFTools colorWithHexString:MainColor].CGColor];
    [scanAgainBtn.layer setBorderWidth:1];
    [scanAgainBtn.layer setMasksToBounds:YES];
    [scanAgainBtn addTarget:self action:@selector(vcScanAgain:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanAgainBtn];
    
}

-(void)dealloc{
    NSLog(@"%s dealloc",object_getClassName(self));
    [AppDelegate currentAppDelegate].device.binding = NO;
    [[AppDelegate currentAppDelegate].device stopScan];
    [NSNOTIC_CENTER removeObserver:self name:KNotification_BluetoothPowerOn object:nil];
    [NSNOTIC_CENTER removeObserver:self name:KNotification_BluetoothPowerOff object:nil];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
