//
//  KeyModel.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/8/11.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "KeyModel.h"

@implementation KeyModel

+ (instancetype)modalWith:(NSInteger)keyid keyname:(NSString *)keyname sn:(NSString *)sn deviceid:(NSInteger)deviceid{

    KeyModel *model = [[self alloc] init];
    model.keyid = keyid;
    model.keyname = keyname;
    model.sn = sn;
    model.deviceid = deviceid;
    
    return model;


}

@end
