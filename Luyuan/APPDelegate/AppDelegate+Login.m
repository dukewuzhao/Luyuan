//
//  AppDelegate+Login.m
//  RideHousekeeper
//
//  Created by Apple on 2018/1/5.
//  Copyright © 2018年 Duke Wu. All rights reserved.
//

#import "AppDelegate+Login.h"

@implementation AppDelegate (Login)


- (void)logindata{
    
    NSString *password= [QFTools getdata:@"password"];
    NSString *phonenum= [QFTools getdata:@"phone_num"];
    
    if ([QFTools isBlankString:phonenum]) {
        return;
    }
    
    NSString *pwd = [NSString stringWithFormat:@"%@%@%@",@"QGJ",password,@"BLE"];
    NSString * md5=[QFTools md5:pwd];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/login"];
    NSDictionary *parameters = @{@"account": phonenum, @"passwd": md5.uppercaseString};
    
    AFHTTPSessionManager *manager = [QFTools sharedManager];
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/x-gzip"];
    
    [manager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dict) {
        if ([dict[@"status"] intValue] == 0) {
            
            NSDictionary *data = dict[@"data"];
            LoginDataModel *loginModel = [LoginDataModel yy_modelWithDictionary:data];
            NSString * token=loginModel.token;
            NSString * defaultlogo = loginModel.default_brand_logo;
            NSString * defaultimage = loginModel.default_model_picture;
            UserInfoModel *userinfo = loginModel.user_info;
            NSString * birthday=userinfo.birthday;
            NSString * nick_name=userinfo.nick_name;
            NSNumber * gender = [NSNumber numberWithInteger:userinfo.gender];
            NSString * icon = userinfo.icon;
            NSString * realName = userinfo.real_name;
            NSString *idcard = userinfo.id_card_no;
            NSNumber *userId = [NSNumber numberWithInteger:userinfo.user_id];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:token,@"token",phonenum,@"phone_num",password,@"password",defaultlogo,@"defaultlogo",defaultimage,@"defaultimage",userId,@"userid",nil];
            [userDefaults setObject:userDic forKey:logInUSERDIC];
            [userDefaults synchronize];
            
            NSDictionary *userDic2 = [NSDictionary dictionaryWithObjectsAndKeys:phonenum,@"username",birthday,@"birthday",nick_name,@"nick_name",gender,@"gender",icon,@"icon",realName,@"realname",idcard,@"idcard",nil];
            [userDefaults setObject:userDic2 forKey:userInfoDic];
            [userDefaults synchronize];
            
            [LVFmdbTool deleteBrandData:nil];
            [LVFmdbTool deleteBikeData:nil];
            [LVFmdbTool deleteModelData:nil];
            [LVFmdbTool deletePeripheraData:nil];
            [LVFmdbTool deleteFingerprintData:nil];
            [AppDelegate currentAppDelegate].macArrM2 = [NSMutableArray new];
            [AppDelegate currentAppDelegate].passwordArrM2 = [NSMutableArray new];
            
            for (BikeInfoModel *bikeInfo in loginModel.bike_info) {
                
                [[AppDelegate currentAppDelegate].macArrM2 addObject:bikeInfo.mac];
                if (bikeInfo.owner_flag == 1) {
                    [AppDelegate currentAppDelegate].child2 = @"0";
                    [AppDelegate currentAppDelegate].main2 = bikeInfo.passwd_info.main;
                    NSString* masterpwd = [QFTools toHexString:(long)[[AppDelegate currentAppDelegate].main2 longLongValue]];
                    int masterpwdCount = 8 - (int)masterpwd.length;
                    
                    for (int i = 0; i<masterpwdCount; i++) {
                        masterpwd = [@"0" stringByAppendingFormat:@"%@",masterpwd];
                    }
                    [[AppDelegate currentAppDelegate].passwordArrM2 addObject:masterpwd];
                }else if (bikeInfo.owner_flag == 0){
                    
                    [AppDelegate currentAppDelegate].child2 = bikeInfo.passwd_info.children.firstObject;
                    [AppDelegate currentAppDelegate].main2 = @"0";
                    
                    NSString* childpwd = [QFTools toHexString:(long)[[AppDelegate currentAppDelegate].child2 longLongValue]];
                    int childpwdCount = 8 - (int)childpwd.length;
                    
                    for (int i = 0; i<childpwdCount; i++) {
                        childpwd = [@"0" stringByAppendingFormat:@"%@",childpwd];
                    }
                    [[AppDelegate currentAppDelegate].passwordArrM2 addObject:childpwd];
                }
                
                NSString *logo = bikeInfo.brand_info.logo;
                NSString *picture_b = bikeInfo.model_info.picture_b;
                
                BikeModel *pmodel = [BikeModel modalWith:bikeInfo.bike_id bikename:bikeInfo.bike_name ownerflag:bikeInfo.owner_flag hwversion:bikeInfo.hw_version firmversion:bikeInfo.firm_version keyversion:bikeInfo.key_version mac:bikeInfo.mac mainpass:[AppDelegate currentAppDelegate].main2 password:[AppDelegate currentAppDelegate].child2 bindedcount:bikeInfo.binded_count ownerphone:bikeInfo.owner_phone];
                [LVFmdbTool insertBikeModel:pmodel];
                
                if (bikeInfo.brand_info.brand_id == 0) {
                    logo = defaultlogo;
                }
                
                BrandModel *bmodel = [BrandModel modalWith:bikeInfo.bike_id brandid:bikeInfo.brand_info.brand_id brandname:bikeInfo.brand_info.brand_name logo:logo];
                [LVFmdbTool insertBrandModel:bmodel];
                
                if (bikeInfo.model_info.model_id == 0) {
                    picture_b = defaultimage;
                }
                
                ModelInfo *Infomodel = [ModelInfo modalWith:bikeInfo.bike_id modelid:bikeInfo.model_info.model_id modelname:bikeInfo.model_info.model_name batttype:bikeInfo.model_info.batt_type battvol:bikeInfo.model_info.batt_vol wheelsize:bikeInfo.model_info.wheel_size brandid:bikeInfo.model_info.brand_id pictures:bikeInfo.model_info.picture_s pictureb:bikeInfo.model_info.picture_b];
                [LVFmdbTool insertModelInfo:Infomodel];
                
                for (DeviceInfoModel *device in bikeInfo.device_info){
                    
                    PeripheralModel *permodel = [PeripheralModel modalWith:bikeInfo.bike_id deviceid:device.device_id type:device.type seq:device.seq mac:device.mac sn:device.sn firmversion:device.firm_version];
                    [LVFmdbTool insertDeviceModel:permodel];
                }
                
                for (FingerModel *finger in bikeInfo.fps){
                    FingerprintModel *fingermodel = [FingerprintModel modalWith:bikeInfo.bike_id fp_id:finger.fp_id pos:finger.pos name:finger.name added_time:finger.added_time];
                    [LVFmdbTool insertFingerprintModel:fingermodel];
                }
            }
            
            NSString*macstring = [[NSUserDefaults standardUserDefaults] stringForKey:Key_MacSTRING];
            NSDictionary *passwordDic = [[NSUserDefaults standardUserDefaults] objectForKey:passwordDIC];
            NSMutableArray *bikeAry = [LVFmdbTool queryBikeData:nil];
            if (![[AppDelegate currentAppDelegate].macArrM2 containsObject:macstring]) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:SETRSSI];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:Key_DeviceUUID];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:Key_MacSTRING];
                NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
                [userDefatluts removeObjectForKey:passwordDIC];
                [userDefatluts synchronize];
                if (bikeAry.count > 0) {
                    BikeModel *firstbikeinfo = bikeAry[0];
                    [[NSUserDefaults standardUserDefaults]setValue:firstbikeinfo.mac.uppercaseString forKey:SETRSSI];
                }
                
                [self.device remove];
                
            }else{
                //在检测密码是否一致
                if (![[AppDelegate currentAppDelegate].passwordArrM2 containsObject:passwordDic[@"main"]]) {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:Key_DeviceUUID];
                    NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
                    [userDefatluts removeObjectForKey:passwordDIC];
                    [userDefatluts synchronize];
                }
                
                [[NSUserDefaults standardUserDefaults]setValue:macstring forKey:SETRSSI];
            }
            
            if ([LVFmdbTool queryBikeData:nil].count == 0) {
                
                if ([[AppDelegate currentAppDelegate].mainController isKindOfClass:[BikeViewController class]]) {
                    
                        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:nil];
                }
            }else{
                
                if ([[AppDelegate currentAppDelegate].mainController isKindOfClass:[ViewController class]]) {
                    
                        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:nil];
                }
            }
            
            NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
            NSString* phoneModel = [[UIDevice currentDevice] model];
            NSString* identifierNumber = [[UIDevice currentDevice].identifierForVendor UUIDString] ;
            NSString*modelname =[NSString stringWithFormat:@"%@|%@|%@",phoneModel,phoneVersion,identifierNumber];
            NSString *regid = [JPUSHService registrationID];
            NSNumber *chanel = [NSNumber numberWithInt:1];
            
            if (regid == nil) {
                regid = @"";
            }
            
            NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/pushonline"];
            NSDictionary *parameters = @{@"token": token, @"device_name": modelname,@"channel": chanel,@"reg_id": regid};
            
            AFHTTPSessionManager *manager = [QFTools sharedManager];
            manager.requestSerializer=[AFJSONRequestSerializer serializer];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/x-gzip"];
            [manager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable dict) {
                
                NSLog(@"手机型号: %@",dict[@"status_info"] );
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"error :%@",error);
                
                [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
            }];
        }
        else if([dict[@"status"] intValue] == 1001){
            
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
            
        }else if([dict[@"status"] intValue] == 1002){
            [SVProgressHUD showSimpleText:@"用户名或密码错误,请重新登录"];
            [self individuaBtnClick];
            
        }else{
            [SVProgressHUD showSimpleText:dict[@"status_info"]];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error :%@",error);
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

- (void)individuaBtnClick
{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
        [userDefatluts removeObjectForKey:logInUSERDIC];
        [userDefatluts synchronize];
        [self.device remove];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:Key_DeviceUUID];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:Key_MacSTRING];
        [userDefatluts removeObjectForKey:passwordDIC];
        [userDefatluts synchronize];
        
        self. device.deviceStatus=5;
        [NSNOTIC_CENTER postNotification:[NSNotification notificationWithName:KNotification_UpdateDeviceStatus object:nil]];
        
        NSFileManager * fileManager = [[NSFileManager alloc]init];
        NSString *imageName = @"currentImage.png";
        NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
        [fileManager removeItemAtPath:fullPath error:nil];
        // [self deleteFile];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
        
    });
}

/**
 *  检测软件是否需要升级
 */
- (void)updateApp
{
    if(![self judgeNeedVersionUpdate])  return ;
    //2先获取当前工程项目版本号
    NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion=infoDic[@"CFBundleShortVersionString"];
    NSString *URLString = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/checkupdate"];
    NSDictionary *parameters = @{@"platform":@"I", @"channel": @"QGJ",@"version": currentVersion};
    
    [[HttpRequest sharedInstance] postWithURLString:URLString parameters:parameters success:^(id _Nullable dict) {
        
        if ([dict[@"status"] intValue] == 0) {
            NSString *currentVersion=infoDic[@"CFBundleShortVersionString"];
            NSDictionary *data = dict[@"data"];
            NSString *appStoreVersion = data[@"latest_version"];
            NSString *description = data[@"description"];
            NSString *nowStoreVersion = data[@"latest_version"];
            //设置版本号
            currentVersion = [currentVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
            if (currentVersion.length==2) {
                currentVersion  = [currentVersion stringByAppendingString:@"0"];
            }else if (currentVersion.length==1){
                currentVersion  = [currentVersion stringByAppendingString:@"00"];
            }
            appStoreVersion = [appStoreVersion stringByReplacingOccurrencesOfString:@"." withString:@""];
            if (appStoreVersion.length==2) {
                appStoreVersion  = [appStoreVersion stringByAppendingString:@"0"];
            }else if (appStoreVersion.length==1){
                appStoreVersion  = [appStoreVersion stringByAppendingString:@"00"];
            }
            //4当前版本号小于商店版本号,就更新
            if([currentVersion floatValue] < [appStoreVersion floatValue])
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"检测到软件新有版本(%@),是否更新?",nowStoreVersion] message:description delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"更新", nil];
                
                //如果你的系统大于等于7.0
                if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_0)
                {
                    
                    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:15]};
                    CGSize size = [description boundingRectWithSize:CGSizeMake(200, 300)
                                                            options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                         attributes:attribute context:nil].size;
                    
                    //                    CGSize size = [description sizeWithFont:[UIFont systemFontOfSize:15]constrainedToSize:CGSizeMake(240,400) lineBreakMode:NSLineBreakByTruncatingTail];
                    
                    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0,240, size.height)];
                    textLabel.font = [UIFont systemFontOfSize:15];
                    textLabel.textColor = [UIColor blackColor];
                    textLabel.backgroundColor = [UIColor clearColor];
                    textLabel.lineBreakMode =NSLineBreakByWordWrapping;
                    textLabel.numberOfLines =0;
                    textLabel.textAlignment =NSTextAlignmentLeft;
                    textLabel.text = description;
                    [alert setValue:textLabel forKey:@"accessoryView"];
                    alert.message =@"";
                }else{
                    NSInteger count = 0;
                    for( UIView * view in alert.subviews )
                    {
                        if( [view isKindOfClass:[UILabel class]] )
                        {
                            count ++;
                            if ( count == 2 ) { //仅对message左对齐
                                UILabel* label = (UILabel*) view;
                                label.textAlignment =NSTextAlignmentLeft;
                            }
                        }
                    }
                }
                
                alert.tag = 3000;
                [alert show];
                
            }else{
                
                NSLog(@"版本号好像比商店大噢!检测到不需要更新");
            }
        }
        
    }failure:^(NSError *error) {
        
        NSLog(@"error :%@",error);
        
    }];
}

//每天进行一次版本判断
- (BOOL)judgeNeedVersionUpdate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    //获取年-月-日
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSString *currentDate = [USER_DEFAULTS objectForKey:@"currentDate"];
    if ([currentDate isEqualToString:dateString]) {
        return NO;
    }
    [USER_DEFAULTS setObject:dateString forKey:@"currentDate"];
    return YES;
}

@end
