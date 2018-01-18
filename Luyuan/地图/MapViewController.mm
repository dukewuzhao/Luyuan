//
//  MapViewController.m
//  RideHousekeeper
//
//  Created by 同时科技 on 16/6/20.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "MapViewController.h"
#import "BNRoutePlanModel.h"
#import "BNCoreServices.h"
#import <QuartzCore/QuartzCore.h>
#import "PopupView.h"
#import "adressModel.h"
#import "BNaviModel.h"
#import "RouteAnnotation.h"
#import "UIImage+Rotate.h"
#import "OfflineMapViewController.h"
#import "AddressTableViewCell.h"

#define NAME        @"userwords"
#define USERWORDS   @"{\"userword\":[{\"name\":\"计算机词汇\",\"words\":[\"随机存储器\",\"只读存储器\",\"扩充数据输出\",\"局部总线\",\"压缩光盘\",\"十七寸显示器\"]},{\"name\":\"我的词汇\",\"words\":[\"槐花树老街\",\"王小贰\",\"发炎\",\"公事\"]}]}"

#define PUTONGHUA   @"mandarin"
#define YUEYU       @"cantonese"
#define HENANHUA    @"henanese"
#define ENGLISH     @"en_us"
#define CHINESE     @"zh_cn";
#define MYBUNDLE_NAME @ "mapapi.bundle"
#define MYBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: MYBUNDLE_NAME]
#define MYBUNDLE [NSBundle bundleWithPath: MYBUNDLE_PATH]

@interface MapViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,BNNaviUIManagerDelegate,BNNaviRoutePlanDelegate,UITextFieldDelegate,UITextViewDelegate,BMKPoiSearchDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

{
    bool isGeoSearch;
}

@property (nonatomic, strong) BMKMapView *mapView;
@property (nonatomic, weak) UITextField *adressField;
@property (nonatomic, strong) BMKLocationService *locService;

@property (nonatomic, strong) BMKPointAnnotation *annotation;//当前定位的位置
@property (nonatomic, strong) BMKPointAnnotation *annotation2;//导航的终点位置
@property (nonatomic, strong) NSMutableArray *adressAry;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *footWin;

@property (nonatomic, weak) UITableView *tableview;
@property (nonatomic, strong) NSString *currentCity;
@property (nonatomic, strong) NSString *currentName;
@property (nonatomic, strong) NSString* detailLocation;//目的地
@property (nonatomic, weak) UILabel* ditances;//距离
@property (nonatomic, weak) UILabel* destination;//目的地
@property (nonatomic, weak) UIView *headview;
@property (nonatomic, weak) UIButton *mapset;
@property (nonatomic, weak) UIButton *backBtn;
@property (nonatomic, weak) UIButton *locationBtn;
@property (nonatomic, weak) UIButton *enlarge;
@property (nonatomic, weak) UIButton *narrow;
@property (nonatomic, weak) UILabel *customLab;
@property (nonatomic, assign) CGFloat currentAngle;
@property (nonatomic, assign) BOOL isBack;

@end

@implementation MapViewController

- (NSMutableArray *)adressAry {
    if (!_adressAry) {
        _adressAry = [[NSMutableArray alloc] init];
    }
    return _adressAry;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    _geocodesearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _poisearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _routesearch.delegate = self;
    [self.locService startUserLocationService];

    [self initRecognizer];//初始化识别对象
}


-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _geocodesearch.delegate = nil; // 不用时，置nil
    _poisearch.delegate = nil; // 不用时，置nil
    _routesearch.delegate = nil; // 不用时，置nil
    [_iflyRecognizerView cancel]; //取消识别
    [_iflyRecognizerView setDelegate:nil];
    [_iflyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.mapView];
    
     _routesearch = [[BMKRouteSearch alloc]init];
    _geocodesearch = [[BMKGeoCodeSearch alloc]init];
    _poisearch = [[BMKPoiSearch alloc]init];

    [self setupNavbar];
    [self setupHeadView];
    [self setupTable];

    CGFloat posY = self.adressField.frame.origin.y+self.adressField.frame.size.height;
    _popUpView = [[PopupView alloc] initWithFrame:CGRectMake(100, posY, 0, 0) withParentView:self.view];
    self.uploader = [[IFlyDataUploader alloc] init];
    //demo录音文件保存路径
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *cachePath = [paths objectAtIndex:0];
//    _pcmFilePath = [[NSString alloc] initWithFormat:@"%@",[cachePath stringByAppendingPathComponent:@"asr.pcm"]];

    UIButton *locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    locationBtn.frame = CGRectMake(ScreenWidth - 45, ScreenHeight - 50, 35, 35);
    [locationBtn setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    locationBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [locationBtn addTarget:self action:@selector(locationClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:locationBtn];
    self.locationBtn = locationBtn;

    UIButton *enlarge = [UIButton buttonWithType:UIButtonTypeCustom];
    enlarge.frame = CGRectMake(ScreenWidth - 45, ScreenHeight - 150, 35, 35);
    enlarge.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [enlarge addTarget:self action:@selector(enlargeClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:enlarge];
    self.enlarge = enlarge;

    UIButton *narrow = [UIButton buttonWithType:UIButtonTypeCustom];
    narrow.frame = CGRectMake(enlarge.x, CGRectGetMaxY(enlarge.frame), 35, 35);
    narrow.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [narrow addTarget:self action:@selector(narrowClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:narrow];
    self.narrow = narrow;

    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 70)];
    image.image =[UIImage imageNamed:@"fangda"];
    [enlarge addSubview:image];

    //设置白天黑夜模式
    //[BNCoreServices_Strategy setDayNightType:BNDayNight_CFG_Type_Auto];
    //设置停车场
    //[BNCoreServices_Strategy setParkInfo:YES];

    CLLocationCoordinate2D wgs84llCoordinate;
    //assign your coordinate here...

    CLLocationCoordinate2D bd09McCoordinate;
    //the coordinate in bd09MC standard, which can be used to show poi on baidu map
    bd09McCoordinate = [BNCoreServices_Instance convertToBD09MCWithWGS84ll: wgs84llCoordinate];
}

-(void)locationClick{

    [self.mapView setCenterCoordinate:self.annotation.coordinate animated:YES];
    
}

//放大缩小
-(void)enlargeClick{
    
    
    [_mapView setZoomLevel:_mapView.zoomLevel+1];//缩小地图
}

-(void)narrowClick{
    
    [_mapView setZoomLevel:_mapView.zoomLevel-1];//缩小地图
}

- (void)dealloc {
    [self.mapView removeFromSuperview];
    if (_poisearch != nil) {
        _poisearch = nil;
    }
    if (_geocodesearch) {
        _geocodesearch = nil;
    }
    if (_routesearch != nil) {
        _routesearch = nil;
    }
    if (_locService != nil) {
        _locService = nil;
    }
    if (_mapView != nil) {
        _mapView = nil;
    }
}

- (void)setupNavbar{
    
    UIView *barview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width , navHeight)];
    barview.backgroundColor = [QFTools colorWithHexString:MainColor];
    [self.view addSubview:barview];
    
    UILabel *customLab = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 50, 26 +LL_MoreStatusBarHeight, 100, 25)];
    [customLab setTextColor:[UIColor whiteColor]];
    customLab.textAlignment = NSTextAlignmentCenter;
    [customLab setText:@"骑行导航"];
    customLab.font = [UIFont systemFontOfSize:18];
    [barview addSubview:customLab];
    self.customLab = customLab;
    
    UIButton *mapset = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 45, 26+LL_MoreStatusBarHeight, 32, 32)];
    [mapset setImage:[UIImage imageNamed:@"icon_map_set"] forState:UIControlStateNormal];
    [mapset addTarget:self action:@selector(mapsetclick:) forControlEvents:UIControlEventTouchUpInside];
    [barview addSubview:mapset];
    [mapset setAdjustsImageWhenHighlighted:NO];
    self.mapset = mapset;
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 25+LL_MoreStatusBarHeight, 40, 30)];
    [backBtn addTarget:self action:@selector(mapBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [self.view addSubview:backBtn];
    self.backBtn = backBtn;
}

-(void)mapBtnClick{

    if (self.isBack) {
        
        [_mapView removeOverlays:_mapView.overlays];
        
        NSArray *annotations = [NSArray arrayWithArray:_mapView.annotations];
        
        [self.mapView setCenterCoordinate:self.annotation.coordinate animated:YES];
        
        for (BMKPointAnnotation *annotation in annotations) {
            if (![[annotation class] isMemberOfClass:[BMKUserLocation class]]) {
                [_mapView removeAnnotation:annotation];
            }
        }
        [self hidefootView];
        self.isBack = NO;
        
    }else{
    
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//界面绘制
-(void)setupHeadView{
    UIView *headview = [[UIView alloc] init];
    headview.frame = CGRectMake(10, 10 +navHeight, ScreenWidth - 20, 40);
    headview.backgroundColor = [UIColor whiteColor];
    [headview.layer setMasksToBounds:YES];//设置按钮的圆角半径不会被遮挡
    [headview.layer setCornerRadius:5];
    [self.view addSubview:headview];
    self.headview = headview;
    
    UIButton *mapImage = [[UIButton alloc] initWithFrame:CGRectMake( 5 , 5,40,30)];
    [mapImage setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [mapImage setImage:[UIImage imageNamed:@"mike"] forState:UIControlStateNormal];
    [mapImage addTarget:self action:@selector(voiceClick:) forControlEvents:UIControlEventTouchUpInside];
    [headview addSubview:mapImage];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(mapImage.frame) - 2, mapImage.y+ 2, 1, mapImage.height - 4)];
    line.backgroundColor = [QFTools colorWithHexString:@"#d8d7d6"];
    [headview addSubview:line];
    
    UIButton *searchBtn = [[UIButton alloc] init];
    searchBtn.backgroundColor=[UIColor clearColor];
    searchBtn.width = 40;
    searchBtn.height = 40;
    searchBtn.x = headview.width - 40;
    searchBtn.y = 0;
    //[searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [searchBtn setImage:[UIImage imageNamed:@"finding"] forState:UIControlStateNormal];
    searchBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
    [searchBtn.layer setMasksToBounds:YES];//设置按钮的圆角半径不会被遮挡
    [searchBtn.layer setCornerRadius:5];
    [searchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(poisearchClick:) forControlEvents:UIControlEventTouchUpInside];
    //[searchBtn addTarget:self action:@selector(onClickRidingSearch:) forControlEvents:UIControlEventTouchUpInside];
    [headview addSubview:searchBtn];
    
    UITextField *adressField = [self addOneTextFieldWithTitle:@"请输入地址" imageName:nil imageNameWidth:10 Frame:CGRectMake(CGRectGetMaxX(mapImage.frame) + 5 , 5, headview.width - 95, 30)];
    [headview addSubview:adressField];
    //[adressField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingDidEnd];
    self.adressField = adressField;
}


-(void)setupTable{
    
    _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    _backgroundView.clipsToBounds = YES;
    _backgroundView.layer.cornerRadius = 4;
    _backgroundView.hidden = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:_backgroundView];
    
    UITapGestureRecognizer *addbikeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundViewClicked)];
    addbikeTap.delegate = self;
    addbikeTap.numberOfTapsRequired = 1;
    [_backgroundView addGestureRecognizer:addbikeTap];

    _backgroundView.hidden = YES;
    UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, ScreenHeight*.3, ScreenWidth, ScreenHeight*.7)];
    tableview.bounces = NO;
    tableview.delegate = self;
    tableview.dataSource = self;
    [tableview registerClass:[AddressTableViewCell class] forCellReuseIdentifier:@"addressCell"];
    [tableview setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    tableview.backgroundColor = [UIColor whiteColor];
    [_backgroundView addSubview:tableview];
    self.tableview = tableview;
    
    _footWin = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 130, ScreenWidth, 130)];
    _footWin.backgroundColor = [UIColor clearColor];
    _footWin.clipsToBounds = YES;
    _footWin.layer.cornerRadius = 4;
    _footWin.hidden = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:_footWin];
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, ScreenWidth, 80)];
    footView.backgroundColor = [UIColor whiteColor];
    [_footWin addSubview:footView];
    
    UILabel *address = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, ScreenWidth- 20, 15)];
    address.textColor = [UIColor blackColor];
    address.font = [UIFont systemFontOfSize:15];
    [footView addSubview:address];
    self.destination = address;
    
    
    UILabel *distance = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(address.frame) + 10, ScreenWidth - 20, 20)];
    distance.textColor = [QFTools colorWithHexString:@"#CCCCCC"];
    distance.font = [UIFont systemFontOfSize:13];
    [footView addSubview:distance];
    self.ditances= distance;
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(ScreenWidth - 100, 10, 80, 80);
    nextBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
    [nextBtn.layer setCornerRadius:40]; // 切圆角
    [nextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [nextBtn setTitle:@"到这去" forState:UIControlStateNormal];
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(realNavi:) forControlEvents:UIControlEventTouchUpInside];
    [nextBtn setImage:[UIImage imageNamed:@"icon_car_on"] forState:UIControlStateNormal];
    [nextBtn setImageEdgeInsets:UIEdgeInsetsMake(-nextBtn.titleLabel.intrinsicContentSize.height, 0, 0, -nextBtn.titleLabel.intrinsicContentSize.width)];
    [nextBtn setTitleEdgeInsets:UIEdgeInsetsMake(nextBtn.currentImage.size.height + 10, -nextBtn.currentImage.size.width, 0, 0)];
    [_footWin addSubview:nextBtn];
    
}

-(void)backgroundViewClicked{
    
    _backgroundView.hidden = YES;

}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch方法。
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch  {
    // 输出点击的view的类名
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}

//uitebaleview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.adressAry.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    return 75;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"addressCell";
   
    AddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    UILabel *chooseLabel = cell.chooseLabel;
    chooseLabel.text = [self.adressAry[indexPath.row] placename] ;
    
    UILabel *adressLab = cell.adressLab;
    adressLab.text = [NSString stringWithFormat:@"地址:%@",[self.adressAry[indexPath.row] adress]];
    adressLab.numberOfLines = 0;
    
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self onClickRidingSearch:indexPath.row];
    _backgroundView.hidden = YES;
}

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath
{
    
    cell.backgroundColor = [UIColor whiteColor];
    
}

- (void)onClickRidingSearch:(NSInteger)sender {
    
    adressModel *newmodel = self.adressAry[sender];
    self.destination.text = newmodel.placename;
    self.detailLocation = newmodel.adress;
    
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    start.name = self.currentName;
    start.cityName = self.currentCity;
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    end.name = newmodel.placename;
    end.cityName = newmodel.city;
    //NSLog(@"start.name%@ start.cityName%@ end.name%@ end.cityName%@",start.name,start.cityName,end.name,end.cityName);
    self.annotation2.coordinate = newmodel.destinationCoor;
    BMKRidingRoutePlanOption *option = [[BMKRidingRoutePlanOption alloc]init];
    option.from = start;
    option.to = end;
    BOOL flag = [_routesearch ridingSearch:option];
    if (flag)
    {
        NSLog(@"骑行规划检索发送成功");
    }
    else
    {
        NSLog(@"骑行规划检索发送失败");
        [SVProgressHUD showSimpleText:@"规划路线失败"];
    }
}

/**
 *返回骑行搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果，类型为BMKRidingRouteResult
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetRidingRouteResult:(BMKRouteSearch *)searcher result:(BMKRidingRouteResult *)result errorCode:(BMKSearchErrorCode)error {
    NSLog(@"onGetRidingRouteResult error:%d", error);
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKRidingRouteLine* plan = (BMKRidingRouteLine*)[result.routes objectAtIndex:0];
        NSInteger size = [plan.steps count];
        float lance = plan.distance/1000;
         //self.ditances.text =  [NSString stringWithFormat:@"%.1f公里",lance] ;
        self.ditances.text = [NSString stringWithFormat:@"%@ | %@",[NSString stringWithFormat:@"%.1f公里",lance],self.detailLocation];
        
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKRidingStep* transitStep = [plan.steps objectAtIndex:i];
            if (i == 0) {
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注
            } else if(i==size-1){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item]; // 添加起点标注
            }
            //添加annotation节点
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.instruction;
            item.degree = (int)transitStep.direction * 30;
            item.type = 4;
            [_mapView addAnnotation:item];
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKRidingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
        [self showfootView];
        
    }else{
        
        RouteAnnotation* item = [[RouteAnnotation alloc]init];
        item.coordinate = self.annotation2.coordinate;
        item.title = @"终点";
        item.type = 1;
        [_mapView addAnnotation:item]; // 添加起点标注
        [self.mapView setCenterCoordinate:self.annotation2.coordinate animated:YES];
        [self showfootView];
    }
}


-(void)showfootView{
    self.customLab.text = @"骑行路线";
    _footWin.hidden = NO;
    self.isBack = YES;
    self.mapset.hidden = YES;
    self.headview.hidden = YES;
    self.locationBtn.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
    self.locationBtn.transform =CGAffineTransformMakeTranslation(0, -60);
    self.enlarge.transform =CGAffineTransformMakeTranslation(0, -60);
    self.narrow.transform =CGAffineTransformMakeTranslation(0, -60);
    }];
}

-(void)hidefootView{
    self.customLab.text = @"骑行导航";
    _footWin.hidden = YES;
    self.mapset.hidden = NO;
    self.headview.hidden = NO;
    self.locationBtn.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.locationBtn.transform =CGAffineTransformMakeTranslation(0, 0);
        self.enlarge.transform =CGAffineTransformMakeTranslation(0, 0);
        self.narrow.transform =CGAffineTransformMakeTranslation(0, 0);
        
    }];
    
}

- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate{
    
    [self.view endEditing:YES];
}

- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor alloc] initWithRed:32/255.0 green:200/255.0 blue:172/255.0 alpha:1];
        polylineView.strokeColor = [[UIColor alloc] initWithRed:32/255.0 green:200/255.0 blue:172/255.0 alpha:0.7];
        polylineView.lineWidth = 5.0;
        polylineView.lineDash = NO;
        polylineView.tileTexture = YES;
        polylineView.keepScale = YES;
        return polylineView;
    }
    return nil;
}

#pragma mark - 私有

//根据polyline设置地图范围
- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [_mapView setVisibleMapRect:rect];
    _mapView.zoomLevel = _mapView.zoomLevel - 0.3;
}



//进入离线地图页面
-(void)mapsetclick:(UIButton *)btn{

    OfflineMapViewController *offVc = [OfflineMapViewController new];
    [self.navigationController pushViewController:offVc animated:YES];
}


//根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
//    NSString *AnnotationViewID = @"annotationViewID";
//    //根据指定标识查找一个可被复用的标注View，一般在delegate中使用，用此函数来代替新申请一个View
//    BMKAnnotationView *annotationView = [view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
//    if (annotationView == nil) {
//        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
//        ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorRed;
//        ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
//    }
//    
//    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
//    annotationView.annotation = annotation;
//    annotationView.canShowCallout = YES;
//    return annotationView;
    if (![annotation isKindOfClass:[RouteAnnotation class]]) return nil;
    return [self getRouteAnnotationView:_mapView viewForAnnotation:(RouteAnnotation *)annotation];
    
    
}

#pragma mark 获取路线的标注，显示到地图
- (BMKAnnotationView*)getRouteAnnotationView:(BMKMapView *)mapview viewForAnnotation:(RouteAnnotation*)routeAnnotation{
    
    BMKAnnotationView *view = nil;
    switch (routeAnnotation.type) {
        case 0:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"start_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc] initWithAnnotation:routeAnnotation reuseIdentifier:@"start_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_start"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = true;
            }
            view.annotation = routeAnnotation;
        }
            break;
        case 1:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"end_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc] initWithAnnotation:routeAnnotation reuseIdentifier:@"end_node"];
                view.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_nav_end"]];
                view.centerOffset = CGPointMake(0, -(view.frame.size.height * 0.5));
                view.canShowCallout = true;
            }
            view.annotation =routeAnnotation;
        }
            break;
        case 4:
        {
            view = [mapview dequeueReusableAnnotationViewWithIdentifier:@"route_node"];
            if (view == nil) {
                view = [[BMKAnnotationView alloc] initWithAnnotation:routeAnnotation reuseIdentifier:@"route_node"];
                view.canShowCallout = true;
            } else {
                [view setNeedsDisplay];
            }
            UIImage *image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/icon_direction"]];
            view.image = [image imageRotatedByDegrees:routeAnnotation.degree];
            view.annotation = routeAnnotation;
        }
            break;
        default:
            break;
    }
    return view;
}

- (NSString*)getMyBundlePath1:(NSString *)filename {
    
    NSBundle * libBundle = MYBUNDLE ;
    if ( libBundle && filename ) {
        NSString * s=[[libBundle resourcePath ] stringByAppendingPathComponent:filename];
        return s;
    }
    return nil ;
}

//进行检索按钮
-(void)poisearchClick:(UIButton *)btn{
    
    [self.adressField resignFirstResponder];
    
    if (![AppDelegate currentAppDelegate].available) {
        [SVProgressHUD showSimpleText:@"网络未连接"];
        
        return;
    }
    
    if ([QFTools isBlankString:self.adressField.text] ) {
        [SVProgressHUD showSimpleText:@"请输入目的地"];
        return;
    }
    
    curPage = 0;
    BMKCitySearchOption *citySearchOption = [[BMKCitySearchOption alloc]init];
    citySearchOption.pageIndex = curPage;
    citySearchOption.pageCapacity = 30;
    citySearchOption.city= self.adressField.text;
    citySearchOption.keyword = self.adressField.text;
    BOOL flag = [_poisearch poiSearchInCity:citySearchOption];
    if(flag)
    {
        NSLog(@"城市内检索发送成功");
        
    }
    else
    {
        
        NSLog(@"城市内检索发送失败");
    }
    
}

#pragma mark -
#pragma mark implement BMKSearchDelegate
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult*)result errorCode:(BMKSearchErrorCode)error
{
    [self.adressAry removeAllObjects];
    
    if (error == BMK_SEARCH_NO_ERROR) {
        
        if (result.poiInfoList.count == 0) {
            
            [SVProgressHUD showSimpleText:@"地址不匹配，请重新输入"];
            
        }else{
        
            _backgroundView.hidden = NO;
        }
        
        for (int i = 0; i < result.poiInfoList.count; i++) {
            BMKPoiInfo* poi = [result.poiInfoList objectAtIndex:i];
            adressModel* item = [[adressModel alloc]init];
            item.placename = poi.name;
            item.adress = poi.address;
            item.city = poi.city;
            item.destinationCoor = poi.pt;
            [self.adressAry addObject:item];
        }
        
    } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        NSLog(@"起始点有歧义");
    } else {
        // 各种情况的判断。。。
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableview reloadData];
    });
}


#pragma mark - 添加输入框方法
- (UITextField *)addOneTextFieldWithTitle:(NSString *)title imageName:(NSString *)imageName imageNameWidth:(CGFloat)width Frame:(CGRect)rect
{
    UITextField *field = [[UITextField alloc] init];
    field.frame = rect;
    field.backgroundColor = [UIColor whiteColor];
    //  field.borderStyle = UITextBorderStyleRoundedRect;
    field.returnKeyType = UIReturnKeyDone;
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //    [usernameField becomeFirstResponder];
    field.delegate = self;
    field.textColor = [QFTools colorWithHexString:@"#333333"];
    // 设置内容居中
    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field.leftViewMode = UITextFieldViewModeAlways;
    // 设置清除按钮
    // field.clearButtonMode = UITextFieldViewModeWhileEditing;
    // 占位符
    field.placeholder = title;
    return field;
}

- (BMKMapView *)mapView
{
    if (!_mapView) {
        
//        dispatch_queue_t queue = dispatch_queue_create("test", DISPATCH_QUEUE_CONCURRENT);
//        dispatch_async(queue, ^{
//
//        });
        
        _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _mapView.mapType = BMKMapTypeStandard;
        _mapView.showMapScaleBar = YES;
        _mapView.mapScaleBarPosition = CGPointMake(10,ScreenHeight - 50);
        _mapView.showsUserLocation = NO;//先关闭显示的定位图层
        _mapView.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态
        _mapView.showsUserLocation = YES;//显示定位图层
        _mapView.zoomLevel = 17;//地图显示比例
        _mapView.rotateEnabled = NO; //设置是否可以旋转
        [BMKLocationService setLocationDistanceFilter:100];//指定最小距离更新(米)
    }
    return _mapView;
}


- (BMKLocationService *)locService
{
    if (!_locService) {
        _locService = [[BMKLocationService alloc] init];
        _locService.delegate = self;
        _locService.distanceFilter = 100;
        _locService.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;//定位精度
    }
    return _locService;
}

- (void)customLocationAccuracyCircle {

    BMKLocationViewDisplayParam* testParam = [[BMKLocationViewDisplayParam alloc] init];
    testParam.isRotateAngleValid = false;// 跟随态旋转角度是否生效
    testParam.isAccuracyCircleShow = false;// 精度圈是否显示
//    testParam.accuracyCircleStrokeColor = [UIColor clearColor];
//    testParam.accuracyCircleFillColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.3];
    //testParam.locationViewImgName = @"icon_compass";// 定位图标名称
    testParam.locationViewOffsetX = 0;//定位图标偏移量(经度)
    testParam.locationViewOffsetY = 0;// 定位图标偏移量(纬度)
    
    [_mapView updateLocationViewWithParam:testParam];
}

/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)willStartLocatingUser
{
    NSLog(@"start locate");
}

- (void)mapView:(BMKMapView*)mapView onDrawMapFrame:(BMKMapStatus*)status{
    [self setLocationViewAngle:_currentAngle];
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    
    //NSLog(@"heading is %@",userLocation.heading);
    [_mapView updateLocationData:userLocation];
    CGFloat angle = userLocation.heading.magneticHeading*M_PI/180;
    _currentAngle= angle;
    [self setLocationViewAngle:_currentAngle];
    
}

#pragma mark设置定位图标的旋转角度
- (void)setLocationViewAngle:(CGFloat)angle{
    BMKAnnotationView*locationView = [_mapView valueForKey:@"_locationView"];
    if(locationView){
        locationView.transform=CGAffineTransformMakeRotation(_currentAngle);
        //不设置位置样式的话 直接设置图片
        //locationView.image = [UIImage imageWithContentsOfFile:[self getMyBundlePath1:@"images/bnavi_icon_location_fixed"]];
    }
}

//地图区域发生变化时调用
- (void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    CLLocationCoordinate2D coor;
    coor.latitude = userLocation.location.coordinate.latitude;
    coor.longitude = userLocation.location.coordinate.longitude;
    if (self.annotation.coordinate.latitude == userLocation.location.coordinate.latitude && self.annotation.coordinate.longitude == userLocation.location.coordinate.longitude) {
        return;
    }
    
    //self.startLoc = userLocation.location;
    
    self.annotation.coordinate = coor;
//    self.annotation.title = @"我在这里";
//    [self.mapView addAnnotation:self.annotation];
//    [self.mapView setCenterCoordinate:coor animated:YES];
    [_mapView updateLocationData:userLocation];
    [self customLocationAccuracyCircle];
    //发起反向地理编码检索
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){coor.latitude, coor.longitude};
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeoCodeSearchOption.reverseGeoPoint = pt;
    [_geocodesearch reverseGeoCode:reverseGeoCodeSearchOption];
}

//接收反向地理编码结果
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:
(BMKReverseGeoCodeResult *)result
errorCode:(BMKSearchErrorCode)error{
  if (error == BMK_SEARCH_NO_ERROR) {
      
      BMKPoiInfo* poi = [result.poiList objectAtIndex:0];
      if ([self.currentName isEqualToString:poi.name]) {
          
          return;
      }
      
      self.currentCity = result.addressDetail.city;
      self.currentName = poi.name;
      //NSLog(@"%@---%@ ---%@  城市:%@,地址：%@",result.address,result.addressDetail.city,result.addressDetail.streetNumber,self.currentCity,self.currentName);
  }else {
      NSLog(@"抱歉，未找到结果");
  }
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)didStopLocatingUser
{
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
}

- (BMKPointAnnotation *)annotation
{
    if (!_annotation) {
        _annotation = [[BMKPointAnnotation alloc] init];
    }
    return _annotation;
}

- (BMKPointAnnotation *)annotation2
{
    if (!_annotation2) {
        _annotation2 = [[BMKPointAnnotation alloc] init];
    }
    return _annotation2;
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

//////////////////语音/////////////////////////

-(void)voiceClick:(UIButton *)btn{
    if(_iflyRecognizerView == nil)
    {
        [self initRecognizer ];
    }
    
    [self.adressField setText:@""];
    [self.adressField resignFirstResponder];
    
    //设置音频来源为麦克风
    [_iflyRecognizerView setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    
    //设置听写结果格式为json
    [_iflyRecognizerView setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
    
    //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
    [_iflyRecognizerView setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    
    [_iflyRecognizerView start];
}

/**
 设置识别参数
 ****/
-(void)initRecognizer
{
    //单例模式，UI的实例
    if (_iflyRecognizerView == nil) {
        //UI显示剧中
        _iflyRecognizerView= [[IFlyRecognizerView alloc] initWithCenter:self.view.center];
        
        [_iflyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        
        //设置听写模式
        [_iflyRecognizerView setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        
    }
    _iflyRecognizerView.delegate = self;
    
    if (_iflyRecognizerView != nil) {
        
        //设置最长录音时间
        [_iflyRecognizerView setParameter:@"30000" forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        //设置后端点
        [_iflyRecognizerView setParameter:@"3000" forKey:[IFlySpeechConstant VAD_EOS]];
        //设置前端点
        [_iflyRecognizerView setParameter:@"3000" forKey:[IFlySpeechConstant VAD_BOS]];
        //设置采样率，推荐使用16K
        [_iflyRecognizerView setParameter:@"16000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
        //设置语言
        
        [_iflyRecognizerView setParameter:@"zh_cn" forKey:[IFlySpeechConstant LANGUAGE]];
            //设置方言
            [_iflyRecognizerView setParameter:PUTONGHUA forKey:[IFlySpeechConstant ACCENT]];
        
        //设置是否返回标点符号
        [_iflyRecognizerView setParameter:@"0" forKey:[IFlySpeechConstant ASR_PTT]];
        
    }
    
}

#pragma mark - IFlySpeechRecognizerDelegate

/**
 音量回调函数
 volume 0－30
 ****/
- (void) onVolumeChanged: (int)volume
{
    if (self.isCanceled) {
        [_popUpView removeFromSuperview];
        return;
    }
    
    NSString * vol = [NSString stringWithFormat:@"音量：%d",volume];
    [_popUpView showText: vol];
}



/**
 开始识别回调
 ****/
- (void) onBeginOfSpeech
{
    NSLog(@"%s",__func__);
    [_popUpView showText: @"正在录音"];
}

/**
 停止录音回调
 ****/
- (void) onEndOfSpeech
{
    NSLog(@"%s",__func__);
    [_popUpView showText: @"停止录音"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 听写结束回调（注：无论听写是否正确都会回调）
 error.errorCode =
 0     听写正确
 other 听写出错
 ****/
- (void) onError:(IFlySpeechError *) error
{
    NSLog(@"%s",__func__);
    
       // [_popUpView showText:@"识别结束"];
    [SVProgressHUD showSimpleText:@"识别结束"];
        NSLog(@"%s errorCode:%d",__func__,[error errorCode]);
    
    
}


/**
 无界面，听写结果回调
 results：听写结果
 isLast：表示最后一次
 ****/
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    
//    NSMutableString *resultString = [[NSMutableString alloc] init];
//    NSDictionary *dic = results[0];
//    for (NSString *key in dic) {
//        [resultString appendFormat:@"%@",key];
//    }
//    _result =[NSString stringWithFormat:@"%@%@", self.adressField.text,resultString];
//    NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
//    self.adressField.text = [NSString stringWithFormat:@"%@%@", self.adressField.text,resultFromJson];
//    
//    if (isLast){
//        NSLog(@"听写结果(json)：%@测试",  self.result);
//    }
//    NSLog(@"result=%@",_result);
//    NSLog(@"resultFromJson=%@",resultFromJson);
//    NSLog(@"isLast=%d,_textView.text=%@",isLast,self.adressField.text);
}

/**
 有界面，听写结果回调
 resultArray：听写结果
 isLast：表示最后一次
 ****/
- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];
    
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    
    self.adressField.text = [NSString stringWithFormat:@"%@%@",self.adressField.text,result];
}

/**
 听写取消回调
 ****/
- (void) onCancel
{
    NSLog(@"%s",__func__);
}

-(void) showPopup
{
    [_popUpView showText: @"正在上传..."];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    int a;
    a = (int)self.annotation2.coordinate.longitude;
    
    if (a == 0 ) {
        
        
    }else if (a != 0){
        
        CLLocationCoordinate2D coor;
        coor.latitude = 0.00;
        coor.longitude = 0.00;
        self.annotation2.coordinate = coor;
    }
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
///////////////////导航//////////////////////////

//真实GPS导航
- (void)realNavi:(UIButton*)button
{
    if ([QFTools isBlankString:self.adressField.text] ) {
        [SVProgressHUD showSimpleText:@"请输入目的地"];
        return;
    }
    
    int a;
    a = (int)self.annotation2.coordinate.longitude;
    
    if (a == 0 ) {
        [SVProgressHUD showSimpleText:@"请先查询目的地"];
        return;
    }
    
    if (![self checkServicesInited]) return;
    //_naviType = BN_NaviTypeReal;
    [self startNavi];
}

- (BOOL)checkServicesInited
{
    if(![BNCoreServices_Instance isServicesInited])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"引擎尚未初始化完成，请稍后再试"
                                                           delegate:nil
                                                  cancelButtonTitle:@"我知道了"
                                                  otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
    return YES;
}

- (void)startNavi
{
    NSMutableArray *nodesArray = [[NSMutableArray alloc]initWithCapacity:2];
    //起点 传入的是原始的经纬度坐标，若使用的是百度地图坐标，可以使用BNTools类进行坐标转化
    CLLocation *myLocation = [BNCoreServices_Location getLastLocation];
    BNRoutePlanNode *startNode = [[BNRoutePlanNode alloc] init];
    startNode.pos = [[BNPosition alloc] init];
    startNode.pos.x = myLocation.coordinate.longitude;;
    startNode.pos.y = myLocation.coordinate.latitude;
    startNode.pos.eType = BNCoordinate_OriginalGPS;
    [nodesArray addObject:startNode];
    
    //终点
    BNRoutePlanNode *endNode = [[BNRoutePlanNode alloc] init];
    endNode.pos = [[BNPosition alloc] init];
    endNode.pos.x = self.annotation2.coordinate.longitude;
    endNode.pos.y = self.annotation2.coordinate.latitude;
    endNode.pos.eType = BNCoordinate_BaiduMapSDK;
    [nodesArray addObject:endNode];
    
    //关闭openURL,不想跳转百度地图可以设为YES
    [BNCoreServices_RoutePlan setDisableOpenUrl:YES];
    [BNCoreServices_RoutePlan startNaviRoutePlan:BNRoutePlanMode_Recommend naviNodes:nodesArray time:nil delegete:self userInfo:nil];
    
}

#pragma mark - BNNaviRoutePlanDelegate
//算路成功回调
-(void)routePlanDidFinished:(NSDictionary *)userInfo
{
    NSLog(@"算路成功");
    [self hidefootView];
    //路径规划成功，开始导航
    [BNCoreServices_UI showPage:BNaviUI_NormalNavi delegate:self extParams:nil];
}

//算路失败回调
- (void)routePlanDidFailedWithError:(NSError *)error andUserInfo:(NSDictionary *)userInfo
{
    //BMKLocationViewDisplayParamNSLog(@"%d",[error code]%10000);
    
    switch ([error code]%10000)
    {
        case BNAVI_ROUTEPLAN_ERROR_LOCATIONFAILED:
            NSLog(@"暂时无法获取您的位置,请稍后重试");
            break;
        case BNAVI_ROUTEPLAN_ERROR_ROUTEPLANFAILED:
            NSLog(@"无法发起导航");
            break;
        case BNAVI_ROUTEPLAN_ERROR_LOCATIONSERVICECLOSED:
            NSLog(@"定位服务未开启,请到系统设置中打开定位服务。");
            break;
        case BNAVI_ROUTEPLAN_ERROR_NODESTOONEAR:
            NSLog(@"起终点距离起终点太近");
            break;
        default:
            NSLog(@"算路失败");
            break;
    }
}

//算路取消回调
-(void)routePlanDidUserCanceled:(NSDictionary*)userInfo {
    NSLog(@"算路取消");
}

- (void)exitNaviUI
{
    [BNCoreServices_UI exitPage:EN_BNavi_ExitTopVC animated:YES extraInfo:nil];
}

#pragma mark - BNNaviUIManagerDelegate

//退出导航页面回调
- (void)onExitPage:(BNaviUIType)pageType  extraInfo:(NSDictionary*)extraInfo
{
    if (pageType == BNaviUI_NormalNavi)
    {
        NSLog(@"退出导航");
        [self mapBtnClick];
        self.isBack = NO;
    }
    else if (pageType == BNaviUI_Declaration)
    {
        NSLog(@"退出导航声明页面");
    }
}

-(id)naviPresentedViewController {
    return self;
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
