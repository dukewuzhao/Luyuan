//
//  PeripheralModel.h
//  RideHousekeeper
//
//  Created by smartwallit on 16/8/22.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PeripheralModel : NSObject

@property (nonatomic, assign) NSInteger bikeid; //车辆内部id
@property (nonatomic, assign) NSInteger deviceid;//外设id
@property (nonatomic, assign) NSInteger type;//外设类型
@property (nonatomic, assign) NSInteger seq;//外设编号
@property (nonatomic, copy) NSString *mac;//mac地址
@property (nonatomic, copy) NSString *sn;//设备sn号
@property (nonatomic, copy) NSString *firmversion;//设备sn号

+ (instancetype)modalWith:(NSInteger)bikeid deviceid:(NSInteger)deviceid type:(NSInteger)type seq:(NSInteger)seq mac:(NSString *)mac sn:(NSString *)sn firmversion:(NSString *)firmversion;

@end
