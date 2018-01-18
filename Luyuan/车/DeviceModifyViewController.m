//
//  DeviceModifyViewController.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/10/29.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "DeviceModifyViewController.h"

@interface DeviceModifyViewController ()

@end

@implementation DeviceModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    [self configureNavgationItemTitle:@"智能配件信息"];
    
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }];

    [self setupView];
}

- (void)setupView{
    
    NSString *QuerykeySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE deviceid LIKE '%zd' AND bikeid LIKE '%zd'", self.deviceId,self.deviceNum];
    NSMutableArray *keymodals = [LVFmdbTool queryPeripheraData:QuerykeySql];
    PeripheralModel *perModel = keymodals.firstObject;
    UIView *model = [[UIView alloc] initWithFrame:CGRectMake(0, 10, ScreenWidth, 40)];
    model.backgroundColor =[UIColor whiteColor];
    [self.view addSubview:model];
    
    UILabel *modelLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 20)];
    modelLable.text = @"条码";
    modelLable.textColor = [UIColor blackColor];
    modelLable.textAlignment = NSTextAlignmentLeft;
    modelLable.font = [UIFont systemFontOfSize:15];
    [model addSubview:modelLable];
    
    UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 200, 10, 180, 20)];
    typeLabel.textColor = [QFTools colorWithHexString:@"#cccccc"];
    typeLabel.text = perModel.sn;
    typeLabel.font = [UIFont systemFontOfSize:14];
    typeLabel.textAlignment = NSTextAlignmentRight;
    [model addSubview:typeLabel];
    
    UIView *bindingNumber = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(model.frame)+10, ScreenWidth, 40)];
    bindingNumber.backgroundColor =[UIColor whiteColor];
    [self.view addSubview:bindingNumber];
    
    
    UILabel *bindingNumberLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 20)];
    bindingNumberLable.text = @"MAC地址";
    bindingNumberLable.textColor = [UIColor blackColor];
    bindingNumberLable.textAlignment = NSTextAlignmentLeft;
    bindingNumberLable.font = [UIFont systemFontOfSize:15];
    [bindingNumber addSubview:bindingNumberLable];
    
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 200, 10, 180, 20)];
    numberLabel.textAlignment = NSTextAlignmentRight;
    numberLabel.textColor = [QFTools colorWithHexString:@"#cccccc"];
    numberLabel.font = [UIFont systemFontOfSize:14];
    numberLabel.text = perModel.mac;
    [bindingNumber addSubview:numberLabel];
    
    UIView *accessories = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bindingNumber.frame)+10, ScreenWidth, 40)];
    accessories.backgroundColor =[UIColor whiteColor];
    [self.view addSubview:accessories];
    
    UILabel *accessoriesLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 20)];
    accessoriesLable.text = @"类型";
    accessoriesLable.textColor = [UIColor blackColor];
    accessoriesLable.textAlignment = NSTextAlignmentLeft;
    accessoriesLable.font = [UIFont systemFontOfSize:15];
    [accessories addSubview:accessoriesLable];
    
    UILabel *battery = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 110, 10, 90, 20)];
    battery.textAlignment = NSTextAlignmentRight;
    battery.textColor = [QFTools colorWithHexString:@"#cccccc"];
    battery.font = [UIFont systemFontOfSize:14];
    [accessories addSubview:battery];
    
    if (perModel.type == 2) {
        
        battery.text = @"蓝牙钥匙";
        
    }else if (perModel.type == 4) {
        
        battery.text = @"GPS外设";
        
    }else if (perModel.type == 5) {
        
        battery.text = @"智能手环";
        
    }
    
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
