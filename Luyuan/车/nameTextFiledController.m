//
//  nameTextFiledController.m
//  阿尔卑斯
//
//  Created by 同时科技 on 16/7/19.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "nameTextFiledController.h"

@interface nameTextFiledController ()
{
    UITextField * nameFiled;
    UIButton * saveBtn;
    NSMutableArray *deviceAry;
}
@end

@implementation nameTextFiledController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    [self configureNavgationItemTitle:@"车辆名"];
    deviceAry = [[NSMutableArray alloc] init];
    
    WS(weakself);
    
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        
        [weakself.navigationController popViewControllerAnimated:NO];
        
    }];
    
    [self configureRightBarButtonWithTitle:@"保存" action:^{
        
        [weakself updateBikeName];
        
        
    }];
    
    [self setupNameText];
    [self setTap];
}

-(void)updateBikeName{
    
    if ([QFTools isBlankString:nameFiled.text ]) {
        [SVProgressHUD showSimpleText:@"车名不能为空"];
        return;
    }else if (nameFiled.text.length>6) {
        [SVProgressHUD showSimpleText:@"车名不合法"];
        return ;
    }
    
    NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM info_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
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
    
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    NSNumber *bikeid = [NSNumber numberWithInt:(int)bikemodel.bikeid];
    NSNumber *bindedcount = [NSNumber numberWithInt:(int)bikemodel.bindedcount];
    NSNumber *ownerflag = [NSNumber numberWithInt:(int)bikemodel.ownerflag];
    NSString *hwversion = bikemodel.hwversion;
    NSString *firversion = bikemodel.firmversion;
    NSString *mac = bikemodel.mac;
    
    NSString *brandQuerySql = [NSString stringWithFormat:@"SELECT * FROM brand_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *brandmodals = [LVFmdbTool queryBrandData:brandQuerySql];
    BrandModel *brandmodel = brandmodals.firstObject;
    NSNumber *brandid2 = [NSNumber numberWithInt:(int)brandmodel.brandid];
    NSString *brandname = brandmodel.brandname;
    NSString *logo = brandmodel.logo;
    NSDictionary *brand_info = [NSDictionary dictionaryWithObjectsAndKeys:brandid2,@"brand_id",brandname,@"brand_name",logo,@"logo",nil];
    
    NSString *peripheraQuerySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *peripheramodals = [LVFmdbTool queryPeripheraData:peripheraQuerySql];
    for (PeripheralModel *peripheramodel in peripheramodals) {
        
        NSNumber *deviceId = [NSNumber numberWithInt:(int)peripheramodel.deviceid];
        NSString *firversion = peripheramodel.firmversion;
        NSString *mac = peripheramodel.mac;
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
    
    NSDictionary *bike_info = [NSDictionary dictionaryWithObjectsAndKeys:bikeid,@"bike_id",nameFiled.text,@"bike_name",bindedcount,@"binded_count",firversion,@"firm_version",mac,@"mac",ownerflag,@"owner_flag",hwversion,@"hwversion",brand_info,@"brand_info",model_info,@"model_info",passwd_info,@"passwd_info",deviceAry,@"device_info",nil];
    
    NSString *token = [QFTools getdata:@"token"];
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/updatebikeinfo"];
    NSDictionary *parameters = @{@"token": token, @"bike_info": bike_info};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            if([self.delegate respondsToSelector:@selector(addViewController:didAddString:)])
            {
                [self.delegate addViewController:self didAddString:nameFiled.text];
            }
            
            NSString *updateSql = [NSString stringWithFormat:@"UPDATE bike_modals SET bikename = '%@' WHERE bikeid = '%zd'", nameFiled.text,self.deviceNum];
            [LVFmdbTool modifyData:updateSql];
            [self backView];
            
        }else {
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
            
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        
    }];
}

-(void) setTap
{
    UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapPage3)];
    [self.view addGestureRecognizer:tapGesturRecognizer];
}
-(void)tapPage3
{
    [nameFiled resignFirstResponder];
}


-(void) setupNameText
{
    nameFiled = [[UITextField alloc]init];
    nameFiled.frame = CGRectMake(10, 20, ScreenWidth - 20, 45);
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    nameFiled.placeholder = bikemodel.bikename;
    [nameFiled setValue:[QFTools colorWithHexString:@"#adaaa8"] forKeyPath:@"_placeholderLabel.textColor"];
    nameFiled.layer.cornerRadius = 5;
    nameFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
    nameFiled.textColor = [UIColor blackColor];
    nameFiled.backgroundColor = [UIColor whiteColor];
    nameFiled.layer.borderColor = [UIColor colorWithRed:14/255.0 green:174/255.0 blue:131/255.0 alpha:1].CGColor;
    nameFiled.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    nameFiled.leftViewMode = UITextFieldViewModeAlways;
    [[UITextField appearance] setTintColor:[QFTools colorWithHexString:MainColor]];
    [self.view addSubview:nameFiled];
    [nameFiled becomeFirstResponder];
    
    UILabel *promte = [[UILabel alloc] initWithFrame:CGRectMake(nameFiled.x, CGRectGetMaxY(nameFiled.frame)+5, nameFiled.width, 20)];
    promte.textColor = [QFTools colorWithHexString:@"#999999"];
    promte.font = [UIFont systemFontOfSize:14];
    promte.text = @"限4-12字符,每个汉字为两个字符";
    [self.view addSubview:promte];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
-(void)backView{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)dealloc{
    NSLog(@"%s dealloc",object_getClassName(self));
}

@end
