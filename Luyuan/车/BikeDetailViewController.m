//
//  BikeDetailViewController.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/10/25.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "BikeDetailViewController.h"


@interface BikeDetailViewController ()

@end

@implementation BikeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImage *image = [UIImage imageNamed:@"setting"];//优化方法
    self.view.layer.contents = (id) image.CGImage;
    
    [self configureNavgationItemTitle:@"车辆详情"];
    
    __weak BikeDetailViewController *weakself = self;
    
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        
        
        [weakself.navigationController popViewControllerAnimated:YES];
        
    }];
    
    [self setupView];
    
}

-(void)setupView{

    NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM info_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *modals = [LVFmdbTool queryModelData:fuzzyQuerySql];
    ModelInfo *modelinfo = modals.firstObject;
    
    
    NSString *brandQuerySql = [NSString stringWithFormat:@"SELECT * FROM brand_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *brandmodals = [LVFmdbTool queryBrandData:brandQuerySql];
    BrandModel *brandmodel = brandmodals.firstObject;
    
    UIImageView *bikeLogo = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 70, 30)];
    bikeLogo.layer.masksToBounds = YES;
    bikeLogo.image = [UIImage imageNamed:@"logo"];
    [self.view addSubview:bikeLogo];
    if (brandmodals.count != 0) {
        NSURL *logurl=[NSURL URLWithString:brandmodel.logo];
        //图片缓存的基本代码，就是这么简单
        [bikeLogo sd_setImageWithURL:logurl];
    }
    
    UIImageView *bikeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - ScreenHeight * .1, 40, ScreenHeight * .2, ScreenHeight * .2)];
    
    NSString *nomalname = [QFTools getdata:@"defaultimage"];
    NSURL *imageurl=[NSURL URLWithString:nomalname];
    [bikeIcon sd_setImageWithURL:imageurl];
    [self.view addSubview:bikeIcon];
    if (modals.count != 0) {
        NSURL *logurl=[NSURL URLWithString:modelinfo.pictureb];
        //图片缓存的基本代码，就是这么简单
        [bikeIcon sd_setImageWithURL:logurl];
    }
    
    UIView *model = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bikeIcon.frame)+20, ScreenWidth, 40)];
    model.backgroundColor =[UIColor colorWithWhite:1 alpha:0.05];
    [self.view addSubview:model];
    
    UIImageView *modelIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
    modelIcon.image = [UIImage imageNamed:@"icon_p1"];
    [model addSubview:modelIcon];
    
    UILabel *modelLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(modelIcon.frame), 10, 80, 20)];
    modelLable.text = @"品牌型号";
    modelLable.textColor = [UIColor whiteColor];
    modelLable.textAlignment = NSTextAlignmentCenter;
    modelLable.font = [UIFont systemFontOfSize:13];
    [model addSubview:modelLable];
    
    UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 100, 10, 80, 20)];
    typeLabel.text = [NSString stringWithFormat:@"%@",brandmodel.brandname];
    typeLabel.font = [UIFont systemFontOfSize:13];
    NSLog(@"%@",brandmodel.brandname);
    typeLabel.textColor = [UIColor whiteColor];
    typeLabel.textAlignment = NSTextAlignmentRight;
    [model addSubview:typeLabel];
    
    
    UIView *bindingNumber = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(model.frame)+10, ScreenWidth, 40)];
    bindingNumber.backgroundColor =[UIColor colorWithWhite:1 alpha:0.05];
    [self.view addSubview:bindingNumber];
    
    
    UIImageView *bindingNumberIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
    //bindingNumberIcon.backgroundColor = [UIColor blackColor];
    bindingNumberIcon.image = [UIImage imageNamed:@"icon_p2"];
    [bindingNumber addSubview:bindingNumberIcon];
    
    UILabel *bindingNumberLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(bindingNumberIcon.frame), 10, 80, 20)];
    bindingNumberLable.text = @"车辆型号";
    bindingNumberLable.textColor = [UIColor whiteColor];
    bindingNumberLable.textAlignment = NSTextAlignmentCenter;
    bindingNumberLable.font = [UIFont systemFontOfSize:13];
    [bindingNumber addSubview:bindingNumberLable];
    
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 100, 10, 80, 20)];
    numberLabel.text =  modelinfo.modelname;
    numberLabel.font = [UIFont systemFontOfSize:13];
    numberLabel.textAlignment = NSTextAlignmentRight;
    numberLabel.textColor = [UIColor whiteColor];
    [bindingNumber addSubview:numberLabel];
    
    UIView *accessories = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bindingNumber.frame)+10, ScreenWidth, 40)];
    accessories.backgroundColor =[UIColor colorWithWhite:1 alpha:0.05];
    [self.view addSubview:accessories];
    
    UIImageView *accessoriesIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
    //accessoriesIcon.backgroundColor = [UIColor blackColor];
    accessoriesIcon.image = [UIImage imageNamed:@"icon_p3"];
    [accessories addSubview:accessoriesIcon];
    
    UILabel *accessoriesLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(accessoriesIcon.frame), 10, 80, 20)];
    accessoriesLable.text = @"电池类型";
    accessoriesLable.textColor = [UIColor whiteColor];
    accessoriesLable.textAlignment = NSTextAlignmentCenter;
    accessoriesLable.font = [UIFont systemFontOfSize:13];
    [accessories addSubview:accessoriesLable];
    
    UILabel *battery = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 110, 10, 90, 20)];
    
    if (modelinfo.batttype == 0) {
        battery.text = @"镍氢电池";
    }else if (modelinfo.batttype == 1){
        battery.text = @"锂离子电池";
    }else if (modelinfo.batttype == 2){
        battery.text = @"铅酸电池";
    }
    
    battery.font = [UIFont systemFontOfSize:13];
    battery.textAlignment = NSTextAlignmentRight;
    battery.textColor = [UIColor whiteColor];
    [accessories addSubview:battery];
    
    UIView *Induction = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(accessories.frame)+10, ScreenWidth, 40)];
    Induction.backgroundColor = [UIColor colorWithWhite:1 alpha:0.05];
    [self.view addSubview:Induction];
    
    UIImageView *InductionIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
    //InductionIcon.backgroundColor = [UIColor blackColor];
    InductionIcon.image = [UIImage imageNamed:@"icon_p4"];
    [Induction addSubview:InductionIcon];
    
    UILabel *InductionLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(InductionIcon.frame), 10, 80, 20)];
    InductionLable.text = @"电池电压";
    InductionLable.textColor = [UIColor whiteColor];
    InductionLable.textAlignment = NSTextAlignmentCenter;
    InductionLable.font = [UIFont systemFontOfSize:13];
    [Induction addSubview:InductionLable];
    
    UILabel *Voltage = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 100, 10, 80, 20)];
    Voltage.text =  [NSString stringWithFormat:@"%dV",modelinfo.battvol];
    Voltage.font = [UIFont systemFontOfSize:13];
    Voltage.textAlignment = NSTextAlignmentRight;
    Voltage.textColor = [UIColor whiteColor];
    [Induction addSubview:Voltage];
    
    UIView *distance = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(Induction.frame)+10,ScreenWidth, 40)];
    distance.backgroundColor = [UIColor colorWithWhite:1 alpha:0.05];
    [self.view addSubview:distance];
    
    UIImageView *distanceIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
    //distanceIcon.backgroundColor = [UIColor blackColor];
    distanceIcon.image = [UIImage imageNamed:@"icon_p5"];
    [distance addSubview:distanceIcon];
    
    UILabel *distanceLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(distanceIcon.frame), 10, 80, 20)];
    distanceLable.text = @"车辆轮径";
    distanceLable.textColor = [UIColor whiteColor];
    distanceLable.textAlignment = NSTextAlignmentCenter;
    distanceLable.font = [UIFont systemFontOfSize:13];
    [distance addSubview:distanceLable];
    
    UILabel *size = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 100, 10, 80, 20)];
    size.text =  [NSString stringWithFormat:@"%d英寸",(int)modelinfo.wheelsize];
    size.font = [UIFont systemFontOfSize:13];
    size.textAlignment = NSTextAlignmentRight;
    size.textColor = [UIColor whiteColor];
    [distance addSubview:size];
    

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
