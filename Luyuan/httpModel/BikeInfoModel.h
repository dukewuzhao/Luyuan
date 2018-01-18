//
//  BikeInfoModel.h
//  RideHousekeeper
//
//  Created by Apple on 2017/11/28.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BikeBrandInfoModel;
@class BikeModelInfoModel;
@class BikePasswdInfoModel;
@interface BikeInfoModel : NSObject

@property (assign, nonatomic) NSInteger bike_id;
@property (copy, nonatomic) NSString* bike_name;
@property (assign, nonatomic) NSInteger owner_flag;
@property (copy, nonatomic) NSString* hw_version;
@property (copy, nonatomic) NSString* firm_version;
@property (copy, nonatomic) NSString* key_version;
@property (copy, nonatomic) NSString* mac;
@property (assign, nonatomic) NSInteger binded_count;
@property (strong, nonatomic) BikeBrandInfoModel *brand_info;
@property (strong, nonatomic) BikeModelInfoModel *model_info;
@property (strong, nonatomic) BikePasswdInfoModel *passwd_info;
/** 存放着外设数据（里面都是DeviceInfo模型） */
@property (strong, nonatomic) NSMutableArray *device_info;
@property (copy, nonatomic) NSString* owner_phone;
/** 存放着指纹数据（里面都是FingerModel模型） */
@property (strong, nonatomic) NSMutableArray *fps;

@end
