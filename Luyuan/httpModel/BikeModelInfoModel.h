//
//  BikeModelInfoModel.h
//  RideHousekeeper
//
//  Created by Apple on 2017/11/27.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BikeModelInfoModel : NSObject

@property (assign, nonatomic) NSInteger model_id;
@property (copy, nonatomic) NSString* model_name;
@property (assign, nonatomic) NSInteger batt_type;
@property (assign, nonatomic) NSInteger batt_vol;
@property (assign, nonatomic) NSInteger wheel_size;
@property (assign, nonatomic) NSInteger brand_id;
@property (copy, nonatomic) NSString* picture_s;
@property (copy, nonatomic) NSString* picture_b;

@end
