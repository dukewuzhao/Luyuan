//
//  FaultModel.h
//  RideHousekeeper
//
//  Created by Apple on 2017/7/12.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FaultModel : NSObject

@property(nonatomic, assign) NSInteger motorfault;//电机故障
@property(nonatomic, assign) NSInteger rotationfault;
@property(nonatomic, assign) NSInteger controllerfault;
@property(nonatomic, assign) NSInteger brakefault;
@property(nonatomic, assign) NSInteger lackvoltage;
@property(nonatomic, assign) NSInteger motordefectNum;

@end
