//
//  PeripheralUUIDModel.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/10/19.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "PeripheralUUIDModel.h"

@implementation PeripheralUUIDModel

+ (instancetype)modalWith:(NSString *)username bikeid:(NSInteger )bikeid mac:(NSString *)mac uuid:(NSString *)uuid{

    PeripheralUUIDModel *model = [[self alloc] init];
    model.username = username;
    model.bikeid = bikeid;
    model.mac = mac;
    model.uuid = uuid;
    
    return model;


}

@end
