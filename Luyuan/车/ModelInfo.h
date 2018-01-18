//
//  ModelInfo.h
//  RideHousekeeper
//
//  Created by smartwallit on 16/8/20.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModelInfo : NSObject

@property (nonatomic, assign) NSInteger bikeid; //车辆内部id
@property (nonatomic, assign) NSInteger modelid;//自定义车辆名称
@property (nonatomic, copy) NSString *modelname;//主用户标志
@property (nonatomic, assign) NSInteger batttype;//硬件版本
@property (nonatomic, assign) NSInteger battvol;//固件版本
@property (nonatomic, assign) NSInteger wheelsize;//报警器mac地址
@property (nonatomic, assign) NSInteger brandid;//绑定用户数
@property (nonatomic, copy) NSString *pictures;//报警器mac地址
@property (nonatomic, copy) NSString *pictureb;//绑定用户数


+ (instancetype)modalWith:(NSInteger)bikeid modelid:(NSInteger)modelid modelname:(NSString *)modelname batttype:(NSInteger )batttype battvol:(NSInteger)battvol wheelsize:(NSInteger)wheelsize brandid:(NSInteger)brandid pictures:(NSString *)pictures pictureb:(NSString *)pictureb;

@end
