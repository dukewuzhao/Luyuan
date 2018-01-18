//
//  MyGarageViewController.m
//  RideHousekeeper
//
//  Created by Apple on 2017/8/24.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "MyGarageViewController.h"
#import "AddBikeViewController.h"

@interface MyGarageViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    
    NSMutableArray *bikearray;
    
}

@property(nonatomic,weak) UITableView *listTableView;

@end

@implementation MyGarageViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self sqliteUpdate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    
    @weakify(self);
    [self configureNavgationItemTitle:@"我的车库"];
    
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
    // 添加选项
    [self setupMenus];
    
}

//选项栏
- (void)setupMenus{
    
    UITableView *listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - navHeight - QGJ_TabbarSafeBottomMargin)];
    listTableView.backgroundColor = [UIColor clearColor];
    listTableView.delegate = self;
    listTableView.dataSource = self;
    listTableView.bounces = YES;
    listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    listTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:listTableView];
    self.listTableView = listTableView;
    
    UIView *footview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 80)];
    [self.view addSubview:footview];
    listTableView.tableFooterView = footview;
    
    UIButton *addbike = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth *.2, 20, ScreenWidth *.6, 44)];
    addbike.layer.masksToBounds = YES;
    addbike.layer.cornerRadius = 8;
    [addbike setTitle:@"添加车辆" forState:UIControlStateNormal];
    [addbike setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addbike.backgroundColor = [QFTools colorWithHexString:MainColor];
    [addbike addTarget:self action:@selector(addbikeClicked) forControlEvents:UIControlEventTouchUpInside];
    [footview addSubview:addbike];
    
}

- (void)addbikeClicked{
    
    AddBikeViewController *addVc = [AddBikeViewController new];
    [self.navigationController pushViewController:addVc animated:YES];
    
}

#pragma mark -- TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    
    return bikearray.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath
{
    
    if ([USER_DEFAULTS valueForKey:SETRSSI]) {
        
        if ([[USER_DEFAULTS valueForKey:SETRSSI] isEqualToString:[[bikearray objectAtIndex:indexPath.section] mac]])
        {
            cell.backgroundColor = [QFTools colorWithHexString:@"#d9d9d9"];
        }
        else
        {
            cell.backgroundColor = [UIColor whiteColor];
        }
    }else{
        
        cell.backgroundColor = [UIColor whiteColor];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    
    view.tintColor = [QFTools colorWithHexString:@"#ebecf2"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellName];
    }else{
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];  //删除并进行重新分配
        }
    }
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 20, 35, 8.4, 15)];
    arrow.image = [UIImage imageNamed:@"arrow"];
    cell.accessoryView = arrow;
    
    if (bikearray.count != 0) {
        
        BikeModel *model = bikearray[indexPath.section];
        NSString *brandQuerySql3 = [NSString stringWithFormat:@"SELECT * FROM brand_modals WHERE bikeid LIKE '%%%zd%%'", model.bikeid];
        NSMutableArray *brandmodals = [LVFmdbTool queryBrandData:brandQuerySql3];
        BrandModel *brandmodel = brandmodals.firstObject;
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(15, 11.5, 65, 65)];
        image.layer.masksToBounds = YES;
        image.layer.cornerRadius = 15;
        image.image = [UIImage imageNamed:@"qgjlogo"];
        [[cell contentView] addSubview:image];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(image.frame) + 15, 20, 150, 20)];
        label.textColor = [UIColor blackColor];
        label.text = [NSString stringWithFormat:@"%@",model.bikename];
        label.textAlignment = NSTextAlignmentLeft;
        [[cell contentView] addSubview:label];
        
        UILabel *modellabel = [[UILabel alloc] initWithFrame:CGRectMake(label.x, CGRectGetMaxY(label.frame) + 10, 150, 20)];
        modellabel.textColor = [QFTools colorWithHexString:@"#999999"];
        modellabel.text = [NSString stringWithFormat:@"%@",brandmodel.brandname];
        modellabel.textAlignment = NSTextAlignmentLeft;
        modellabel.font = [UIFont systemFontOfSize:15];
        [[cell contentView] addSubview:modellabel];
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [USER_DEFAULTS setValue:[[bikearray objectAtIndex:indexPath.section] mac]forKey:SETRSSI];
    NSNumber *biketag = [NSNumber numberWithInteger:[[bikearray objectAtIndex:indexPath.section] bikeid]];
    NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:biketag,@"biketag", nil];
    [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_SwitchingVehicle object:nil userInfo:dict]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sqliteUpdate{
    
    
    [bikearray removeAllObjects];
    bikearray = [LVFmdbTool queryBikeData:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.listTableView reloadData];
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
