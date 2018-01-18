//
//  PeripheralUUIDModel.h
//  RideHousekeeper
//
//  Created by smartwallit on 16/10/19.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PeripheralUUIDModel : NSObject

@property (nonatomic, copy) NSString * username; //用户手机号码
@property (nonatomic, assign) NSInteger bikeid;//外设id
@property (nonatomic, copy) NSString *mac;//mac地址
@property (nonatomic, copy) NSString *uuid;//设备的uuid

+ (instancetype)modalWith:(NSString *)username bikeid:(NSInteger )bikeid mac:(NSString *)mac uuid:(NSString *)uuid;

@end
