//
//  PeripheralModel.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/8/22.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "PeripheralModel.h"

@implementation PeripheralModel

+ (instancetype)modalWith:(NSInteger)bikeid deviceid:(NSInteger)deviceid type:(NSInteger)type seq:(NSInteger)seq mac:(NSString *)mac sn:(NSString *)sn firmversion:(NSString *)firmversion{
    
    PeripheralModel *model = [[self alloc] init];
    model.bikeid = bikeid;
    model.deviceid = deviceid;
    model.seq = seq;
    model.type = type;
    model.mac = mac;
    model.sn = sn;
    model.firmversion = firmversion;
    return model;

}
@end
