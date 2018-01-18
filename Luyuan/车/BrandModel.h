//
//  BrandModel.h
//  RideHousekeeper
//
//  Created by smartwallit on 16/8/20.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BrandModel : NSObject

@property (nonatomic, assign) NSInteger bikeid; //车辆内部id
@property (nonatomic, assign) NSInteger brandid;//自定义车辆名称
@property (nonatomic, copy) NSString *brandname;//主用户标志
@property (nonatomic, copy) NSString *logo;//产品logo


+ (instancetype)modalWith:(NSInteger)bikeid brandid:(NSInteger)brandid brandname:(NSString *)brandname logo:(NSString *)logo;

@end
