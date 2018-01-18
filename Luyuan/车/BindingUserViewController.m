//
//  BindingUserViewController.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/8/26.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "BindingUserViewController.h"
#import "AddUserViewController.h"

@interface BindingUserViewController ()<UITableViewDataSource,UITableViewDelegate,AddUserViewControllerDelegate>

@property (nonatomic ,weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datarray;

@property (nonatomic, strong) NSMutableArray *childIdArray;
@property (nonatomic, assign) NSInteger selectIndex;

@end

@implementation BindingUserViewController

// 即将进来页面后关闭抽屉
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

// 即将出去后再打开 因为可能其他页面需要抽屉效果
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (NSMutableArray *)datarray {
    if (!_datarray) {
        _datarray = [[NSMutableArray alloc] init];
    }
    return _datarray;
}

- (NSMutableArray *)childIdArray {
    if (!_childIdArray) {
        _childIdArray = [[NSMutableArray alloc] init];
    }
    return _childIdArray;
}

-(void)getBikeUser{


    [self.datarray removeAllObjects];
    [self.childIdArray removeAllObjects];
    
    NSString *token = [QFTools getdata:@"token"];
    NSNumber *bikeid = [NSNumber numberWithInteger:self.bikeid];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/getbikeusers"];
    NSDictionary *parameters = @{@"token":token, @"bike_id": bikeid};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            NSMutableArray *userArray = data[@"user_info"];
            
            for (NSDictionary *userDic in userArray) {
                
                if (![userDic[@"phone_num"] isEqualToString:[QFTools getdata:@"phone_num"]]) {
                    
                    [self.datarray addObject:userDic[@"phone_num"]];
                    [self.childIdArray addObject:userDic[@"user_id"]];
                    
                }
            }
            
            NSString *updateSql = [NSString stringWithFormat:@"UPDATE bike_modals SET bindedcount = '%zd' WHERE bikeid = '%zd'", self.datarray.count+1,self.bikeid];
            [LVFmdbTool modifyData:updateSql];
            
            if([self.delegate respondsToSelector:@selector(UpdateUsernumberSuccess)])
            {
                [self.delegate UpdateUsernumberSuccess];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
            });
            
            
        }else if([dict[@"status"] intValue] == 1001){
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }else{
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [QFTools colorWithHexString:@"#ebecf2"];
    
    WS(weakself);
    
    [self configureNavgationItemTitle:@"分享车辆"];
    
    [self configureLeftBarButtonWithImage:[UIImage imageNamed:@"back"] action:^{
        
        [weakself.navigationController popViewControllerAnimated:YES];
        
    }];
    
    [self setupview];
}

- (void)setupview{
    
    UIView *backview = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - ScreenWidth *.13, 30, ScreenWidth *.26, ScreenWidth *.26)];
    backview.backgroundColor = [QFTools colorWithHexString:MainColor];
    backview.layer.masksToBounds = YES;
    backview.layer.cornerRadius = ScreenWidth *.13;
    [self.view addSubview:backview];
    
    UIImageView *backIcon = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - ScreenWidth *.13, 30, ScreenWidth *.26, ScreenWidth *.26)];
    backIcon.center = backview.center;
    backIcon.image = [UIImage imageNamed:@"lvyuan_logo"];
    [self.view addSubview:backIcon];
    
    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.bikeid];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 75, CGRectGetMaxY(backview.frame)+10, 150, 20)];
    nameLabel.text = bikemodel.bikename;
    nameLabel.textColor = [QFTools colorWithHexString:MainColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:nameLabel];
    
    UIView *mianuser = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(nameLabel.frame)+30, ScreenWidth, 45)];
    mianuser.backgroundColor =[UIColor whiteColor];
    [self.view addSubview:mianuser];
    
    UIImageView *mianIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 25, 25)];
    mianIcon.image = [UIImage imageNamed:@"user_icon_ig"];
    [mianuser addSubview:mianIcon];
    
    UILabel *mainlabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(mianIcon.frame), 12.5, 120, 20)];
    mainlabel.text = [QFTools getdata:@"phone_num"];
    mainlabel.textAlignment = NSTextAlignmentCenter;
    mainlabel.textColor = [UIColor blackColor];
    mainlabel.font = [UIFont systemFontOfSize:15];
    [mianuser addSubview:mainlabel];
    
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(mianuser.frame)+ 10, ScreenWidth, ScreenHeight *.4)];
    table.bounces = NO;
    table.delegate = self;
    table.dataSource = self;
    table.separatorStyle = NO;
    table.backgroundColor = [UIColor clearColor];
    [table setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:table];
    self.tableView = table;
    
    if (bikemodel.ownerflag == 0) {
        
        
    }else{
    UIButton *addbike = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
    [addbike setTitle:@"添加成员" forState:UIControlStateNormal];
    [addbike setTitleColor:[QFTools colorWithHexString:MainColor] forState:UIControlStateNormal];
    addbike.backgroundColor = [UIColor whiteColor];
    [addbike addTarget:self action:@selector(addbikeClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addbike];
    table.tableFooterView = addbike;
    }
    
    [self getBikeUser];
}

- (void)addbikeClick{

    NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.bikeid];
    NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
    BikeModel *bikemodel = bikemodals.firstObject;
    if (bikemodel.ownerflag == 0) {
        
        [SVProgressHUD showSimpleText:@"子用户无此权限"];
        return;
        
    }
    
    AddUserViewController *addVc = [AddUserViewController new];
    addVc.bikeId = self.bikeid;
    addVc.delegate = self;
    [self.navigationController pushViewController:addVc animated:YES];

}



/**
 添加用户成员成功后回调
 */
-(void)AddUserSuccess{

    [self getBikeUser];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    return self.datarray.count * 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row %2 == 0) {
        return 45;
    }else{
        
        return 10;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellName = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }else{
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView*)[cell.contentView.subviews lastObject] removeFromSuperview];  //删除并进行重新分配
        }
    }
    
    if (indexPath.row %2 == 0) {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.bikeid];
        NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
        BikeModel *bikemodel = bikemodals.firstObject;
        
        if (bikemodel.ownerflag == 1) {
            UIButton *delate = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 50, 0, 50, 45)];
            [delate setTitle:@"删除" forState:UIControlStateNormal];
            delate.backgroundColor = [UIColor redColor];
            delate.tag = indexPath.row;
            [delate addTarget:self action:@selector(deleteUser:) forControlEvents:UIControlEventTouchUpInside];
            [[cell contentView] addSubview:delate];
        }
        UIImageView *mianIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 25, 25)];
        mianIcon.image = [UIImage imageNamed:@"icon_p2"];
        [[cell contentView] addSubview:mianIcon];
        
        cell.textLabel.text = [NSString stringWithFormat:@"         %@",self.datarray[indexPath.row/2]];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        
        
    }else{
        cell.userInteractionEnabled = NO;
    }
    //cell.textLabel.text = datarray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
        
}

- ( void )tableView:( UITableView  *)tableView  willDisplayCell :( UITableViewCell  *)cell  forRowAtIndexPath :( NSIndexPath  *)indexPath
{
    if (indexPath.row%2) {
        cell .backgroundColor  = [UIColor clearColor];
        
    }else{
        cell .backgroundColor  = [UIColor whiteColor];
        
    }
}



-(void) deleteUser:(UIButton *)btn{
    self.selectIndex = btn.tag;
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"是否删除该子用户" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag =666;
    [alert show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 666) {
        if (buttonIndex != [alertView cancelButtonIndex]) {
            
            NSString *bikeQuerySql = [NSString stringWithFormat:@"SELECT * FROM bike_modals WHERE bikeid LIKE '%zd'", self.bikeid];
            NSMutableArray *bikemodals = [LVFmdbTool queryBikeData:bikeQuerySql];
            BikeModel *bikemodel = bikemodals.firstObject;
            if (bikemodel.ownerflag == 0) {
                [SVProgressHUD showSimpleText:@"子用户无此权限"];
                return;
            }
            
            if (self.selectIndex/2 >= self.datarray.count) {
                return;
            }
            NSString *token = [QFTools getdata:@"token"];
            NSNumber *bikeid = [NSNumber numberWithInt:(int)self.bikeid];
            NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/unbindchild"];
            NSDictionary *parameters = @{@"token":token, @"bike_id": bikeid , @"child_id":self.childIdArray[self.selectIndex/2]};
            
            [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
                
                if ([dict[@"status"] intValue] == 0) {
                    
                    if (self.selectIndex/2 < self.datarray.count) {
                        [self.datarray removeObjectAtIndex:self.selectIndex/2];
                        NSString *updateSql = [NSString stringWithFormat:@"UPDATE bike_modals SET bindedcount = '%zd' WHERE bikeid = '%zd'", self.datarray.count+1,self.bikeid];
                        [LVFmdbTool modifyData:updateSql];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                    [SVProgressHUD showSimpleText:@"删除子用户成功"];
                }
                else if([dict[@"status"] intValue] == 1001){
                    [SVProgressHUD showSimpleText:dict[@"status_info"]];
                }else{
                    [SVProgressHUD showSimpleText:dict[@"status_info"]];
                }
                
            }failure:^(NSError *error) {
                
                NSLog(@"error :%@",error);
                
            }];
        }
    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
