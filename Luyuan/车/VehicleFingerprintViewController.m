//
//  VehicleFingerprintViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2017/11/21.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "VehicleFingerprintViewController.h"
#import "InputFingerprintViewController.h"
#import "EditFingerprintViewController.h"

@interface VehicleFingerprintViewController ()<UITableViewDelegate,UITableViewDataSource,EditFingerprinDelegate,inputFingerprinDelegate>
@property (nonatomic ,weak) UITableView *fingerTable;
@property (nonatomic, strong) NSMutableArray *fingerAry;
@property (nonatomic ,weak) UILabel *fingerPrompt;

@end

@implementation VehicleFingerprintViewController

- (NSMutableArray *)fingerAry {
    if (!_fingerAry) {
        _fingerAry = [[NSMutableArray alloc] init];
    }
    return _fingerAry;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    [self configureNavgationItemTitle:@"车辆指纹"];
    
    @weakify(self);
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    NSString *fingerQuerySql = [NSString stringWithFormat:@"SELECT * FROM fingerprint_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *fingerprintmodals = [LVFmdbTool queryFingerprintData:fingerQuerySql];
    self.fingerAry = fingerprintmodals;
    
    FingerprintModel *newFingerModel = [FingerprintModel modalWith:0 fp_id:0 pos:0 name:@"新建指纹" added_time:0];
    [self.fingerAry addObject:newFingerModel];
    
    [self setupView];
}

-(void)setupView{
    
    UIImageView *fingerprintIcon = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 30, 70, 60, 60)];
    fingerprintIcon.image = [UIImage imageNamed:@"fingerprint_bg"];
    [self.view addSubview:fingerprintIcon];
    
    UILabel *TitleLab = [[UILabel alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(fingerprintIcon.frame)+ 25, ScreenWidth - 80, 20)];
    TitleLab.text = @"智能电动车";
    TitleLab.textColor = [UIColor blackColor];
    TitleLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:TitleLab];
    
    UILabel *fingerPrompt = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(TitleLab.frame)+ 15, ScreenWidth, 10)];
    fingerPrompt.text = [NSString stringWithFormat:@"指纹列表（%d/10）",self.fingerAry.count-1];
    fingerPrompt.textColor = [QFTools colorWithHexString:@"#cccccc"];
    fingerPrompt.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:fingerPrompt];
    self.fingerPrompt = fingerPrompt;
    
    UITableView *fingerTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(TitleLab.frame)+ 30, ScreenWidth, ScreenHeight *.4)];
    fingerTable.bounces = NO;
    fingerTable.delegate = self;
    fingerTable.dataSource = self;
    //fingerTable.separatorStyle = NO;
    fingerTable.backgroundColor = [UIColor clearColor];
    [fingerTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:fingerTable];
    self.fingerTable = fingerTable;
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.fingerAry.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    if ([self.fingerAry[indexPath.row] bikeid] == 0) {
        
        cell.textLabel.textColor = [QFTools colorWithHexString:MainColor];
    }else{
        
        cell.imageView.image = [UIImage imageNamed:@"user_fingerprint_icon"];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    cell.textLabel.text = [self.fingerAry[indexPath.row] name];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    if (bikemodel.ownerflag == 0) {
        
        [SVProgressHUD showSimpleText:@"子用户无此权限"];
        return;
    }
    
    if (![[AppDelegate currentAppDelegate].device isConnected]) {
        
        [SVProgressHUD showSimpleText:@"蓝牙未连接"];
        return;
    }
    
    if ([self.fingerAry[indexPath.row] bikeid] == 0) {
        if (self.fingerAry.count-1 >=10) {
            [SVProgressHUD showSimpleText:@"指纹录入已达上限"];
            return;
        }
        InputFingerprintViewController *inputVc = [InputFingerprintViewController new];
        inputVc.deviceNum = self.deviceNum;
        inputVc.delegate = self;
        [self.navigationController pushViewController:inputVc animated:YES];
    }else{
        
        EditFingerprintViewController *editVc = [EditFingerprintViewController new];
        editVc.deviceNum = self.deviceNum;
        editVc.fpmodel = [self.fingerAry objectAtIndex:indexPath.row];
        editVc.delegate = self;
        [self.navigationController pushViewController:editVc animated:YES];
    }
}

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath
{
    cell .backgroundColor  = [UIColor whiteColor];
}

#pragma mark -  EditFingerprinDelegate
-(void)deleteFingerprintSuccess{
    
    [self.fingerAry removeAllObjects];
    NSString *fingerQuerySql = [NSString stringWithFormat:@"SELECT * FROM fingerprint_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *fingerprintmodals = [LVFmdbTool queryFingerprintData:fingerQuerySql];
    self.fingerAry = fingerprintmodals;
    FingerprintModel *newFingerModel = [FingerprintModel modalWith:0 fp_id:0 pos:0 name:@"新建指纹" added_time:0];
    [self.fingerAry addObject:newFingerModel];
    
    self.fingerPrompt.text = [NSString stringWithFormat:@"指纹列表（%d/10）",self.fingerAry.count-1];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // something
        [self.fingerTable reloadData];
    });
}

-(void)editFingerprintNameSuccess{
    
    [self.fingerAry removeAllObjects];
    NSString *fingerQuerySql = [NSString stringWithFormat:@"SELECT * FROM fingerprint_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *fingerprintmodals = [LVFmdbTool queryFingerprintData:fingerQuerySql];
    self.fingerAry = fingerprintmodals;
    FingerprintModel *newFingerModel = [FingerprintModel modalWith:0 fp_id:0 pos:0 name:@"新建指纹" added_time:0];
    [self.fingerAry addObject:newFingerModel];
    
    self.fingerPrompt.text = [NSString stringWithFormat:@"指纹列表（%d/10）",self.fingerAry.count-1];
    dispatch_async(dispatch_get_main_queue(), ^{
        // something
        [self.fingerTable reloadData];
    });
}

#pragma mark -  InputFingerprinDelegate
-(void)inputFingerprintOver{
    
    [self.fingerAry removeAllObjects];
    NSString *fingerQuerySql = [NSString stringWithFormat:@"SELECT * FROM fingerprint_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *fingerprintmodals = [LVFmdbTool queryFingerprintData:fingerQuerySql];
    self.fingerAry = fingerprintmodals;
    FingerprintModel *newFingerModel = [FingerprintModel modalWith:0 fp_id:0 pos:0 name:@"新建指纹" added_time:0];
    [self.fingerAry addObject:newFingerModel];
    
    self.fingerPrompt.text = [NSString stringWithFormat:@"指纹列表（%d/10）",self.fingerAry.count-1];
    dispatch_async(dispatch_get_main_queue(), ^{
        // something
        [self.fingerTable reloadData];
    });
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
