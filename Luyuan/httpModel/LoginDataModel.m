//
//  LoginDataModel.m
//  TaiwanIntelligence
//
//  Created by Apple on 2017/11/30.
//  Copyright © 2017年 DUKE.Wu. All rights reserved.
//

#import "LoginDataModel.h"

@implementation LoginDataModel

//把数组里面带有对象的类型专门按照这个方法，这个格式写出来*****
+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass{
    
    return @{
             @"bike_info" : BikeInfoModel.class, // @"statuses" : [MJStatus class],
             };
}

@end
