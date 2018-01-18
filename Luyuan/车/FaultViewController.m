//
//  FaultViewController.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/9/3.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "FaultViewController.h"
#import "YYImage.h"
@interface FaultViewController ()
{
    NSMutableArray *faultArray;
}
@property(nonatomic,weak) NSTimer *animation;
@property(nonatomic,assign) NSInteger tagnum;
@property(nonatomic,weak) UIView *headview;
@property(nonatomic,weak) UIView *electric;
@property(nonatomic,weak) UIView *rotation;
@property(nonatomic,weak) UIView *controller;
@property(nonatomic,weak) UIView *defect;
@property(nonatomic,weak) UIView *undervoltage;
@property(nonatomic,weak) UIButton *experien;
@property(nonatomic,strong) YYAnimatedImageView *imageView;

@property(nonatomic,weak) UILabel *checkLab;
@end

@implementation FaultViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidLoad {
    
    [self configureNavgationItemTitle:@"故障检测"];
    WS(weakSelf);
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    }];
    [super viewDidLoad];
    UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight *.45 - navHeight)];
    headview.backgroundColor = [QFTools colorWithHexString:MainColor];
    [self.view addSubview:headview];
    self.headview = headview;
    
    faultArray = [NSMutableArray arrayWithObjects:@"电机霍尔",@"转把",@"控制器",@"电机缺陷",@"电池欠压",nil];
    
    [NSNOTIC_CENTER addObserver:self selector:@selector(queryFaultSuccess:) name:KNotification_QueryData object:nil];
    [self setupView];
    
    UIImageView *defaultImage = [[UIImageView alloc] init];
    defaultImage.frame = _imageView.frame;
    defaultImage.image = [UIImage imageNamed:@"icon_faultview_checked"];
    [self.view addSubview:defaultImage];
    
    self.tagnum = 1500;
}

-(void)faultBtnClick{

    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)setupView{
    
    YYImage *image = [YYImage imageNamed:@"testing.gif"];
    _imageView = [[YYAnimatedImageView alloc] initWithImage:image];
    _imageView.autoPlayAnimatedImage = NO;
    
    if(ScreenHeight <= 568){
    
        _imageView.frame = CGRectMake(ScreenWidth*.31,20,ScreenWidth*.38,ScreenWidth*.38);
        
    }else{
    
        _imageView.frame = CGRectMake(ScreenWidth*.27,20,ScreenWidth*.46,ScreenWidth*.46);
    
    }
    [self.headview addSubview:_imageView];
    _imageView.hidden = YES;
    
    UILabel *checkLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_imageView.frame) + 10, ScreenWidth, 22)];
    checkLab.textColor = [UIColor whiteColor];
    checkLab.textAlignment = NSTextAlignmentCenter;
    checkLab.font = [UIFont systemFontOfSize:14];
    checkLab.textColor = [UIColor whiteColor];
    [self.headview addSubview:checkLab];
    self.checkLab = checkLab;
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headview.frame), ScreenWidth, ScreenHeight*.55)];
    [self .view addSubview:footView];
    
    UIView *electric = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    electric.backgroundColor =[UIColor colorWithWhite:1 alpha:0.05];
    electric.tag = 1500;
    [footView addSubview:electric];
    self.electric = electric;
    
    UIImageView *electricIcon = [[UIImageView alloc] initWithFrame:CGRectMake(22, 10, 25, 25)];
    [electric addSubview:electricIcon];
    
    UILabel *electricLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(electricIcon.frame)+22, 10, 80, 22)];
    electricLable.text = @"电机霍尔";
    electricLable.textColor = [UIColor blackColor];
    electricLable.textAlignment = NSTextAlignmentLeft;
    electricLable.font = [UIFont systemFontOfSize:16];
    [electric addSubview:electricLable];
    
    UILabel *eletricState = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 136, 10, 114, 22)];
    eletricState.text = @"健康";
    eletricState.textAlignment = NSTextAlignmentRight;
    eletricState.font = [UIFont systemFontOfSize:14];
    [electric addSubview:eletricState];
    
    if (self.motorfaultNum == 1) {
        electricIcon.image = [UIImage imageNamed:@"electric1"];
        eletricState.textColor = [QFTools colorWithHexString:@"#fdc12b"];
        eletricState.text = @"故障";
    }else if (self.motorfaultNum == 0){
    
        electricIcon.image = [UIImage imageNamed:@"electric"];
        eletricState.text = @"健康";
        eletricState.textColor = [QFTools colorWithHexString:MainColor];
    
    }
    
    UIView *defect = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(electric.frame)+5, ScreenWidth, 44)];
    defect.tag = 1501;
    defect.backgroundColor =[UIColor colorWithWhite:1 alpha:0.05];
    [footView addSubview:defect];
    self.defect = defect;
    
    UIImageView *defectIcon = [[UIImageView alloc] initWithFrame:CGRectMake(22, 10, 25, 25)];
    defectIcon.image = [UIImage imageNamed:@"defect"];
    [defect addSubview:defectIcon];
    
    UILabel *defectLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(defectIcon.frame)+22, 10, 80, 22)];
    defectLab.text = @"电机缺陷";
    defectLab.textColor = [UIColor blackColor];
    defectLab.textAlignment = NSTextAlignmentLeft;
    defectLab.font = [UIFont systemFontOfSize:16];
    [defect addSubview:defectLab];
    
    UILabel *defectState = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 136, 10, 114, 22)];
    defectState.text = @"健康";
    defectState.textAlignment = NSTextAlignmentRight;
    defectState.font = [UIFont systemFontOfSize:14];
    [defect addSubview:defectState];
    
    if (self.motordefectNum == 1) {
        defectIcon.image = [UIImage imageNamed:@"defect1"];
        defectState.textColor = [QFTools colorWithHexString:@"#fdc12b"];
        defectState.text = @"故障";
    }else if (self.motordefectNum == 0){
        
        defectIcon.image = [UIImage imageNamed:@"defect"];
        defectState.text = @"健康";
        defectState.textColor = [QFTools colorWithHexString:MainColor];
    }
    
    UIView *rotation = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(defect.frame)+5, ScreenWidth, 44)];
    rotation.backgroundColor =[UIColor colorWithWhite:1 alpha:0.05];
    rotation.tag = 1502;
    [footView addSubview:rotation];
    self.rotation = rotation;
    
    UIImageView *rotationIcon = [[UIImageView alloc] initWithFrame:CGRectMake(22, 10, 25, 25)];
    //rotationIcon.image = [UIImage imageNamed:@"rotation"];
    [rotation addSubview:rotationIcon];
    
    UILabel *rotationLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(rotationIcon.frame)+22, 10, 80, 22)];
    rotationLab.text = @"转把";
    rotationLab.textColor = [UIColor blackColor];
    rotationLab.textAlignment = NSTextAlignmentLeft;
    rotationLab.font = [UIFont systemFontOfSize:16];
    [rotation addSubview:rotationLab];
    
    UILabel *rotationState = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 136, 10, 114, 22)];
    //typeLabel.text = [NSString stringWithFormat:@"%@-%@",brandmodel.brandname,modelinfo.modelname];
    rotationState.text = @"健康";
    
    rotationState.textAlignment = NSTextAlignmentRight;
    rotationState.font = [UIFont systemFontOfSize:14];
    [rotation addSubview:rotationState];
    //
    if (self.rotationfaultNum == 1) {
        rotationIcon.image = [UIImage imageNamed:@"rotation1"];
        rotationState.textColor = [QFTools colorWithHexString:@"#fdc12b"];
        rotationState.text = @"故障";
    }else if (self.rotationfaultNum == 0){
        
        rotationIcon.image = [UIImage imageNamed:@"rotation"];
        rotationState.text = @"健康";
        rotationState.textColor = [QFTools colorWithHexString:MainColor];
    }
    
    UIView *controller = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(rotation.frame)+5, ScreenWidth, 44)];
    controller.backgroundColor =[UIColor colorWithWhite:1 alpha:0.05];
    controller.tag = 1503;
    [footView addSubview:controller];
    self.controller = controller;
    
    UIImageView *controllerIcon = [[UIImageView alloc] initWithFrame:CGRectMake(22, 10, 25, 25)];
    //controllerIcon.image = [UIImage imageNamed:@"controller"];
    [controller addSubview:controllerIcon];
    
    UILabel *controllerIconLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(electricIcon.frame)+22, 10, 80, 22)];
    controllerIconLab.text = @"控制器";
    controllerIconLab.textColor = [UIColor blackColor];
    controllerIconLab.textAlignment = NSTextAlignmentLeft;
    controllerIconLab.font = [UIFont systemFontOfSize:16];
    [controller addSubview:controllerIconLab];
    
    UILabel *controllerState = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 136, 10, 114, 22)];
    //typeLabel.text = [NSString stringWithFormat:@"%@-%@",brandmodel.brandname,modelinfo.modelname];
    controllerState.text = @"健康";
    controllerState.textAlignment = NSTextAlignmentRight;
    controllerState.font = [UIFont systemFontOfSize:14];
    [controller addSubview:controllerState];

    if (self.controllerfaultNum == 1) {
        controllerIcon.image = [UIImage imageNamed:@"controller1"];
        controllerState.textColor = [QFTools colorWithHexString:@"#fdc12b"];
        controllerState.text = @"故障";
    }else if (self.controllerfaultNum == 0){
        
        controllerIcon.image = [UIImage imageNamed:@"controller"];
        controllerState.text = @"健康";
        controllerState.textColor = [QFTools colorWithHexString:MainColor];
    }
    
    UIView *undervoltage = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(controller.frame)+5, ScreenWidth, 44)];
    undervoltage.tag = 1504;
    undervoltage.backgroundColor =[UIColor colorWithWhite:1 alpha:0.05];
    [footView addSubview:undervoltage];
    self.undervoltage = undervoltage;
    
    UIImageView *undervoltageIcon = [[UIImageView alloc] initWithFrame:CGRectMake(22, 10, 25, 25)];
    //undervoltageIcon.image = [UIImage imageNamed:@"undervoltage"];
    [undervoltage addSubview:undervoltageIcon];
    
    UILabel *undervoltageLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(defectIcon.frame)+22, 10, 80, 22)];
    undervoltageLab.text = @"电池欠压";
    undervoltageLab.textColor = [UIColor blackColor];
    undervoltageLab.textAlignment = NSTextAlignmentLeft;
    undervoltageLab.font = [UIFont systemFontOfSize:16];
    [undervoltage addSubview:undervoltageLab];
    
    UILabel *undervoltageState = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 136, 10, 114, 22)];
    //typeLabel.text = [NSString stringWithFormat:@"%@-%@",brandmodel.brandname,modelinfo.modelname];
    undervoltageState.text = @"健康";
    
    undervoltageState.textAlignment = NSTextAlignmentRight;
    undervoltageState.font = [UIFont systemFontOfSize:14];
    [undervoltage addSubview:undervoltageState];
    
    if (self.lackvoltageNum == 1) {
        undervoltageIcon.image = [UIImage imageNamed:@"undervoltage1"];
        undervoltageState.text = @"欠压";
        undervoltageState.textColor = [QFTools colorWithHexString:@"#fdc12b"];
    }else if (self.lackvoltageNum == 0){
        
        undervoltageIcon.image = [UIImage imageNamed:@"undervoltage"];
        undervoltageState.text = @"健康";
        undervoltageState.textColor = [QFTools colorWithHexString:MainColor];
    }
    
    UIButton *experien = [[UIButton alloc] init];
    if (ScreenWidth <= 568) {
        experien.frame = CGRectMake(ScreenWidth *.32, (footView.height - 284)/2 + CGRectGetMaxY(undervoltage.frame), ScreenWidth *.36,35);
        
    }else{
    
        experien.frame = CGRectMake(ScreenWidth *.32, (footView.height - 284)/2 + CGRectGetMaxY(undervoltage.frame), ScreenWidth *.36,44);
    }
    
    [experien addTarget:self action:@selector(experienClick) forControlEvents:UIControlEventTouchUpInside];
    [experien setTitle:@"立即检测" forState:UIControlStateNormal];
    experien.titleLabel.font = [UIFont systemFontOfSize:16];
    [experien setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [experien.layer setMasksToBounds:YES];//设置按钮的圆角半径不会被遮挡
    [experien.layer setCornerRadius:10];
    experien.backgroundColor = [QFTools colorWithHexString:MainColor];
    [footView addSubview:experien];
    self.experien = experien;
}

-(void)experienClick{
    
    while (self.view.subviews.count) {
        [self.view.subviews.lastObject removeFromSuperview];//清除所有子元素
    }
    
    UIView *headview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight *.45 - navHeight)];
    headview.backgroundColor = [QFTools colorWithHexString:MainColor];
    [self.view addSubview:headview];
    self.headview = headview;
    
    [self setupView];
    _imageView.hidden = NO;
    self.checkLab.text = @"正在扫描电机...";
    self.experien.hidden = YES;
    [_imageView startAnimating];

    self.electric.hidden = YES;
    self.rotation.hidden = YES;
    self.controller.hidden = YES;
    self.defect.hidden = YES;
    self.undervoltage.hidden = YES;
    
    self.animation = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(delayMethod) userInfo:nil repeats:YES];
}

-(void)delayMethod{
    
    if (self.tagnum == 1500) {
        
        [UIView animateWithDuration:0.5 animations:^{
            self.checkLab.text = @"正在扫描电机...";
            self.electric.hidden = NO;
            self.tagnum ++;
        }];
        
    }else if (self.tagnum == 1501){
    
        [UIView animateWithDuration:0.5 animations:^{
            self.checkLab.text = @"正在扫描转把...";
            self.defect.hidden = NO;
            self.tagnum ++;
        }];
        
    }else if (self.tagnum == 1502){
        [UIView animateWithDuration:0.5 animations:^{
            self.checkLab.text = @"正在扫描控制器...";
            self.rotation.hidden = NO;
            self.tagnum ++;
        }];
        
    }else if (self.tagnum == 1503){
        
        [UIView animateWithDuration:0.5 animations:^{
            self.checkLab.text = @"正在扫描电池欠压...";
            self.controller.hidden = NO;
            self.tagnum ++;
        }];
        
    }else if (self.tagnum == 1504){
    
        [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations: ^{
            
            self.undervoltage.hidden = NO;
            
        }completion:^(BOOL finished) {
            UIImageView *defaultImage = [UIImageView new];
            defaultImage.frame = _imageView.frame;
            defaultImage.image = [UIImage imageNamed:@"icon_faultview_checked"];
            [self.self.view addSubview:defaultImage];
            [UIView animateWithDuration:0.2 animations:^{
                //self.gifView.image = [UIImage imageNamed:@"icon_fault_checked"];
                self.experien.hidden = NO;
                self.checkLab.text = @"车辆检测完成";
                self.tagnum = 1500;
                [self.animation invalidate];
                [_imageView stopAnimating];
                _imageView.hidden = YES;
            }];
        }];
    }
}

-(void)queryFaultSuccess:(NSNotification *)data{

    NSString *date = data.userInfo[@"data"];
    if ([[date substringWithRange:NSMakeRange(8, 4)] isEqualToString:@"1001"]) {
    
        NSData *datevalue = [ConverUtil parseHexStringToByteArray:date];
        Byte *byte=(Byte *)[datevalue bytes];
        NSString *bikestate = [QFTools getBinaryByhex:[date substringWithRange:NSMakeRange(28, 2)]];
        
        if (byte[14] == 0) {
            
            self.motorfaultNum = 0;
            self.rotationfaultNum = 0;
            self.controllerfaultNum = 0;
            self.motordefectNum = 0;
            self.brakefaultNum = 0;
            self.lackvoltageNum = 0;
            
        }else{
            
            
            if([[bikestate substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"1"]){
                //电机故障
                self.motorfaultNum = 1;
                
            }else if([[bikestate substringWithRange:NSMakeRange(7, 1)] isEqualToString:@"0"]){
                
                self.motorfaultNum = 0;
            }
            
            if([[bikestate substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"1"]){
                //转把故障
                self.rotationfaultNum = 1;
                
            }else if([[bikestate substringWithRange:NSMakeRange(6, 1)] isEqualToString:@"0"]){
                
                self.rotationfaultNum = 0;
            }
            
            if([[bikestate substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"1"]){
                //控制器故障
                
                self.controllerfaultNum = 1;
            }else if([[bikestate substringWithRange:NSMakeRange(5, 1)] isEqualToString:@"0"]){
                
                self.controllerfaultNum = 0;
            }
            
            if([[bikestate substringWithRange:NSMakeRange(4, 1)] isEqualToString:@"1"]){
                //电池欠压
                
                self.motordefectNum = 1;
            }else if([[bikestate substringWithRange:NSMakeRange(4, 1)] isEqualToString:@"0"]){
                
                self.motordefectNum = 0;
            }
            
            if([[bikestate substringWithRange:NSMakeRange(3, 1)] isEqualToString:@"1"]){
                //刹车故障
                self.brakefaultNum = 1;
                
            }else if([[bikestate substringWithRange:NSMakeRange(3, 1)] isEqualToString:@"0"]){
                
                self.brakefaultNum = 0;
            }
            
            if([[bikestate substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"1"]){
                //电池欠压故障
                self.lackvoltageNum = 1;
                
            }else if([[bikestate substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"0"]){
                
                self.lackvoltageNum = 0;
            }
            
        }
    
    }

}

//- (void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath
//{
//    
//    cell.backgroundColor = [UIColor colorWithRed:30.0/255 green:36.0/255 blue:49.0/255 alpha:1.0];

    //cell动画效果
//    CATransform3D rotation;
//    rotation = CATransform3DMakeRotation( (90.0*M_PI)/180, 0.0, 0.7, 0.4);
//    rotation.m34 = 1.0/ -600;
//    
//    cell.layer.shadowColor = [[UIColor blackColor]CGColor];
//    cell.layer.shadowOffset = CGSizeMake(10, 10);
//    cell.alpha = 0;
//    cell.layer.transform = rotation;
//    cell.layer.anchorPoint = CGPointMake(0, 0.5);
//    
//    [UIView beginAnimations:@"rotation" context:NULL];
//    [UIView setAnimationDuration:0.8];
//    cell.layer.transform = CATransform3DIdentity;
//    cell.alpha = 1;
//    cell.layer.shadowOffset = CGSizeMake(0, 0);
//    [UIView commitAnimations];
    
//}

-(void)dealloc{
    
    //****************//
    [NSNOTIC_CENTER removeObserver:self
                             name:KNotification_QueryData
                           object:nil];

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
