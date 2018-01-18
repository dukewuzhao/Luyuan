//
//  FingerprintModel.h
//  RideHousekeeper
//
//  Created by Apple on 2017/11/23.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FingerprintModel : NSObject

@property (nonatomic, assign) NSInteger bikeid;//外设id
@property (nonatomic, assign) NSInteger fp_id;//指纹id
@property (nonatomic, assign) NSInteger pos;//硬件指纹序列id
@property (nonatomic, copy) NSString *name;//指纹名称
@property (nonatomic, assign) NSInteger added_time;//时间

+ (instancetype)modalWith:(NSInteger )bikeid fp_id:(NSInteger )fp_id pos:(NSInteger )pos name:(NSString *)name added_time:(NSInteger)added_time;

@end
