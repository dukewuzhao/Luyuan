//
//  OfflineMapViewController.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/9/2.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "OfflineMapViewController.h"
#import "OfflineDemoMapViewController.h"
#import "GroupTableViewCell.h"
#import "PlainTableViewCell.h"
#import "switchView.h"

@interface OfflineMapViewController ()<switchViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UITableView* groupTableView;
    UITableView* plainTableView;

}

@property (nonatomic, strong) NSMutableArray * municipalAry;//直辖市
@property (nonatomic, strong) NSMutableArray * provinceAry;//省
@property (nonatomic, strong) NSMutableArray * hongkongMacaoAry;//港澳台
@property (nonatomic, strong) NSMutableArray * wholecountryAry;//全国包

@property (nonatomic, strong) NSMutableArray * downloadingAry;//下载中
@property (nonatomic, strong) NSMutableArray * downAry;//下载完成

@end

@implementation OfflineMapViewController

-(void)viewWillAppear:(BOOL)animated {
    //    [_mapView viewWillAppear];
    _mapView.delegate = self;
    _offlineMap.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _offlineMap.delegate = nil; // 不用时，置nil
}

- (void)dealloc {
    
    for (BMKOLUpdateElement* item in self.downloadingAry) {
        
        if (item.status == 1 || item.status == 2) {
            [_offlineMap pause:item.cityID];
        }
    }
    
    [self mapDownloadStatus];
    
    
    if (_offlineMap != nil) {
        _offlineMap = nil;
    }
    if (_mapView) {
        _mapView = nil;
    }
}

- (NSMutableArray *)municipalAry {
    if (!_municipalAry) {
        _municipalAry = [[NSMutableArray alloc] init];
    }
    return _municipalAry;
}

- (NSMutableArray *)downAry {
    if (!_downAry) {
        _downAry = [[NSMutableArray alloc] init];
    }
    return _downAry;
}

- (NSMutableArray *)downloadingAry {
    if (!_downloadingAry) {
        _downloadingAry = [[NSMutableArray alloc] init];
    }
    return _downloadingAry;
}

- (NSMutableArray *)provinceAry {
    if (!_provinceAry) {
        _provinceAry = [[NSMutableArray alloc] init];
    }
    return _provinceAry;
}

- (NSMutableArray *)hongkongMacaoAry {
    if (!_hongkongMacaoAry) {
        _hongkongMacaoAry = [[NSMutableArray alloc] init];
    }
    return _hongkongMacaoAry;
}

- (NSMutableArray *)wholecountryAry {
    if (!_wholecountryAry) {
        _wholecountryAry = [[NSMutableArray alloc] init];
    }
    return _wholecountryAry;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    [self setupNavbarView];
    //初始化离线地图服务
    _offlineMap = [[BMKOfflineMap alloc]init];
    //获取热门城市
    _arrayHotCityData = [[_offlineMap getHotCityList] mutableCopy];
    //获取支持离线下载城市列表
    _arrayOfflineCityData = [[_offlineMap getOfflineCityList] mutableCopy];
    
    _arraylocalDownLoadMapInfo = [NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]];
    
    for (BMKOLSearchRecord* item in _arrayOfflineCityData) {
        
        if([item.cityName isEqualToString:@"全国基础包"]){
            
            [self.wholecountryAry addObject:item];
            
        }else if ([item.cityName isEqualToString:@"北京市"] || [item.cityName isEqualToString:@"上海市"] || [item.cityName isEqualToString:@"天津市"] || [item.cityName isEqualToString:@"重庆市"] ){
            
           [self.municipalAry addObject:item];
        
        }else if ([item.cityName isEqualToString:@"香港特别行政区"] || [item.cityName isEqualToString:@"澳门特别行政区"] || [item.cityName isEqualToString:@"台湾省"]){
            
            [self.hongkongMacaoAry addObject:item];
        }else{
        
            [self.provinceAry addObject:item];
        }
    }
    
    [self mapDownloadStatus];
    [self setupView];
}

- (void)setupNavbarView{
    
    UIView *barview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width , navHeight)];
    barview.backgroundColor = [QFTools colorWithHexString:MainColor];
    [self.view addSubview:barview];
    
    switchView *segment = [[switchView alloc] init];
    segment.items = @[@"下载管理",@"城市列表"];
    segment.width = 140;
    segment.height = 28;
    segment.x = (ScreenWidth - segment.width) * 0.5;
    segment.y = 28+LL_MoreStatusBarHeight;
    segment.delegate = self;
    [self.view addSubview:segment];
    segment.selectedSegmentIndex = 1;
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 25+LL_MoreStatusBarHeight, 40, 30)];
    [backBtn addTarget:self action:@selector(bkBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [barview addSubview:backBtn];
    
}

-(void)bkBtnClick{

    [self.navigationController popViewControllerAnimated:YES];

}

-(void)mapDownloadStatus{

    [self.downAry removeAllObjects];
    [self.downloadingAry removeAllObjects];
    _arraylocalDownLoadMapInfo = [NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]];
    for (BMKOLUpdateElement* item in _arraylocalDownLoadMapInfo) {
        
        if(item.status == 4){
            [self.downAry addObject:item];
        }else{
            [self.downloadingAry addObject:item];
        }
    }
}


- (void)switchView:(switchView *)switchView DidBtnClick:(UIButton *)btn
{
    if (btn.tag == 20) {
        
        groupTableView.hidden = YES;//城市界面
        plainTableView.hidden = NO;//下载界面
        //获取各城市离线地图更新信息
        [_arraylocalDownLoadMapInfo removeAllObjects];
        _arraylocalDownLoadMapInfo = [NSMutableArray arrayWithArray:[_offlineMap getAllUpdateInfo]];
        [plainTableView reloadData];
        
    }else if(btn.tag == 21){
        
        groupTableView.hidden = NO;
        plainTableView.hidden = YES;
        [groupTableView reloadData];
    }
}


- (void)setupView{
    
    groupTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight - QGJ_TabbarSafeBottomMargin)];
    groupTableView.delegate = self;
    groupTableView.dataSource = self;
    [groupTableView registerClass:[GroupTableViewCell class] forCellReuseIdentifier:@"groupTableViewCell"];
    groupTableView.separatorColor = [UIColor clearColor];
    groupTableView.backgroundColor = [UIColor clearColor];
    [groupTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:groupTableView];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    headView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.02];
    [self.view addSubview:headView];
    groupTableView.tableHeaderView = headView;
    
    UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 120, 20)];
    myLabel.font = [UIFont systemFontOfSize:12];
    myLabel.text = @"按地区查找";
    myLabel.textColor = [QFTools colorWithHexString:@"#bbbbbb"];
    [headView addSubview:myLabel];
    
    plainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, navHeight, ScreenWidth, ScreenHeight - navHeight - QGJ_TabbarSafeBottomMargin)];
    plainTableView.delegate = self;
    plainTableView.dataSource = self;
    [plainTableView registerClass:[PlainTableViewCell class] forCellReuseIdentifier:@"PlainTableViewCell"];
    plainTableView.separatorColor = [UIColor clearColor];
    plainTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:plainTableView];
    [plainTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    plainTableView.hidden = YES;
}


//离线地图delegate，用于获取通知
- (void)onGetOfflineMapState:(int)type withState:(int)state
{
    
    if (type == TYPE_OFFLINE_UPDATE) {
        //id为state的城市正在下载或更新，start后会毁掉此类型
        BMKOLUpdateElement* updateInfo;
        updateInfo = [_offlineMap getUpdateInfo:state];
        dispatch_async(dispatch_get_main_queue(), ^{
            // something
            [plainTableView reloadData];
        });
        if (updateInfo.status == 4) {

            [self mapDownloadStatus];

            dispatch_async(dispatch_get_main_queue(), ^{
                // something
                [groupTableView reloadData];
            });
        }
    }
    if (type == TYPE_OFFLINE_NEWVER) {
        //id为state的state城市有新版本,可调用update接口进行更新
        BMKOLUpdateElement* updateInfo;
        updateInfo = [_offlineMap getUpdateInfo:state];
    }
    if (type == TYPE_OFFLINE_UNZIP) {
        //正在解压第state个离线包，导入时会回调此类型
    }
    if (type == TYPE_OFFLINE_ZIPCNT) {
        //检测到state个离线包，开始导入时会回调此类型
        NSLog(@"检测到%d个离线包",state);
        if(state==0)
        {
            [self showImportMesg:state];
        }
    }
    if (type == TYPE_OFFLINE_ERRZIP) {
        //有state个错误包，导入完成后会回调此类型
        NSLog(@"有%d个离线包导入错误",state);
    }
    if (type == TYPE_OFFLINE_UNZIPFINISH) {
        NSLog(@"成功导入%d个离线包",state);
        //导入成功state个离线包，导入成功后会回调此类型
        [self showImportMesg:state];
    }
    
}
//导入提示框
- (void)showImportMesg:(int)count
{
    NSString* showmeg = [NSString stringWithFormat:@"成功导入离线地图包个数:%d", count];
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"导入离线地图" message:showmeg delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
    [myAlertView show];
}

#pragma mark UITableView delegate
//定义表中有几个section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView== groupTableView)
    {
        return self.provinceAry.count+3;
    }
    else
    {
        return 2;
    }
    
}
//定义每个section中有几行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == groupTableView)
    {
        if(section==0)
        {
            if ([_showDic objectForKey:[NSString stringWithFormat:@"%ld",(long)section]]) {
            return [self.wholecountryAry count];
            }else{
                
                return 0;
            }
        }else if (section == 1){
        
            if ([_showDic objectForKey:[NSString stringWithFormat:@"%ld",(long)section]]) {
                return [self.municipalAry count];
            }else{
                
                return 0;
            }
            
        
        }else if (section == 2){
            if ([_showDic objectForKey:[NSString stringWithFormat:@"%ld",(long)section]]) {
                return [self.hongkongMacaoAry count];
            }else{
                
                return 0;
            }

        }else
        {
            if ([_showDic objectForKey:[NSString stringWithFormat:@"%ld",(long)section]]) {
            
            BMKOLSearchRecord* item = [self.provinceAry objectAtIndex:section-3];
            return [item.childCities count]-1;
            
            }else{
            
                return 0;
            }
        }
        
    }
    else
    {
        if (section == 0) {
            return self.downloadingAry.count;
        }else{
            return self.downAry.count;
        }
        //return [_arraylocalDownLoadMapInfo count];
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if(tableView == groupTableView)
    {
        return 40;
    }
    else
    {
        if (section == 0) {
            if (self.downloadingAry.count > 0) {
                return 20;
            }else{
                return 2;
            }
        }else{
            if (self.downAry.count > 0) {
                return 20;
            }else{
                return 2;
            }
        
        }
        
    }
    
}

//section底部间距
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(tableView == groupTableView)
    {
        return 2;
    }
    else
    {
        return 0;
    }
}
//section底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 2)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
//section头部显示的内容
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if(tableView == groupTableView){
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
    header.backgroundColor = [UIColor whiteColor];
    header.tag = section;
    UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, ScreenWidth -30, 20)];
    NSString *provincName=@"";
    
    if(section==0)
    {
        provincName=@"全国基础包";
        
    }else if(section==1){
    
        provincName=@"直辖市";
        
    }else if(section==2){
        
        provincName=@"港澳台";
        
    }
    else{
        
        BMKOLSearchRecord* item = [self.provinceAry objectAtIndex:section - 3];
        provincName= item.cityName;
    }
    myLabel.text = provincName;
    myLabel.textColor = [UIColor blackColor];
    myLabel.font = [UIFont systemFontOfSize:16];
    [header addSubview:myLabel];
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 30, 17, 17, 6)];
    
    [header addSubview:image];
    
    if ([_showDic objectForKey:[NSString stringWithFormat:@"%ld",(long)section]]) {
    
        image.image = [UIImage imageNamed:@"icon_up"];
    }else{
        image.image = [UIImage imageNamed:@"icon_down"];
    }
        
    UITapGestureRecognizer *singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SingleTap:)];
    singleRecognizer.numberOfTapsRequired = 1; //点击的次数 =1:单击
    [singleRecognizer setNumberOfTouchesRequired:1];//1个手指操作
    [header addGestureRecognizer:singleRecognizer];//添加一个手势监测；
        
        return header;
    }else{
    
        UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
        header.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
        header.tag = section;
        UILabel *myLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 120, 20)];
        NSString *provincName=@"";
        
        if(section==0)
        {
            if (self.downloadingAry.count > 0) {
                
                provincName=@"正在下载";
            }else{
                header.backgroundColor = [UIColor clearColor];
            }
            
        }else if(section==1){
            
            //provincName=@"已下载";
            if (self.downAry.count > 0) {
                
                provincName=@"下载完成";
            }else{
                header.backgroundColor = [UIColor clearColor];
            }
        }
        myLabel.font = [UIFont systemFontOfSize:12];
        myLabel.text = provincName;
        myLabel.textColor = [QFTools colorWithHexString:@"#bbbbbb"];
        [header addSubview:myLabel];
        return header;
        
        
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == groupTableView)
    {
        if ([_showDic objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section]]) {
            
            return 40;
        }else{
        
            return 0;
        }
    }
    else
    {
        if ([_cellshowDic objectForKey:indexPath]) {
        
            return 100;
        }else{
            
            return 60;
        }
    }
}

-(void)setTextColor:(UILabel *)label FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:label.text];
    //设置字号
    [str addAttribute:NSFontAttributeName value:font range:range];
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:range];
    label.attributedText = str;
}


//定义cell样式填充数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d%d", [indexPath section], [indexPath row]];
    static NSString *CellIdentifier = @"groupTableViewCell";
    static NSString *cellName = @"PlainTableViewCell";
    
    if(tableView == groupTableView)
    {
         GroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *down = cell.down;
        UILabel *sizelabel = cell.sizelabel;
        UILabel *cityname = cell.cityLab;
        //热门城市列表
        if(indexPath.section==0)
        {
            if ([_showDic objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section]]) {
            BMKOLSearchRecord* item = [self.wholecountryAry objectAtIndex:indexPath.row];
            BMKOLUpdateElement* updateInfo;
            updateInfo = [_offlineMap getUpdateInfo:item.cityID];
            //转换包大小

            //sizelabel.autoresizingMask =UIViewAutoresizingFlexibleLeftMargin;
            NSString *packSize = [self getDataSizeString:item.size];
            sizelabel.text =  [NSString stringWithFormat:@"%@",packSize];
            
            if (updateInfo.status==1) {
                
                down.image = [UIImage imageNamed:@"stopdown"];
                cityname.text = [NSString stringWithFormat:@"%@(正在下载)", item.cityName];
                NSString *contentStr = cityname.text;
                [self setTextColor:cityname FontNumber:[UIFont systemFontOfSize:13] AndRange:NSMakeRange(contentStr.length - 6, 6) AndColor:[QFTools colorWithHexString:@"#20c8ac"]];
            }else if (updateInfo.status==2) {
                
                down.image = [UIImage imageNamed:@"stopdown"];
                cityname.text = [NSString stringWithFormat:@"%@ (等待下载)", item.cityName];
                NSString *contentStr = cityname.text;
                [self setTextColor:cityname FontNumber:[UIFont systemFontOfSize:13] AndRange:NSMakeRange(contentStr.length - 6, 6) AndColor:[QFTools colorWithHexString:@"#ffffff"]];
            }else if (updateInfo.status==3) {
                
                down.image = [UIImage imageNamed:@"downloading"];
                cityname.text = [NSString stringWithFormat:@"%@ (已暂停)", item.cityName];
                NSString *contentStr = cityname.text;
                [self setTextColor:cityname FontNumber:[UIFont systemFontOfSize:13] AndRange:NSMakeRange(contentStr.length - 5, 5) AndColor:[UIColor redColor]];
            }else if (updateInfo.status==4){
                
                down.image = [UIImage imageNamed:@"stopdown"];
                cityname.text = [NSString stringWithFormat:@"%@ (已下载)", item.cityName];
                NSString *contentStr = cityname.text;
                [self setTextColor:cityname FontNumber:[UIFont systemFontOfSize:13] AndRange:NSMakeRange(contentStr.length - 5, 5) AndColor:[UIColor whiteColor]];
            }else if (updateInfo.status==10){
                
                down.image = [UIImage imageNamed:@"stopdown"];
                cityname.text = [NSString stringWithFormat:@"%@ (离线包导入中)", item.cityName];
                NSString *contentStr = cityname.text;
                [self setTextColor:cityname FontNumber:[UIFont systemFontOfSize:13] AndRange:NSMakeRange(contentStr.length - 8, 8) AndColor:[UIColor whiteColor]];
            }else {
                down.image = [UIImage imageNamed:@"downloading"];
                cell.textLabel.text = [NSString stringWithFormat:@"%@", item.cityName];
            }
            
        }
            
        }else if (indexPath.section == 1){
        if ([_showDic objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section]]) {
            BMKOLSearchRecord* item = [self.municipalAry objectAtIndex:indexPath.row];
            BMKOLUpdateElement* updateInfo;
            updateInfo = [_offlineMap getUpdateInfo:item.cityID];
            //转换包大小
            
            //sizelabel.autoresizingMask =UIViewAutoresizingFlexibleLeftMargin;
            NSString *packSize = [self getDataSizeString:item.size];
            sizelabel.text =  [NSString stringWithFormat:@"%@",packSize];
            if (updateInfo.status==1) {
                down.image = [UIImage imageNamed:@"stopdown"];
                cityname.text = [NSString stringWithFormat:@"%@ (正在下载)", item.cityName];
                NSString *contentStr = cityname.text;
                [self setTextColor:cityname FontNumber:[UIFont systemFontOfSize:13] AndRange:NSMakeRange(contentStr.length - 6, 6) AndColor:[QFTools colorWithHexString:@"#20c8ac"]];
            }else if (updateInfo.status==2) {
                down.image = [UIImage imageNamed:@"stopdown"];
                cityname.text = [NSString stringWithFormat:@"%@ (等待下载)", item.cityName];
                NSString *contentStr = cityname.text;
                [self setTextColor:cityname FontNumber:[UIFont systemFontOfSize:13] AndRange:NSMakeRange(contentStr.length - 6, 6) AndColor:[QFTools colorWithHexString:@"#ffffff"]];
            }else if (updateInfo.status==3) {
                down.image = [UIImage imageNamed:@"downloading"];
                cityname.text = [NSString stringWithFormat:@"%@ (已暂停)", item.cityName];
                
                NSString *contentStr = cityname.text;
                [self setTextColor:cityname FontNumber:[UIFont systemFontOfSize:13] AndRange:NSMakeRange(contentStr.length - 5, 5) AndColor:[UIColor redColor]];
            }else if (updateInfo.status==4){
                down.image = [UIImage imageNamed:@"stopdown"];
                cityname.text = [NSString stringWithFormat:@"%@ (已下载)", item.cityName];
                NSString *contentStr = cityname.text;
                [self setTextColor:cityname FontNumber:[UIFont systemFontOfSize:13] AndRange:NSMakeRange(contentStr.length - 5, 5) AndColor:[UIColor whiteColor]];
            }else if (updateInfo.status==10){
                down.image = [UIImage imageNamed:@"stopdown"];
                
                cityname.text = [NSString stringWithFormat:@"%@ (离线包导入中)", item.cityName];
                NSString *contentStr = cityname.text;
                [self setTextColor:cityname FontNumber:[UIFont systemFontOfSize:13] AndRange:NSMakeRange(contentStr.length - 8, 8) AndColor:[UIColor whiteColor]];
            }else {
                down.image = [UIImage imageNamed:@"downloading"];
                cityname.text = [NSString stringWithFormat:@"%@", item.cityName];
            }
        }
        }else if (indexPath.section == 2){
            if ([_showDic objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section]]) {
            BMKOLSearchRecord* item = [self.hongkongMacaoAry objectAtIndex:indexPath.row];
            BMKOLUpdateElement* updateInfo;
            updateInfo = [_offlineMap getUpdateInfo:item.cityID];
            //转换包大小
            //sizelabel.autoresizingMask =UIViewAutoresizingFlexibleLeftMargin;
            NSString *packSize = [self getDataSizeString:item.size];
            sizelabel.text =  [NSString stringWithFormat:@"%@",packSize];
            down.image = [UIImage imageNamed:@"stopdown"];
            if (updateInfo.status==1) {
                cityname.text = [NSString stringWithFormat:@"%@ (正在下载)", item.cityName];
                NSString *contentStr = cityname.text;
                [self setTextColor:cityname FontNumber:[UIFont systemFontOfSize:13] AndRange:NSMakeRange(contentStr.length - 6, 6) AndColor:[QFTools colorWithHexString:@"#20c8ac"]];
            }else if (updateInfo.status==2) {
                down.image = [UIImage imageNamed:@"stopdown"];
                cityname.text = [NSString stringWithFormat:@"%@ (等待下载)", item.cityName];
                NSString *contentStr = cityname.text;
                [self setTextColor:cityname FontNumber:[UIFont systemFontOfSize:13] AndRange:NSMakeRange(contentStr.length - 6, 6) AndColor:[QFTools colorWithHexString:@"#ffffff"]];
            }else if (updateInfo.status==3) {
                down.image = [UIImage imageNamed:@"downloading"];
                cityname.text = [NSString stringWithFormat:@"%@ (已暂停)", item.cityName];
                
                NSString *contentStr = cityname.text;
                [self setTextColor:cityname FontNumber:[UIFont systemFontOfSize:13] AndRange:NSMakeRange(contentStr.length - 5, 5) AndColor:[UIColor redColor]];
            }else if (updateInfo.status==4){
                down.image = [UIImage imageNamed:@"stopdown"];
                cityname.text = [NSString stringWithFormat:@"%@ (已下载)", item.cityName];
                NSString *contentStr = cityname.text;
                [self setTextColor:cityname FontNumber:[UIFont systemFontOfSize:13] AndRange:NSMakeRange(contentStr.length - 5, 5) AndColor:[UIColor whiteColor]];
            }else if (updateInfo.status==10){
                down.image = [UIImage imageNamed:@"stopdown"];
                cityname.text = [NSString stringWithFormat:@"%@ (离线包导入中)", item.cityName];
                NSString *contentStr = cityname.text;
                [self setTextColor:cityname FontNumber:[UIFont systemFontOfSize:13] AndRange:NSMakeRange(contentStr.length - 8, 8) AndColor:[UIColor whiteColor]];
            }else {
                
                down.image = [UIImage imageNamed:@"downloading"];
                cityname.text = [NSString stringWithFormat:@"%@", item.cityName];
            }
            
            }
        }
        //支持离线下载城市列表
        else
        {
            if ([_showDic objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.section]]) {
            
            BMKOLSearchRecord* item = [self.provinceAry objectAtIndex:indexPath.section - 3];
            //转换包大小
            
            BMKOLSearchRecord* childitem = item.childCities[indexPath.row +1];
            NSString *packSize = [self getDataSizeString:childitem.size];
            
            //sizelabel.autoresizingMask =UIViewAutoresizingFlexibleLeftMargin;
            sizelabel.text =  [NSString stringWithFormat:@"%@",packSize];
            BMKOLUpdateElement* updateInfo;
            updateInfo = [_offlineMap getUpdateInfo:childitem.cityID];
            
            if (updateInfo.status==1) {
                down.image = [UIImage imageNamed:@"stopdown"];
                cityname.text = [NSString stringWithFormat:@"%@ (正在下载)", childitem.cityName];
                NSString *contentStr = cityname.text;
                [self setTextColor:cityname FontNumber:[UIFont systemFontOfSize:13] AndRange:NSMakeRange(contentStr.length - 6, 6) AndColor:[QFTools colorWithHexString:@"#20c8ac"]];
            }else if (updateInfo.status==2) {
                down.image = [UIImage imageNamed:@"stopdown"];
                cityname.text = [NSString stringWithFormat:@"%@ (等待下载)", childitem.cityName];
                NSString *contentStr = cityname.text;
                [self setTextColor:cityname FontNumber:[UIFont systemFontOfSize:13] AndRange:NSMakeRange(contentStr.length - 6, 6) AndColor:[UIColor whiteColor]];
            }else if (updateInfo.status==3) {
                down.image = [UIImage imageNamed:@"downloading"];
                cityname.text = [NSString stringWithFormat:@"%@ (已暂停)", childitem.cityName];
                NSString *contentStr = cityname.text;
                [self setTextColor:cityname FontNumber:[UIFont systemFontOfSize:13] AndRange:NSMakeRange(contentStr.length - 5, 5) AndColor:[UIColor redColor]];
            }else if (updateInfo.status==4){
                down.image = [UIImage imageNamed:@"stopdown"];
                cityname.text = [NSString stringWithFormat:@"%@ (已下载)", childitem.cityName];
                NSString *contentStr = cityname.text;
                [self setTextColor:cityname FontNumber:[UIFont systemFontOfSize:13] AndRange:NSMakeRange(contentStr.length - 5, 5) AndColor:[UIColor whiteColor]];
            }else if (updateInfo.status==10){
                down.image = [UIImage imageNamed:@"stopdown"];
                cityname.text = [NSString stringWithFormat:@"%@ (离线包导入中)", item.cityName];
                NSString *contentStr = cityname.text;
                [self setTextColor:cityname FontNumber:[UIFont systemFontOfSize:13] AndRange:NSMakeRange(contentStr.length - 8, 8) AndColor:[UIColor whiteColor]];
            }else {
                down.image = [UIImage imageNamed:@"downloading"];
                cityname.text = [NSString stringWithFormat:@"%@", childitem.cityName];
            }
            
        }
    }
        
        return cell;
    }else{
         PlainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *down = cell.down;
        UILabel *sizelabel = cell.sizelabel;
        UILabel *cityname = cell.cityLab;
        UIProgressView *processView = cell.processView;
        UIButton *stopBtn = cell.stopBtn;
        UIButton *delete = cell.deleteBtn;
        
        if (indexPath.section == 0) {
            
            
            if(_arraylocalDownLoadMapInfo!=nil&&_arraylocalDownLoadMapInfo.count>indexPath.row)
            {
                BMKOLUpdateElement* item = [self.downloadingAry objectAtIndex:indexPath.row];
                
                NSString *str = item.cityName;
                cityname.text = str;
                
                if ([_cellshowDic objectForKey:indexPath]) {
                    down.image = [UIImage imageNamed:@"icon_up"];
                    stopBtn.hidden = NO;
                    delete.hidden = NO;
                    [stopBtn addTarget:self action:@selector(stopBtnClick: WithEvent:) forControlEvents:UIControlEventTouchUpInside];
                    
                    BMKOLUpdateElement* updateInfo;
                    updateInfo = [_offlineMap getUpdateInfo:item.cityID];
                    if (updateInfo.status==3) {
                        [stopBtn setTitle:@"开始下载" forState:UIControlStateNormal];
                        
                    }else{
                    
                        [stopBtn setTitle:@"暂停下载" forState:UIControlStateNormal];
                    }
                    
                    [delete addTarget:self action:@selector(deleteClick: WithEvent:) forControlEvents:UIControlEventTouchUpInside];
                    
                }else{
                    down.image = [UIImage imageNamed:@"icon_down"];
                    stopBtn.hidden = YES;
                    delete.hidden = YES;
                }
                
                //是否可更新
                if(item.update)
                {
                    
                    BMKOLUpdateElement* updateInfo;
                    updateInfo = [_offlineMap getUpdateInfo:item.cityID];
                    
                    processView.progress = updateInfo.ratio/100.00;
                    
                    if (updateInfo.status==1) {
                        sizelabel.textColor = [QFTools colorWithHexString:MainColor];
                        sizelabel.text =  [NSString stringWithFormat:@"正在下载%d%%",updateInfo.ratio];
                    }else if (updateInfo.status==2) {
                        sizelabel.text = @"等待下载";
                    }else if (updateInfo.status==3) {
                        sizelabel.textColor = [UIColor redColor];
                        sizelabel.text = [NSString stringWithFormat:@"已暂停%d%%",updateInfo.ratio];
                        
                    }else if (updateInfo.status==4){
                        sizelabel.textColor = [QFTools colorWithHexString:@"#bbbbbb"];
                        [processView removeFromSuperview];
                        sizelabel.text = @"已下载";
                        
                    }else if (updateInfo.status==10){
                        
                        sizelabel.text = @"离线包导入中";
                        
                    }else {
                        
                        sizelabel.text = @"未下载";
                    }
                    
                }
                else
                {
                    BMKOLUpdateElement* updateInfo;
                    updateInfo = [_offlineMap getUpdateInfo:item.cityID];
                    processView.progress = updateInfo.ratio/100.00;
                    if (updateInfo.status==1) {
                        sizelabel.textColor = [QFTools colorWithHexString:MainColor];
                        sizelabel.text =  [NSString stringWithFormat:@"正在下载%d%%",updateInfo.ratio];
                    }else if (updateInfo.status==2) {
                        sizelabel.text = @"等待下载";
                    }else if (updateInfo.status==3) {
                        sizelabel.textColor = [UIColor redColor];
                        sizelabel.text = [NSString stringWithFormat:@"已暂停%d%%",updateInfo.ratio];
                    }else if (updateInfo.status==4){
                        sizelabel.textColor = [QFTools colorWithHexString:@"#bbbbbb"];
                        [processView removeFromSuperview];
                        sizelabel.text = @"已下载";
                        
                    }else if (updateInfo.status==10){
                        
                        sizelabel.text = @"离线包导入中";
                        
                    }else {
                        
                        sizelabel.text = @"未下载";
                    }
                    
                }
            }
            else
            {
                cell.textLabel.text = @"";
            }
            
        }else{
            
            if(_arraylocalDownLoadMapInfo!=nil&&_arraylocalDownLoadMapInfo.count>indexPath.row)
            {
                BMKOLUpdateElement* item = [self.downAry objectAtIndex:indexPath.row];
                
                cityname.text = item.cityName;
                [stopBtn removeFromSuperview];
                [processView removeFromSuperview];
                if ([_cellshowDic objectForKey:indexPath]) {
                    down.image = [UIImage imageNamed:@"icon_up"];
                    delete.hidden = NO;
                    [delete addTarget:self action:@selector(deleteClick: WithEvent:) forControlEvents:UIControlEventTouchUpInside];
                    
                }else{
                    down.image = [UIImage imageNamed:@"icon_down"];
                    delete.hidden = YES;
                }
                
                //是否可更新
                if(item.update)
                {
                    BMKOLUpdateElement* updateInfo;
                    updateInfo = [_offlineMap getUpdateInfo:item.cityID];
                    
                    processView.progress = updateInfo.ratio/100.00;
                    
                    if (updateInfo.status==1) {
                        sizelabel.textColor = [QFTools colorWithHexString:MainColor];
                        sizelabel.text =  [NSString stringWithFormat:@"正在下载%d%%",updateInfo.ratio];
                    }else if (updateInfo.status==2) {
                        sizelabel.text = @"等待下载";
                    }else if (updateInfo.status==3) {
                        sizelabel.textColor = [UIColor redColor];
                        sizelabel.text = [NSString stringWithFormat:@"已暂停%d%%",updateInfo.ratio];
                    }else if (updateInfo.status==4){
                        sizelabel.textColor = [QFTools colorWithHexString:@"#bbbbbb"];
                        [processView removeFromSuperview];
                        sizelabel.text = @"已下载";
                        
                    }else if (updateInfo.status==10){
                        
                        sizelabel.text = @"离线包导入中";
                        
                    }else {
                        
                        sizelabel.text = @"未下载";
                    }
                }else{
                    
                    BMKOLUpdateElement* updateInfo;
                    updateInfo = [_offlineMap getUpdateInfo:item.cityID];
                    processView.progress = updateInfo.ratio/100.00;
                    if (updateInfo.status==1) {
                        sizelabel.textColor = [QFTools colorWithHexString:MainColor];
                        sizelabel.text =  [NSString stringWithFormat:@"正在下载%d%%",updateInfo.ratio];
                    }else if (updateInfo.status==2) {
                        sizelabel.text = @"等待下载";
                    }else if (updateInfo.status==3) {
                        sizelabel.textColor = [UIColor redColor];
                        sizelabel.text = [NSString stringWithFormat:@"已暂停%d%%",updateInfo.ratio];
                    }else if (updateInfo.status==4){
                        sizelabel.textColor = [QFTools colorWithHexString:@"#bbbbbb"];
                        [processView removeFromSuperview];
                        sizelabel.text = @"已下载";
                        
                    }else if (updateInfo.status==10){
                        
                        sizelabel.text = @"离线包导入中";
                        
                    }else {
                        
                        sizelabel.text = @"未下载";
                    }
                }
            }
            else
            {
                
                cell.textLabel.text = @"";
            }
        }
        return cell;
    }
}

-(void)deleteClick:(UIButton *)btn WithEvent:(id)event
{
    
    //取到 button所在的cell的indexPath
    NSSet *touches =[event allTouches];
    UITouch *touch =[touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:plainTableView];
    NSIndexPath *indexPath= [plainTableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath != nil)
    {
        
        if (indexPath.section == 0) {
            
            BMKOLUpdateElement* item = [self.downloadingAry objectAtIndex:indexPath.row];
            //删除指定城市id的离线地图
            [_offlineMap remove:item.cityID];
            //将此城市的离线地图信息从数组中删除
            [(NSMutableArray*)_arraylocalDownLoadMapInfo removeObjectAtIndex:indexPath.row];
            
        }else{
        
            BMKOLUpdateElement* item = [self.downAry objectAtIndex:indexPath.row];
            //删除指定城市id的离线地图
            [_offlineMap remove:item.cityID];
            //将此城市的离线地图信息从数组中删除
            [(NSMutableArray*)_arraylocalDownLoadMapInfo removeObjectAtIndex:indexPath.row];
            
        }
        
        
    }
    
    [self mapDownloadStatus];
    dispatch_async(dispatch_get_main_queue(), ^{
        // something
        [plainTableView reloadData];
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // something
        [groupTableView reloadData];
    });
    
}

-(void)stopBtnClick:(UIButton *)btn WithEvent:(id)event
{
    
    //取到 button所在的cell的indexPath
    NSSet *touches =[event allTouches];
    UITouch *touch =[touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:plainTableView];
    NSIndexPath *indexPath= [plainTableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath != nil)
    {
        if (indexPath.section == 0) {
            
            BMKOLUpdateElement* item = [self.downloadingAry objectAtIndex:indexPath.row];
            
            if (item.status == 1 || item.status == 2) {
                [_offlineMap pause:item.cityID];
            }else{
                
                [_offlineMap start:item.cityID];
                
            }
        }
    }
    
    [self mapDownloadStatus];
    dispatch_async(dispatch_get_main_queue(), ^{
        // something
        [plainTableView reloadData];
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // something
        [groupTableView reloadData];
    });
    
}

////是否允许table进行编辑操作
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    if(tableView== groupTableView)
//    {
//        return NO;
//    }
//    else
//    {
//        return YES;
//    }
//}

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath
{
    if(tableView== groupTableView)
    {
        cell.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        cell.backgroundColor = [UIColor whiteColor];
    }
    

}

////提交编辑列表的结果
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        //删除poi
//        if (tableView == plainTableView) {
//            BMKOLUpdateElement* item = [_arraylocalDownLoadMapInfo objectAtIndex:indexPath.row];
//            //删除指定城市id的离线地图
//            [_offlineMap remove:item.cityID];
//            //将此城市的离线地图信息从数组中删除
//            [(NSMutableArray*)_arraylocalDownLoadMapInfo removeObjectAtIndex:indexPath.row];
//            
//        }
//        [self mapDownloadStatus];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // something
//            [plainTableView reloadData];
//        });
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // something
//            [groupTableView reloadData];
//        });
//    }
//    
//}
//表的行选择操作
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(tableView==plainTableView)
    {
        BMKOLUpdateElement* item = [_arraylocalDownLoadMapInfo objectAtIndex:indexPath.row];
        if(item.ratio==100&&item.update)//跳转到地图查看页面进行地图更新
            //        if(item.ratio==100)
        {
            //跳转到地图浏览页面
            OfflineDemoMapViewController *offlineMapViewCtrl = [[OfflineDemoMapViewController alloc] init];
            offlineMapViewCtrl.title = @"查看离线地图";
            offlineMapViewCtrl.cityId = item.cityID;
            offlineMapViewCtrl.offlineServiceOfMapview = _offlineMap;
            UIBarButtonItem *customLeftBarButtonItem = [[UIBarButtonItem alloc] init];
            customLeftBarButtonItem.title = @"返回";
            self.navigationItem.backBarButtonItem = customLeftBarButtonItem;
            [self.navigationController pushViewController:offlineMapViewCtrl animated:YES];
            
        }
        else if(item.ratio<100)//弹出提示框
        {
//            cityId.text = [NSString stringWithFormat:@"%d", item.cityID];
//            cityName.text = item.cityName;
//            downloadratio.text = [NSString stringWithFormat:@"已下载:%d", item.ratio];
//            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该离线地图未完全下载，请继续下载！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
//            [myAlertView show];
        }
        
        //NSInteger didSection = recognizer.view.tag;
        
        if (!_cellshowDic) {
            _cellshowDic = [[NSMutableDictionary alloc]init];
        }
        
        NSIndexPath *key = indexPath;
        if (![_cellshowDic objectForKey:key]) {
            [_cellshowDic setObject:@"1" forKey:key];
            
        }else{
            [_cellshowDic removeObjectForKey:key];
            
        }
        
        [plainTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        //获得当前选中的城市信息
        if(indexPath.section==0)
        {
            BMKOLSearchRecord* item = [self.wholecountryAry objectAtIndex:indexPath.row];
            //NSString* tempStri = [NSString stringWithFormat:@"%@(%d)", item.cityName, item.cityID];
            BMKOLUpdateElement* updateInfo;
            updateInfo = [_offlineMap getUpdateInfo:item.cityID];
            if (updateInfo.status == 1 || updateInfo.status == 2) {
                [_offlineMap pause:item.cityID];
            }else{
            
                [_offlineMap start:item.cityID];
                [self mapDownloadStatus];
            }
        }else if(indexPath.section==1){
            
            BMKOLSearchRecord* item = [self.municipalAry objectAtIndex:indexPath.row];
            //NSString* tempStri = [NSString stringWithFormat:@"%@(%d)", item.cityName, item.cityID];
            BMKOLUpdateElement* updateInfo;
            updateInfo = [_offlineMap getUpdateInfo:item.cityID];
            if (updateInfo.status == 1 || updateInfo.status == 2) {
                [_offlineMap pause:item.cityID];
            }else{
                
                [_offlineMap start:item.cityID];
                [self mapDownloadStatus];
            }
            
        }else if(indexPath.section==2)
        {
            BMKOLSearchRecord* item = [self.hongkongMacaoAry objectAtIndex:indexPath.row];
            //NSString* tempStri = [NSString stringWithFormat:@"%@(%d)", item.cityName, item.cityID];
            BMKOLUpdateElement* updateInfo;
            updateInfo = [_offlineMap getUpdateInfo:item.cityID];
            if (updateInfo.status == 1 || updateInfo.status == 2) {
                [_offlineMap pause:item.cityID];
            }else{
                
                [_offlineMap start:item.cityID];
                [self mapDownloadStatus];
            }
            
        }else{
            BMKOLSearchRecord* item = [self.provinceAry objectAtIndex:indexPath.section - 3];
            BMKOLSearchRecord* childitem = item.childCities[indexPath.row +1];
            //NSString* tempStri = [NSString stringWithFormat:@"%@(%d)", childitem.cityName, childitem.cityID];
            BMKOLUpdateElement* updateInfo;
            updateInfo = [_offlineMap getUpdateInfo:childitem.cityID];
            if (updateInfo.status == 1 || updateInfo.status == 2) {
                [_offlineMap pause:childitem.cityID];
            }else{
                
                [_offlineMap start:childitem.cityID];
                [self mapDownloadStatus];
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // something
            [groupTableView reloadData];
        });
    }
}

#pragma mark 展开收缩section中cell 手势监听
-(void)SingleTap:(UITapGestureRecognizer*)recognizer{
    NSInteger didSection = recognizer.view.tag;
    
    if (!_showDic) {
        _showDic = [[NSMutableDictionary alloc]init];
    }
    
    NSString *key = [NSString stringWithFormat:@"%ld",(long)didSection];
    if (![_showDic objectForKey:key]) {
        [_showDic setObject:@"1" forKey:key];
        
    }else{
        [_showDic removeObjectForKey:key];
        
    }
    [groupTableView reloadSections:[NSIndexSet indexSetWithIndex:didSection] withRowAnimation:UITableViewRowAnimationFade];
    //[groupTableView reloadRowsAtIndexPaths:@[self.lastSelectIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark 包大小转换工具类（将包大小转换成合适单位）
-(NSString *)getDataSizeString:(int) nSize
{
    NSString *string = nil;
    if (nSize<1024)
    {
        string = [NSString stringWithFormat:@"%dB", nSize];
    }
    else if (nSize<1048576)
    {
        string = [NSString stringWithFormat:@"%dK", (nSize/1024)];
    }
    else if (nSize<1073741824)
    {
        if ((nSize%1048576)== 0 )
        {
            string = [NSString stringWithFormat:@"%dM", nSize/1048576];
        }
        else
        {
            int decimal = 0; //小数
            NSString* decimalStr = nil;
            decimal = (nSize%1048576);
            decimal /= 1024;
            
            if (decimal < 10)
            {
                decimalStr = [NSString stringWithFormat:@"%d", 0];
            }
            else if (decimal >= 10 && decimal < 100)
            {
                int i = decimal / 10;
                if (i >= 5)
                {
                    decimalStr = [NSString stringWithFormat:@"%d", 1];
                }
                else
                {
                    decimalStr = [NSString stringWithFormat:@"%d", 0];
                }
                
            }
            else if (decimal >= 100 && decimal < 1024)
            {
                int i = decimal / 100;
                if (i >= 5)
                {
                    decimal = i + 1;
                    
                    if (decimal >= 10)
                    {
                        decimal = 9;
                    }
                    
                    decimalStr = [NSString stringWithFormat:@"%d", decimal];
                }
                else
                {
                    decimalStr = [NSString stringWithFormat:@"%d", i];
                }
            }
            
            if (decimalStr == nil || [decimalStr isEqualToString:@""])
            {
                string = [NSString stringWithFormat:@"%dMss", nSize/1048576];
            }
            else
            {
                string = [NSString stringWithFormat:@"%d.%@M", nSize/1048576, decimalStr];
            }
        }
    }
    else	// >1G
    {
        string = [NSString stringWithFormat:@"%dG", nSize/1073741824];
    }
    
    return string;
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
