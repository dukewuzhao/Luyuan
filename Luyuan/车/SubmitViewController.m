//
//  SubmitViewController.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/7/14.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "SubmitViewController.h"
#import "nameTextFiledController.h"
#import "AccessoriesViewController.h"
#import "BindingUserViewController.h"
#import "VehicleFingerprintViewController.h"
#import "BikeNameTableViewCell.h"
#import "bikeFunctionTableViewCell.h"
#import "BikeInductionDistanceTableViewCell.h"
#import "AutomaticLockTableViewCell.h"
#import "DeviceModel.h"
#import "LianUISlider.h"

@interface SubmitViewController ()<nameTextDelegate,UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource,BindingUserViewControllerDelegate>
{
    
    NSMutableArray *deviceList;
    
    BOOL showFinger;
}

@property (nonatomic, strong)UIAlertView *BluetoothUpgrateAlertView;
@property (nonatomic, strong)UIAlertView *DeviceDelateAlertView;
@property (nonatomic, weak) UITableView *bikeSubmitView;
@property (nonatomic, strong)NSArray *cellIdentifiers;
@property (nonatomic, strong)NSArray *cellClasses;
@end

@implementation SubmitViewController

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    
    deviceList=[[NSMutableArray alloc]init];
    
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    [self configureNavgationItemTitle:bikemodel.bikename];
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(SubmitquerySuccess:) name:KNotification_QueryBleKeyData object:nil];
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(updateDeviceStatusAction2:) name:KNotification_UpdateDeviceStatus object:nil];
    
    @weakify(self);
    [[[NSNOTIC_CENTER rac_addObserverForName:KNotification_FirmwareUpgradeCompleted object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
//        NSNotification *userInfo = x;
//        NSString *upgradeFirmware = userInfo.userInfo[@"data"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.bikeSubmitView reloadData];
        });
        
    }];
    
    
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    
    [self setupMainView];
    
}


- (NSString *)replaceStringWithAsterisk:(NSString *)originalStr startLocation:(NSInteger)startLocation lenght:(NSInteger)lenght
{
    NSString *newStr = originalStr;
    for (int i = 0; i < lenght; i++) {
        NSRange range = NSMakeRange(startLocation, 1);
        newStr = [newStr stringByReplacingCharactersInRange:range withString:@"*"];
        startLocation ++;
    }
    return newStr;
}


-(void)setupMainView{
    
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    NSString *hwversion = bikemodel.hwversion;
    NSString *last = [hwversion substringFromIndex:hwversion.length-1];
    if ([last isEqualToString:@"0"]) {
        showFinger = NO;
    }else{
        showFinger = YES;
    }
    
    UITableView *bikeSubmitView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - navHeight)];
    bikeSubmitView.delegate = self;
    bikeSubmitView.dataSource = self;
    bikeSubmitView.bounces = NO;
    for (NSInteger index = 0; index < self.cellIdentifiers.count; index++) {
        
        [bikeSubmitView registerClass:self.cellClasses[index] forCellReuseIdentifier:self.cellIdentifiers[index]];
    }
    bikeSubmitView.backgroundColor = [UIColor clearColor];
    [bikeSubmitView setSeparatorColor:[QFTools colorWithHexString:@"#cccccc"]];
    //bikeSubmitView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [bikeSubmitView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:bikeSubmitView];
    self.bikeSubmitView = bikeSubmitView;
    
    UIView *footview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 60)];
    [self.view addSubview:footview];
    
    UIButton *UnbundBtn = [[UIButton alloc] initWithFrame:CGRectMake(80, 7.5, ScreenWidth - 160, 45)];
    UnbundBtn.backgroundColor = [UIColor colorWithRed:38.0/255 green:45.0/255 blue:57.0/255 alpha:1.0];
    [UnbundBtn addTarget:self action:@selector(UnbundDevice:) forControlEvents:UIControlEventTouchUpInside];
    [UnbundBtn setTitle:@"解绑车辆" forState:UIControlStateNormal];
    UnbundBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [UnbundBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UnbundBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
    [UnbundBtn.layer setCornerRadius:10.0]; // 切圆角
    [footview addSubview:UnbundBtn];
    bikeSubmitView.tableFooterView = footview;
}

#pragma mark -- TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return 1;
    }else if (section == 1){
        
        if (showFinger) {
            return 3;
        }else{
            return 2;
        }
        
    }else if (section == 2){
        
        return 2;
    }else {
        
        return 2;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        return ScreenHeight *.13 + 5;
    }else if (indexPath.section == 1){
        
        return 40.0f;
    }else if (indexPath.section == 2){
        
        return ScreenHeight *.13 + 5;
    }else {
        
        return 40.0f;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headerView = [UIView new];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *footerView = [UIView new];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 10.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}
- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath{
    
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    
    view.tintColor = [QFTools colorWithHexString:@"#cccccc"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    
    NSString *brandQuerySql = [NSString stringWithFormat:@"SELECT * FROM brand_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *brandmodals = [LVFmdbTool queryBrandData:brandQuerySql];
    BrandModel *brandmodel = brandmodals.firstObject;
    
    if (indexPath.section == 0) {
        
        BikeNameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BikeNameTableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.bikeimage.image = [UIImage imageNamed:@"default_logo"];
        cell.nameLab.text = bikemodel.bikename;
        cell.usericon.image = [UIImage imageNamed:@"smalluserIcon"];
        [cell.modifyBtn setImage:[UIImage imageNamed:@"pen"] forState:UIControlStateNormal];
        NSString* text = bikemodel.ownerphone;
        cell.phone.text = [self replaceStringWithAsterisk:text startLocation:3 lenght:text.length -7];
        
        UIButton * modifyBtn = cell.modifyBtn;
        [modifyBtn addTarget:self action:@selector(modifyBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }else if (indexPath.section == 1) {
        
        bikeFunctionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bikeFunctionTableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *icon = cell.Icon;
        UILabel *name = cell.nameLab;
        UILabel *detailLab = cell.detailLab;
        
        if (indexPath.row == 0){
            
            icon.image = [UIImage imageNamed:@"icon_p2"];
            name.text = @"分享车辆";
            detailLab.text = [NSString stringWithFormat:@"%ld",(long)bikemodel.bindedcount];
        }else if (indexPath.row == 1){
            
            icon.image = [UIImage imageNamed:@"icon_p3"];
            name.text = @"配件管理";
            [detailLab removeFromSuperview];
        }else if (indexPath.row == 2){
            
            icon.image = [UIImage imageNamed:@"fingerprint_icon"];
            name.text = @"指纹管理";
            [detailLab removeFromSuperview];
        }
        
        return cell;
    }else if (indexPath.section == 2){
        
        BikeInductionDistanceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BikeInductionDistanceTableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *swi1 = cell.swit;
        LianUISlider *slider = cell.slider;
        if (indexPath.row == 0) {
            
            cell.Icon.image = [UIImage imageNamed:@"icon_p4"];
            cell.nameLab.text = @"手机感应";
            
            swi1.tag = 7000;
            NSString *fuzzyinduSql = [NSString stringWithFormat:@"SELECT * FROM induction_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
            NSMutableArray *inductionmodals = [LVFmdbTool queryInductionData:fuzzyinduSql];
            InductionModel *indumodel = inductionmodals.firstObject;
            
            if (inductionmodals.count == 0) {
                [swi1 setOn:NO animated:YES];
            }else if(indumodel.induction == 0){
                [swi1 setOn:NO animated:YES];
            }else if (indumodel.induction == 1){
                [swi1 setOn:YES animated:YES];
            }
            
            [swi1 addTarget:self action:@selector(getValue1:) forControlEvents:UIControlEventValueChanged];
            
            slider.tag = 180;
            slider.minimumValue = 60;
            slider.maximumValue = 75;
            if (inductionmodals.count == 0 || indumodel.inductionValue == 0) {
                slider.value = 67;
            }else{
                slider.value = -indumodel.inductionValue;
            }
            [slider addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventTouchUpInside];
            
        }else{
            [swi1 removeFromSuperview];
            cell.Icon.image = [UIImage imageNamed:@"icon_p5"];
            cell.nameLab.text = @"钥匙感应";
            
            slider.tag = 201;
            slider.minimumValue = 60;
            slider.maximumValue = 92;
            
            if (![[AppDelegate currentAppDelegate].device isConnected]) {
                
                [slider setThumbImage:[UIImage imageNamed:@"graypoint"] forState:UIControlStateHighlighted];
                [slider setThumbImage:[UIImage imageNamed:@"graypoint"] forState:UIControlStateNormal];
            }else{
                
                [slider setThumbImage:[UIImage imageNamed:@"slideimage"] forState:UIControlStateHighlighted];
                [slider setThumbImage:[UIImage imageNamed:@"slideimage"] forState:UIControlStateNormal];
            }
            
            [slider addTarget:self action:@selector(updateValue:) forControlEvents:UIControlEventTouchUpInside];
            
            NSString *qureeySql = [NSString stringWithFormat:@"SELECT * FROM induckey_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
            NSMutableArray *indukeymodals = [LVFmdbTool queryInduckeyData:qureeySql];
            InduckeyModel *indukeymodel = indukeymodals.firstObject;
            
            if (indukeymodals.count == 0) {
                
                if([[AppDelegate currentAppDelegate].device isConnected]){
                    NSString *passwordHEX = [NSString stringWithFormat:@"A5000007200300"];
                    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
                    
                }
                
            }else{
                slider.value = indukeymodel.induckeyValue;
            }
                
        }
        
        
        return cell;
    }else{
        
        if (indexPath.row == 0) {
            
            AutomaticLockTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AutomaticLockTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.Icon.image = [UIImage imageNamed:@"icon_p7"];
            cell.nameLab.text = @"自动锁车";
            cell.detailLab.text = @"车辆解锁且车轮45秒不转,自动锁车";
            UISwitch *swi1 = cell.swit;
            swi1.tag = 8000;
            NSString *queraAutomaticLockSql = [NSString stringWithFormat:@"SELECT * FROM automaticlock_models WHERE bikeid LIKE '%zd'", self.deviceNum];
            NSMutableArray *AutomaticLockmodels = [LVFmdbTool queryAutomaticLockData:queraAutomaticLockSql];
            AutomaticLockModel *AutomaticLockmodel = AutomaticLockmodels.firstObject;
            
            if (AutomaticLockmodels.count == 0) {
                
                if ([[AppDelegate currentAppDelegate].device isConnected]) {
                    NSString *AutomaticLockHEX = @"A5000007300302";
                    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:AutomaticLockHEX]];
                }else{
                    [swi1 setOn:NO animated:YES];
                }
                
            }else if(AutomaticLockmodel.automaticlock == 0){
                
                [swi1 setOn:NO animated:YES];
            }else if (AutomaticLockmodel.automaticlock == 1){
                
                [swi1 setOn:YES animated:YES];
            }
            
            [swi1 addTarget:self action:@selector(getValue1:) forControlEvents:UIControlEventValueChanged];
            return cell;
        }else{
            
            bikeFunctionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bikeFunctionTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.Icon.image = [UIImage imageNamed:@"icon_p6"];
            cell.nameLab.text = @"固件版本";
            cell.detailLab.text = bikemodel.firmversion;
            return cell;
        }
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            BindingUserViewController *bindingVc = [BindingUserViewController new];
            bindingVc.bikeid = self.deviceNum;
            bindingVc.delegate = self;
            [self.navigationController pushViewController:bindingVc animated:YES];
        }else if (indexPath.row == 1){
            
            if (![[AppDelegate currentAppDelegate].device isConnected]) {
                
                [SVProgressHUD showSimpleText:@"蓝牙未连接"];
                return;
            }
            
            AccessoriesViewController *accessVc = [AccessoriesViewController new];
            accessVc.deviceNum = self.deviceNum;
            [self.navigationController pushViewController:accessVc animated:YES];
            
        }else if (indexPath.row == 2){
            
            if (![[AppDelegate currentAppDelegate].device isConnected]) {
                
                [SVProgressHUD showSimpleText:@"蓝牙未连接"];
                return;
            }
            
            VehicleFingerprintViewController *vehicleVc = [VehicleFingerprintViewController new];
            vehicleVc.deviceNum = self.deviceNum;
            [self.navigationController pushViewController:vehicleVc animated:YES];
        }
        
    }else if (indexPath.section == 3){
        
        if (indexPath.row == 1) {
            
            if (![[AppDelegate currentAppDelegate].device isConnected]) {
                
                [SVProgressHUD showSimpleText:@"蓝牙未连接"];
                return;
            }
            
            NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
            NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
            BikeModel *bikemodel = bikemodals.firstObject;
            
            if (bikemodel.ownerflag == 0) {
                
                [SVProgressHUD showSimpleText:@"子用户无此权限"];
                return;
            }
            
            if([self.delegate respondsToSelector:@selector(submitBegainUpgrate)])
            {
                [self.delegate submitBegainUpgrate];
            }
        }
    }
}

#pragma mark - BindingUserViewControllerDelegate
-(void)UpdateUsernumberSuccess{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.bikeSubmitView reloadData];
    });
}

#pragma mark - Getter
- (NSArray *)cellIdentifiers {
    
    if (!_cellIdentifiers) {
        
        _cellIdentifiers = @[@"BikeNameTableViewCell",
                             @"bikeFunctionTableViewCell",
                             @"BikeInductionDistanceTableViewCell",@"AutomaticLockTableViewCell"];
    }
    return _cellIdentifiers;
}

- (NSArray *)cellClasses {
    
    if (!_cellClasses) {
        
        _cellClasses = @[[BikeNameTableViewCell class],
                         [bikeFunctionTableViewCell class],
                         [BikeInductionDistanceTableViewCell class],[AutomaticLockTableViewCell class]];;
    }
    return _cellClasses;
}






-(void)UnbundDevice:(UIButton *)btn{
    
    self.DeviceDelateAlertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否解绑" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    self.DeviceDelateAlertView.tag =6000;
    [self.DeviceDelateAlertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 6000) {
        if (buttonIndex != [alertView cancelButtonIndex]) {
            
            dispatch_group_t group = dispatch_group_create();
            dispatch_group_enter(group);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self UnbundBtnClick];
                
                dispatch_group_leave(group);
            });
            //            dispatch_group_enter(group);
            //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //
            //                dispatch_group_leave(group);
            //            });
            
            //            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            //
            //                if (self.connecbikeid == self.deviceNum &&[LVFmdbTool queryBikeData:nil].count > 0) {
            //                    if([self.delegate respondsToSelector:@selector(submitUnbundDevice)])
            //                    {
            //                        [self.delegate submitUnbundDevice];
            //                    }
            //                    [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_ConnectDefaultBike object:nil]];
            //                }
            //
            //                if ([LVFmdbTool queryBikeData:nil].count >0) {
            //
            //                    [self.loadview removeFromSuperview];
            //                    [self.navigationController popToRootViewControllerAnimated:YES];
            //                }else{
            //
            //                    [self.loadview removeFromSuperview];
            //                    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
            //                }
            //            });
        }
    }
}

- (void)modifyBtnClick:(UIButton *)btn{

    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    if (bikemodel.ownerflag == 0) {
        
        [SVProgressHUD showSimpleText:@"子用户无此权限"];
        return;
        
    }
    
    nameTextFiledController * nameText = [nameTextFiledController new];
    nameText.delegate = self;
    nameText.deviceNum = self.deviceNum;
    [self.navigationController pushViewController:nameText animated:NO];

}

-(void) addViewController:(nameTextFiledController *)wuschool didAddString:(NSString *)nametext
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // something
        [self.bikeSubmitView reloadData];
    });
    
    [self configureNavgationItemTitle:nametext];
    if([self.delegate respondsToSelector:@selector(addViewController:didAddString:deviceTag:)])
    {
        [self.delegate addViewController:self didAddString:nametext deviceTag:self.deviceNum];
    }
    
}

-(void)SubmitquerySuccess:(NSNotification *)data{
    
    NSString *date = data.userInfo[@"data"];
    if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"2003"]) {
        
        NSString *date = data.userInfo[@"data"];
        NSData *datevalue = [ConverUtil parseHexStringToByteArray:date];
        Byte *byte=(Byte *)[datevalue bytes];
        if (byte[6] > 92) {
            return;
        }
        
        NSInteger f = byte[6];
        NSString *qureeySql = [NSString stringWithFormat:@"SELECT * FROM induckey_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
        NSMutableArray *indukeymodals = [LVFmdbTool queryInduckeyData:qureeySql];
        NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM induckey_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
        
        if (indukeymodals.count != 0) {
            [LVFmdbTool deleteInduckeyData:deleteSql];
        }
        
        InduckeyModel *inducmodel = [InduckeyModel modalWith:self.deviceNum induckeyValue:f];
        [LVFmdbTool insertInduckeyModel:inducmodel];
        
    }else if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"3003"]) {
        
        NSString *queraAutomaticLockSql = [NSString stringWithFormat:@"SELECT * FROM automaticlock_models WHERE bikeid LIKE '%zd'", self.deviceNum];
        NSMutableArray *AutomaticLockmodels = [LVFmdbTool queryAutomaticLockData:queraAutomaticLockSql];
        
        if (AutomaticLockmodels.count == 0) {
            
            if ([[date substringWithRange:NSMakeRange(8, 6)] isEqualToString:@"300300"]){
                
                AutomaticLockModel *automaticlockmodel = [AutomaticLockModel modalWith:self.deviceNum automaticlock:0];
                [LVFmdbTool insertAutomaticLockModel:automaticlockmodel];
                
            }else if ([[date substringWithRange:NSMakeRange(8, 6)] isEqualToString:@"300301"]){
                
                AutomaticLockModel *automaticlockmodel = [AutomaticLockModel modalWith:self.deviceNum automaticlock:1];
                [LVFmdbTool insertAutomaticLockModel:automaticlockmodel];
            }
            
        }else{
            
            if ([[date substringWithRange:NSMakeRange(8, 6)] isEqualToString:@"300300"]){
                
                NSString *updateSql = [NSString stringWithFormat:@"UPDATE automaticlock_models SET automaticlock = '%zd' WHERE bikeid = '%zd'", 0,self.deviceNum];
                [LVFmdbTool modifyData:updateSql];
            }else if ([[date substringWithRange:NSMakeRange(8, 6)] isEqualToString:@"300301"]){
                
                NSString *updateSql = [NSString stringWithFormat:@"UPDATE automaticlock_models SET automaticlock = '%zd' WHERE bikeid = '%zd'", 1,self.deviceNum];
                [LVFmdbTool modifyData:updateSql];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // something
            [self.bikeSubmitView reloadData];
        });
        
    }
}


-(void)breakBLEconnect{

    [[AppDelegate currentAppDelegate].device startScan];
    
}


- (void)updateValue:(UISlider *)sender{
    
    if (sender.tag == 180) {
        
        int f = sender.value;
        NSString *value = [NSString stringWithFormat:@"%d",f];
        NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:value,@"value", nil];
        
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_UpdateValue object:nil userInfo:dict]];
        
        }else if (sender.tag == 201){
        
        if (![[AppDelegate currentAppDelegate].device isConnected]) {
            
            [SVProgressHUD showSimpleText:@"蓝牙未连接"];
            return;
        }
            
        int f = sender.value;
        NSString *passwordHEX = [NSString stringWithFormat:@"A50000072003%@",[ConverUtil ToHex:f]];
        [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
    }
}


//解绑回调
-(void)UnbundBtnClick{
    
    LoadView *loadview = [[LoadView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    loadview.protetitle.text = @"删除车辆中";
    [[UIApplication sharedApplication].keyWindow addSubview:loadview];
    
    NSString *token = [QFTools getdata:@"token"];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/unbindbike"];
    
    NSNumber *bikeid = [NSNumber numberWithInteger:self.deviceNum];
    NSDictionary *parameters = @{@"token": token,@"bike_id":bikeid};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSString *deleteBikeSql = [NSString stringWithFormat:@"DELETE FROM bike_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
            [LVFmdbTool deleteBikeData:deleteBikeSql];
            
            NSString *deleteBrandSql = [NSString stringWithFormat:@"DELETE FROM brand_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
            [LVFmdbTool deleteBrandData:deleteBrandSql];
            
            NSString *deleteInfoSql = [NSString stringWithFormat:@"DELETE FROM info_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
            [LVFmdbTool deleteModelData:deleteInfoSql];
            
            NSString *deletePeripherSql = [NSString stringWithFormat:@"DELETE FROM periphera_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
            [LVFmdbTool deletePeripheraData:deletePeripherSql];
            
            NSString *deleteFingerSql = [NSString stringWithFormat:@"DELETE FROM fingerprint_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
            [LVFmdbTool deleteFingerprintData:deleteFingerSql];
            
            [[AppDelegate currentAppDelegate].device remove];
            [USER_DEFAULTS removeObjectForKey:Key_DeviceUUID];
            [USER_DEFAULTS removeObjectForKey:Key_MacSTRING];
            [USER_DEFAULTS removeObjectForKey:SETRSSI];
            [USER_DEFAULTS removeObjectForKey:passwordDIC];
            [USER_DEFAULTS synchronize];
            
            [AppDelegate currentAppDelegate]. device.deviceStatus=0;
            [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_UpdateDeviceStatus object:nil]];
            
            
            NSString *deleteuuidSql = [NSString stringWithFormat:@"DELETE FROM peripherauuid_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
            [LVFmdbTool deletePeripheraUUIDData:deleteuuidSql];
            
            NSString *inductionSql = [NSString stringWithFormat:@"DELETE FROM induction_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
            [LVFmdbTool deleteInductionData:inductionSql];
            
            NSString *deleteinduckey = [NSString stringWithFormat:@"DELETE FROM induckey_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
            [LVFmdbTool deleteInduckeyData:deleteinduckey];
            
            NSString *deleteAutomaticlockkey = [NSString stringWithFormat:@"DELETE FROM automaticlock_models WHERE bikeid LIKE '%zd'", self.deviceNum];
            [LVFmdbTool deleteAutomaticLockData:deleteAutomaticlockkey];
            
            if ([LVFmdbTool queryBikeData:nil].count >0) {
                
                if([self.delegate respondsToSelector:@selector(submitUnbundDevice)])
                {
                    [self.delegate submitUnbundDevice];
                }
                
                [loadview removeFromSuperview];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }else{
                
                [loadview removeFromSuperview];
                [NSNOTIC_CENTER postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
            }
            
        }else{
            [loadview removeFromSuperview];
            [SVProgressHUD showSimpleText:@"解绑失败"];
        }
        
    }failure:^(NSError *error) {
        
        [loadview removeFromSuperview];
        NSLog(@"error :%@",error);
        
    }];
}


- (void)getValue1:(id)sender{
    
    UISwitch *swi=(UISwitch *)sender;
    
    if (swi.tag == 7000) {
        
        if (swi.isOn) {
            NSLog(@"On");
            
            
            NSString *result = @"on";
            NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:result,@"data", nil];
            [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:@"Inductionswitch" object:nil userInfo:dict]];
            
        }else{
            
            NSLog(@"Off");
            NSString *result = @"off";
            NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:result,@"data", nil];
            [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:@"Inductionswitch" object:nil userInfo:dict]];
        }
        
    }else if (swi.tag == 8000){
    
        if (![[AppDelegate currentAppDelegate].device isConnected]) {
            
            [SVProgressHUD showSimpleText:@"蓝牙未连接"];
            return;
        }
        
        NSString *queraAutomaticLockSql = [NSString stringWithFormat:@"SELECT * FROM automaticlock_models WHERE bikeid LIKE '%zd'", self.deviceNum];
        NSMutableArray *AutomaticLockmodels = [LVFmdbTool queryAutomaticLockData:queraAutomaticLockSql];
        
        if (AutomaticLockmodels.count == 0) {
            
            if (swi.isOn) {
                
                if ([[AppDelegate currentAppDelegate].device isConnected]) {
                    NSString *AutomaticLockHEX = @"A5000007300301";
                    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:AutomaticLockHEX]];
                }
                
            }else{
                
                if ([[AppDelegate currentAppDelegate].device isConnected]) {
                    NSString *AutomaticLockHEX = @"A5000007300300";
                    [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:AutomaticLockHEX]];
                }
            }
            
        }else{
        
            if (swi.isOn) {
                NSString *AutomaticLockHEX = @"A5000007300301";
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:AutomaticLockHEX]];
            }else{
                NSString *AutomaticLockHEX = @"A5000007300300";
                [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:AutomaticLockHEX]];
            }
        }
    }
}


//车辆的连接状态改变响应函数
-(void)updateDeviceStatusAction2:(NSNotification*)notification{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // something
        [self.bikeSubmitView reloadData];
    });
}

-(void)dealloc{
    
    [NSNOTIC_CENTER removeObserver:self name:KNotification_UpdateDeviceStatus object:nil];
    [NSNOTIC_CENTER removeObserver:self name:KNotification_QueryBleKeyData object:nil];
    [self.BluetoothUpgrateAlertView dismissWithClickedButtonIndex:0 animated:YES];
    [self.DeviceDelateAlertView dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
}

//****************以上是固件升级**********//
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
