//
//  BikeInfoModel.m
//  RideHousekeeper
//
//  Created by Apple on 2017/11/28.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "BikeInfoModel.h"

@implementation BikeInfoModel

//把数组里面带有对象的类型专门按照这个方法，这个格式写出来*****
+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass{
    
    return @{
             @"device_info" : DeviceInfoModel.class, // @"statuses" : [MJStatus class],
             @"fps" : FingerModel.class // @"ads" : [MJAd class]
             };
}

@end
