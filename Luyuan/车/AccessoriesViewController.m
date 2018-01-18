//
//  AccessoriesViewController.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/7/14.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "AccessoriesViewController.h"
#import "TwoDimensionalCodecanViewController.h"
#import "BindingkeyViewController.h"
#import "DeviceModifyViewController.h"
#import "CollectionViewCell.h"
#import "DelPopView.h"
#import "CustomFlowLayout.h"

static NSString * const CellReuseIdentify = @"CellReuseIdentify";
static NSString * const SupplementaryViewHeaderIdentify = @"SupplementaryViewHeaderIdentify";
static NSString * const SupplementaryViewFooterIdentify = @"SupplementaryViewFooterIdentify";
@interface AccessoriesViewController ()<UIAlertViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,DelPopViewDelegate,BindingkeyDelegate,TwoDimensionalCodecanDelegate>

{
    NSInteger blekeyNumber;
    NSInteger braceletNumber;
}
@property (weak, nonatomic) UICollectionView *collectionView;
@property (nonatomic, strong) DelPopView *outputView;//右上角弹出按钮

@property(nonatomic,weak) UIImageView *nomalIcon;
@property(nonatomic,weak) UIImageView *nomalIcon2;

@property(nonatomic,assign) BOOL nomalkey;
@property(nonatomic,assign) BOOL nomalkey2;
@property(nonatomic,assign) NSInteger deviceid;
@end

@implementation AccessoriesViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self refrshView];
}

- (void)refrshView{

    NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND seq LIKE '%zd' AND bikeid LIKE '%zd'",3,0,self.deviceNum];
    NSMutableArray *modals = [LVFmdbTool queryPeripheraData:fuzzyQuerySql];
    
    NSString *fuzzyQuerySql2 = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND seq LIKE '%zd' AND bikeid LIKE '%zd'",3,1,self.deviceNum];
    NSMutableArray *modals2 = [LVFmdbTool queryPeripheraData:fuzzyQuerySql2];
    
    NSString *QuerykeySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 2,self.deviceNum];
    NSMutableArray *keymodals = [LVFmdbTool queryPeripheraData:QuerykeySql];
    blekeyNumber = keymodals.count;
    //blekeyNumber = 2;
    NSString *QuerybraceletSql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 5,self.deviceNum];
    NSMutableArray *braceletmodals = [LVFmdbTool queryPeripheraData:QuerybraceletSql];
    braceletNumber = braceletmodals.count;
    if (modals.count >= 1) {
        
        self.nomalkey = YES;
    }else if (modals.count == 0){
        
        self.nomalkey = NO;
    }
    
    if (modals2.count >= 1) {
        
        self.nomalkey2 = YES;
    }else if (modals2.count == 0){
        
        self.nomalkey2 = NO;
    }
    
    [self setupkeyView];
}

-(void)getBleKeyNumber{
    
    NSString *QuerykeySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 2,self.deviceNum];
    NSMutableArray *keymodals = [LVFmdbTool queryPeripheraData:QuerykeySql];
    blekeyNumber = keymodals.count;
    
    NSString *QuerybraceletSql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND bikeid LIKE '%zd'", 5,self.deviceNum];
    NSMutableArray *braceletmodals = [LVFmdbTool queryPeripheraData:QuerybraceletSql];
    braceletNumber = braceletmodals.count;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // something
        [self.collectionView reloadData];
    });
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    [self configureNavgationItemTitle:@"配件管理"];
    
    @weakify(self);
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        @strongify(self);
        [self popview];
    }];
    
    [self refrshView];
    [self setupHeadview];
    [self setupViews];
    
    [[[NSNOTIC_CENTER rac_addObserverForName:RefreshFittingsManagement object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        [self getBleKeyNumber];//刷新列表
    }];
}

-(void)popview{

    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setupHeadview{

    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0,  0, ScreenWidth, ScreenHeight*.315+35)];
    headView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headView];
    
    UILabel *nomal = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 100, 25)];
    nomal.text = @"普通配件";
    nomal.textColor = [UIColor blackColor];
    nomal.font = [UIFont systemFontOfSize:16];
    [headView addSubview:nomal];
    
    UIImageView *nomalIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(nomal.frame) + 10, 65, 65)];
    nomalIcon.layer.masksToBounds = YES;
    nomalIcon.layer.cornerRadius = 32.5;
    if (self.nomalkey) {
        nomalIcon.image = [UIImage imageNamed:@"nomalkey"];
    }else{
        nomalIcon.image = [UIImage imageNamed:@"addkey"];
    }
    nomalIcon.userInteractionEnabled = YES;
    [headView addSubview:nomalIcon];
    self.nomalIcon = nomalIcon;
    
    UITapGestureRecognizer *nomalIconTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(nomalIconClicked:)];
    nomalIconTap.numberOfTapsRequired = 1;
    nomalIcon.tag = 30;
    [nomalIcon addGestureRecognizer:nomalIconTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteFer:)];
    longPress.numberOfTouchesRequired = 1;
    [nomalIcon addGestureRecognizer:longPress];
    
    UILabel *titlename = [[UILabel alloc] initWithFrame:CGRectMake(nomalIcon.centerX - 40, CGRectGetMaxY(nomalIcon.frame) +15, 80, 15)];
    titlename.text = @"普通钥匙1";
    titlename.textColor = [UIColor blackColor];
    titlename.textAlignment = NSTextAlignmentCenter;
    titlename.font = [UIFont systemFontOfSize:15];
    [headView addSubview:titlename];
    
    UIImageView *nomalIcon2 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(nomalIcon.frame) + ScreenWidth*0.186, nomalIcon.y, 65, 65)];
    nomalIcon2.layer.masksToBounds = YES;
    nomalIcon2.layer.cornerRadius = 32.5;
    
    if (self.nomalkey2) {
        nomalIcon2.image = [UIImage imageNamed:@"nomalkey"];
    }else{
        nomalIcon2.image = [UIImage imageNamed:@"addkey"];
    }
    nomalIcon2.userInteractionEnabled = YES;
    [headView addSubview:nomalIcon2];
    self.nomalIcon2 = nomalIcon2;
    
    UITapGestureRecognizer *nomalIcon2Tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(nomalIconClicked:)];
    nomalIcon2Tap.numberOfTapsRequired = 1;
    nomalIcon2.tag = 31;
    [nomalIcon2 addGestureRecognizer:nomalIcon2Tap];
    
    UILongPressGestureRecognizer *longPress2 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteFer:)];
    longPress2.numberOfTouchesRequired = 1;
    [nomalIcon2 addGestureRecognizer:longPress2];
    
    UILabel *titlename2 = [[UILabel alloc] initWithFrame:CGRectMake(nomalIcon2.centerX - 40, CGRectGetMaxY(nomalIcon2.frame) +15, 80, 15)];
    titlename2.text = @"普通钥匙2";
    titlename2.textColor = [UIColor blackColor];
    titlename2.textAlignment = NSTextAlignmentCenter;
    titlename2.font = [UIFont systemFontOfSize:15];
    [headView addSubview:titlename2];
    
    UILabel *prompt = [[UILabel alloc] init];
    prompt.frame = CGRectMake(10, CGRectGetMaxY(titlename2.frame)+25, ScreenWidth - 20, 40);
    prompt.textAlignment = NSTextAlignmentCenter;
    prompt.textColor = [QFTools colorWithHexString:@"#666666"];
    prompt.font = [UIFont systemFontOfSize:13];
    prompt.text = @"注:除车辆自带的钥匙外,还能通过app给车辆配置两把普通钥匙,长按可删除已配置钥匙";
    [prompt setNumberOfLines:0];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:prompt.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:1];//调整行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [prompt.text length])];
    prompt.attributedText = attributedString;
    [prompt setLineBreakMode:NSLineBreakByCharWrapping];
    [headView addSubview:prompt];
    
}

- (void)setupViews{
    CustomFlowLayout *layout = [[CustomFlowLayout alloc] init];
    layout.maximumInteritemSpacing = ScreenWidth * 0.186;
    layout.minimumInteritemSpacing = ScreenWidth * 0.186;
    layout.minimumLineSpacing = 10;
    layout.itemSize = CGSizeMake(65, 120);
    //    layout.headerReferenceSize = CGSizeMake(100, 10);
    //    layout.footerReferenceSize = CGSizeMake(100, 20);
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, ScreenHeight*.315+45, ScreenWidth, ScreenHeight*.485 -navHeight - 45) collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    //注册
    [collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:CellReuseIdentify];
    //[collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:CellReuseIdentify];
    //UICollectionElementKindSectionHeader注册是固定的
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SupplementaryViewHeaderIdentify];
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:SupplementaryViewFooterIdentify];
}

#pragma mark - UICollectionViewDataSource method
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
        if (blekeyNumber+braceletNumber == 0) {
            return 1;
        }else {
            return 2;
        }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentify forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    UIImageView *iconButton = cell.icon;
    
    NSString *QuerykeySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' OR type LIKE '%zd' AND bikeid LIKE '%zd'", 2,5,self.deviceNum];
    NSMutableArray *keymodals = [LVFmdbTool queryPeripheraData:QuerykeySql];

        if (blekeyNumber+braceletNumber == 0) {
            cell.textLabel.text = @"添加配件";
            iconButton.image = [UIImage imageNamed:@"peripheral_add"];
            iconButton.userInteractionEnabled = NO;
        }else if (blekeyNumber+braceletNumber == 1){
            if (indexPath.row == 0) {
                PeripheralModel *permodel = keymodals[indexPath.row];
                if (permodel.type == 2) {
                    cell.textLabel.text = [NSString stringWithFormat:@"感应钥匙%zd", indexPath.row+1];
                    iconButton.image = [UIImage imageNamed:@"bluetooth_have"];
                    iconButton.userInteractionEnabled = YES;
                    iconButton.tag = permodel.deviceid;
                    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteinductionKey:)];
                    longPress.numberOfTouchesRequired = 1;
                    [iconButton addGestureRecognizer:longPress];
                }else if (permodel.type == 5){
                    
                    cell.textLabel.text = [NSString stringWithFormat:@"感应手环%zd", indexPath.row+1];
                    iconButton.image = [UIImage imageNamed:@"bracelet_have"];
                    iconButton.userInteractionEnabled = YES;
                    iconButton.tag = permodel.deviceid;
                    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteinductionKey:)];
                    longPress.numberOfTouchesRequired = 1;
                    [iconButton addGestureRecognizer:longPress];
                }
                
            }else{
                
                cell.textLabel.text = @"添加配件";
                iconButton.image = [UIImage imageNamed:@"peripheral_add"];
                iconButton.userInteractionEnabled = NO;
            }
        }else{
            PeripheralModel *permodel = keymodals[indexPath.row];
            if (indexPath.row == 0) {
                
                if (permodel.type == 2) {
                    cell.textLabel.text = [NSString stringWithFormat:@"感应钥匙%zd", indexPath.row+1];
                    iconButton.image = [UIImage imageNamed:@"bluetooth_have"];
                    iconButton.userInteractionEnabled = YES;
                    iconButton.tag = permodel.deviceid;
                    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteinductionKey:)];
                    longPress.numberOfTouchesRequired = 1;
                    [iconButton addGestureRecognizer:longPress];
                }else if (permodel.type == 5){
                    
                    cell.textLabel.text = [NSString stringWithFormat:@"感应手环%zd", indexPath.row+1];
                    iconButton.image = [UIImage imageNamed:@"bracelet_have"];
                    iconButton.userInteractionEnabled = YES;
                    iconButton.tag = permodel.deviceid;
                    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteinductionKey:)];
                    longPress.numberOfTouchesRequired = 1;
                    [iconButton addGestureRecognizer:longPress];
                }
                
            }else{
                if (permodel.type == 2) {
                    
                    cell.textLabel.text = [NSString stringWithFormat:@"感应钥匙%zd", indexPath.row+1];
                    iconButton.image = [UIImage imageNamed:@"bluetooth_have"];
                    iconButton.userInteractionEnabled = YES;
                    iconButton.tag = permodel.deviceid;
                    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteinductionKey:)];
                    longPress.numberOfTouchesRequired = 1;
                    [iconButton addGestureRecognizer:longPress];
                }else if (permodel.type == 5){
                    
                    cell.textLabel.text = [NSString stringWithFormat:@"感应手环%zd", indexPath.row+1];
                    iconButton.image = [UIImage imageNamed:@"bracelet_have"];
                    iconButton.userInteractionEnabled = YES;
                    iconButton.tag = permodel.deviceid;
                    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteinductionKey:)];
                    longPress.numberOfTouchesRequired = 1;
                    [iconButton addGestureRecognizer:longPress];
                }
            }
        }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if([kind isEqualToString:UICollectionElementKindSectionHeader]){
        UICollectionReusableView *supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SupplementaryViewHeaderIdentify forIndexPath:indexPath];
        supplementaryView.backgroundColor = [UIColor whiteColor];
        
        for (UIView *view in supplementaryView.subviews) { [view removeFromSuperview]; }
        
        UILabel *nomal = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 100, 20)];
        nomal.text = @"智能配件";
        nomal.textColor = [UIColor blackColor];
        nomal.font = [UIFont systemFontOfSize:16];
        [supplementaryView addSubview:nomal];
        
        return supplementaryView;
    }
    else if([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        UICollectionReusableView *supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:SupplementaryViewFooterIdentify forIndexPath:indexPath];
        supplementaryView.backgroundColor = [UIColor whiteColor];
        return supplementaryView;
    }
    return nil;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(15, 15, 5, 15);//分别为上、左、下、右
}

#pragma mark - UICollectionViewDelegate method
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor clearColor];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = nil;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (![[AppDelegate currentAppDelegate].device isConnected]) {
        
        [SVProgressHUD showSimpleText:@"蓝牙未连接"];
        return;
        
    }
    
    NSString *QuerykeySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' OR type LIKE '%zd' AND bikeid LIKE '%zd'", 2,5,self.deviceNum];
    NSMutableArray *keymodals = [LVFmdbTool queryPeripheraData:QuerykeySql];
    
    
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    
    if (bikemodel.ownerflag == 0) {
        
        [SVProgressHUD showSimpleText:@"子用户无此权限"];
        return;
    }
    
    if (blekeyNumber + braceletNumber == 0) {
        
        TwoDimensionalCodecanViewController *QRvC = [TwoDimensionalCodecanViewController new];
        QRvC.delegate = self;
        QRvC.deviceNum = self.deviceNum;
        [self.navigationController pushViewController:QRvC animated:YES];
    }else if (blekeyNumber + braceletNumber == 1){
        if (indexPath.row == 0) {
            PeripheralModel *periperMod = keymodals[indexPath.row];
            DeviceModifyViewController *deviceDetailvc = [DeviceModifyViewController new];
            deviceDetailvc.deviceNum = self.deviceNum;
            deviceDetailvc.deviceId = periperMod.deviceid;
            [self.navigationController pushViewController:deviceDetailvc animated:YES];
        }else{
            
            TwoDimensionalCodecanViewController *QRvC = [TwoDimensionalCodecanViewController new];
            QRvC.delegate = self;
            QRvC.deviceNum = self.deviceNum;
            [self.navigationController pushViewController:QRvC animated:YES];
        }
    }else{
        PeripheralModel *periperMod = keymodals[indexPath.row];
        DeviceModifyViewController *deviceDetailvc = [DeviceModifyViewController new];
        deviceDetailvc.deviceNum = self.deviceNum;
        deviceDetailvc.deviceId = periperMod.deviceid;
        [self.navigationController pushViewController:deviceDetailvc animated:YES];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}
//长按cell，显示编辑菜单 当用户长按cell时
//- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}
//
//- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
//    if ([NSStringFromSelector(action) isEqualToString:@"copy:"]
//        || [NSStringFromSelector(action) isEqualToString:@"paste:"])
//        return YES;
//    return NO;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
//    NSLog(@"复制之后，可以插入一个新的cell");
//}


#pragma mark - UICollectionViewDelegateFlowLayout method
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    return CGSizeMake(100, 20);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeMake(100, 0.1);
}

-(void)TwoDimensionalCodecanBidingKeySuccess{
    
    [self getBleKeyNumber];
}

//- (void)deviceButtonPressed:(id)sender{
//
//    UIView *v = [sender superview];//获取父类view
//    CollectionViewCell *cell = (CollectionViewCell *)[v superview];//获取cell
//    NSIndexPath *indexpath = [self.collectionView indexPathForCell:cell];//获取cell对应的indexpath;
//    NSLog(@"设备图片按钮被点击:%ld        %ld",indexpath.section,indexpath.row);
//}

- (void)deleteinductionKey:(UILongPressGestureRecognizer *)longPress {
    
    if (longPress.state == UIGestureRecognizerStateBegan){
        
        UIView *v = [[longPress view] superview];//获取父类view
        CollectionViewCell *cell = (CollectionViewCell *)[v superview];//获取cell
        NSIndexPath *indexpath = [self.collectionView indexPathForCell:cell];//获取cell对应的indexpath;
        CGRect cellInCollection = [_collectionView convertRect:cell.frame toView:_collectionView];
        CGRect cellInSuperview = [_collectionView convertRect:cellInCollection toView:[self.view superview]];
        CGFloat x = cellInSuperview.origin.x + 10;
        CGFloat y = cellInSuperview.origin.y;
        
        NSInteger selectTag = 32+indexpath.row;;
        _outputView = [[DelPopView alloc] initWithorigin:CGPointMake(x, y) width:45 height:30 tag:selectTag deviceId:[longPress view].tag];
        _outputView.delegate = self;
        _outputView.dismissOperation = ^(){
            _outputView = nil;
            
        };
        [_outputView pop];
    }
}

- (void)didSelectedAtIndexPath:(NSInteger)selectTag :(NSInteger)deviceid{
    self.deviceid = deviceid;
    [AppDelegate currentAppDelegate].device.bindingaccessories = YES;
    if (selectTag == 30) {
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"是否删除该钥匙" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag =9999;
        [alert show];
        
    }else if (selectTag == 31){
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"是否删除该钥匙" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag =10000;
        [alert show];
        
    }else if (selectTag == 32){
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"是否删除该智能配件" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag =10002;
        [alert show];
        
    }else if (selectTag == 33){
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"是否删除该智能配件" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag =10003;
        [alert show];
        
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 9999) {
        if (buttonIndex != [alertView cancelButtonIndex]) {
            
            NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND seq LIKE '%zd' AND bikeid LIKE '%zd'",3,0,self.deviceNum];
            NSMutableArray *modals = [LVFmdbTool queryPeripheraData:fuzzyQuerySql];
            PeripheralModel *permodel = modals.firstObject;
            
            [self delateKey:permodel.deviceid];
            NSString *passwordHEX = [@"A5000017300100" stringByAppendingFormat:@"%@%@%@%@", @"FFFFFFFF", @"FFFFFFFF", @"FFFFFFFF", @"FFFFFFFF"];
            [[AppDelegate currentAppDelegate].device sendHexstring:passwordHEX];
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:[passwordHEX substringWithRange:NSMakeRange(0, 40)]]];
        }else{
            [AppDelegate currentAppDelegate].device.bindingaccessories = NO;
        }
    }else if (alertView.tag == 10000) {
        if (buttonIndex != [alertView cancelButtonIndex]) {
            
            NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE type LIKE '%zd' AND seq LIKE '%zd' AND bikeid LIKE '%zd'",3,1,self.deviceNum];
            NSMutableArray *modals = [LVFmdbTool queryPeripheraData:fuzzyQuerySql];
            PeripheralModel *permodel = modals.firstObject;
            
            [self delateKey:permodel.deviceid];
            NSString *passwordHEX = [@"A5000017300101" stringByAppendingFormat:@"%@%@%@%@", @"FFFFFFFF", @"FFFFFFFF", @"FFFFFFFF", @"FFFFFFFF"];
            [[AppDelegate currentAppDelegate].device sendHexstring:passwordHEX];
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:[passwordHEX substringWithRange:NSMakeRange(0, 40)]]];
        }else{
            [AppDelegate currentAppDelegate].device.bindingaccessories = NO;
        }
    }else if (alertView.tag == 10002) {
        if (buttonIndex != [alertView cancelButtonIndex]) {
            //蓝牙钥匙
            NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE deviceid LIKE '%zd'", self.deviceid];
            NSMutableArray *modals = [LVFmdbTool queryPeripheraData:fuzzyQuerySql];
            PeripheralModel *permodel = modals.firstObject;
            [self delateKey:permodel.deviceid];
            
            NSInteger number = permodel.seq;
            NSString *passwordHEX = [NSString stringWithFormat:@"A500000E3002010%d%@",number,permodel.mac];
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
        }else{
            [AppDelegate currentAppDelegate].device.bindingaccessories = NO;
        }
    }else if (alertView.tag == 10003) {
        if (buttonIndex != [alertView cancelButtonIndex]) {
            //蓝牙钥匙
            NSString *fuzzyQuerySql = [NSString stringWithFormat:@"SELECT * FROM periphera_modals WHERE deviceid LIKE '%zd'", self.deviceid];
            NSMutableArray *modals = [LVFmdbTool queryPeripheraData:fuzzyQuerySql];
            PeripheralModel *permodel = modals.lastObject;
            [self delateKey:permodel.deviceid];
            
            NSInteger number = permodel.seq;
            NSString *passwordHEX = [NSString stringWithFormat:@"A500000E3002010%d%@",number,permodel.mac];
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
        }else{
            [AppDelegate currentAppDelegate].device.bindingaccessories = NO;
        }
    }
}


- (void)delateKey:(NSInteger)deviceid{
    
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *device_id= [NSNumber numberWithInt:(int)deviceid];
    NSNumber *bike_id= [NSNumber numberWithInt:(int)self.deviceNum];
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/deldevice"];
    NSDictionary *parameters = @{@"token": token,@"bike_id":bike_id,@"device_id":device_id};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSString *deleteSql = [NSString stringWithFormat:@"DELETE FROM periphera_modals WHERE deviceid LIKE '%zd' AND bikeid LIKE '%zd'", deviceid,self.deviceNum];
            [LVFmdbTool deletePeripheraData:deleteSql];
            [self refrshView];
            dispatch_async(dispatch_get_main_queue(), ^{
                // something
                [self.collectionView reloadData];
            });
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        
    }];
    [self performSelector:@selector(interval) withObject:nil afterDelay:0.5];
    
}

- (void)interval{

    [AppDelegate currentAppDelegate].device.bindingaccessories = NO;
    
}


- (void)deleteFer:(UILongPressGestureRecognizer *)longPress {
    
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.deviceNum];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    if (bikemodel.ownerflag == 0) {
        
        [SVProgressHUD showSimpleText:@"子用户无此权限"];
        return;
    }
    
    if ([longPress view].tag == 30) {
        
        if (longPress.state == UIGestureRecognizerStateBegan){
            if (self.nomalkey) {
                
                UIView *v = [longPress view];//获取父类view
                CGFloat x = v.x +10;
                CGFloat y = v.y - 15 +navHeight;
                _outputView = [[DelPopView alloc] initWithorigin:CGPointMake(x, y) width:45 height:30 tag:[longPress view].tag deviceId:0];
                _outputView.delegate = self;
                _outputView.dismissOperation = ^(){
                    _outputView = nil;
                };
                [_outputView pop];
                
            }
            
        }
        
    }else if ([longPress view].tag == 31){
    
        if (longPress.state == UIGestureRecognizerStateBegan){
            
            if (self.nomalkey2) {
                
                UIView *v = [longPress view];//获取父类view
                CGFloat x = v.x +10;
                CGFloat y = v.y - 15 +navHeight;
                _outputView = [[DelPopView alloc] initWithorigin:CGPointMake(x, y) width:45 height:30 tag:[longPress view].tag deviceId:0];
                _outputView.delegate = self;
                _outputView.dismissOperation = ^(){
                    _outputView = nil;
                    
                };
                [_outputView pop];
            }
        }
    }
}


- (void)nomalIconClicked:(UITapGestureRecognizer *)gesture{

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

    if ([gesture view].tag == 30) {
        
        if (!self.nomalkey) {
            [AppDelegate currentAppDelegate].device.bindingaccessories = YES;
            NSString *passwordHEX = @"A5000007100301";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            BindingkeyViewController *bindVc = [BindingkeyViewController new];
            bindVc.deviceNum = self.deviceNum;
            bindVc.delegate = self;
            bindVc.seq = 0;
            bindVc.keyversion = bikemodel.keyversion;
            [self.navigationController pushViewController:bindVc animated:YES];
            
        }else{
            [SVProgressHUD showSimpleText:@"钥匙已经绑定"];
        }
        
    }else if ([gesture view].tag == 31){
    
        if (!self.nomalkey2) {
            [AppDelegate currentAppDelegate].device.bindingaccessories = YES;
            NSString *passwordHEX = @"A5000007100301";
            [[AppDelegate currentAppDelegate].device sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
            BindingkeyViewController *bindVc = [BindingkeyViewController new];
            bindVc.delegate = self;
            bindVc.deviceNum = self.deviceNum;
            bindVc.seq = 1;
            bindVc.keyversion = bikemodel.keyversion;
            [self.navigationController pushViewController:bindVc animated:YES];
            
        }else{
            
            [SVProgressHUD showSimpleText:@"钥匙已经绑定"];
            
        }
    }
    
}
#pragma mark - BindingkeyDelegate
-(void)bidingKeyOver{
    
    [self refrshView];
    dispatch_async(dispatch_get_main_queue(), ^{
        // something
        [self.collectionView reloadData];
    });
}

- (void)setupkeyView{

    if (self.nomalkey && self.nomalkey2) {
        self.nomalIcon.image = [UIImage imageNamed:@"nomalkey"];
        self.nomalIcon2.image = [UIImage imageNamed:@"nomalkey"];
    }else if (self.nomalkey){
        
        self.nomalIcon.image = [UIImage imageNamed:@"nomalkey"];
        self.nomalIcon2.image = [UIImage imageNamed:@"addkey"];
        
    }else if (self.nomalkey2){
        self.nomalIcon.image = [UIImage imageNamed:@"addkey"];
        self.nomalIcon2.image = [UIImage imageNamed:@"nomalkey"];
    }else{
    
        self.nomalIcon.image = [UIImage imageNamed:@"addkey"];
        self.nomalIcon2.image = [UIImage imageNamed:@"addkey"];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}

-(void)dealloc{
    
    [AppDelegate currentAppDelegate].device.bindingaccessories = NO;
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
