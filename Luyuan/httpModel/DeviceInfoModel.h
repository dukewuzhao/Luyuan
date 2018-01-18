//
//  DeviceInfoModel.h
//  RideHousekeeper
//
//  Created by Apple on 2017/11/27.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceInfoModel : NSObject

@property (assign, nonatomic) NSInteger default_brand_id;
@property (assign, nonatomic) NSInteger default_model_id;
@property (copy, nonatomic) NSString* desc;
@property (assign, nonatomic) NSInteger device_id;
@property (copy, nonatomic) NSString* firm_version;
@property (copy, nonatomic) NSString* mac;
@property (copy, nonatomic) NSString* prod_date;
@property (assign, nonatomic) NSInteger seq;
@property (copy, nonatomic) NSString* sn;
@property (assign, nonatomic) NSInteger type;

@end
