//
//  InduckeyModel.m
//  RideHousekeeper
//
//  Created by Apple on 2017/2/6.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "InduckeyModel.h"

@implementation InduckeyModel

+ (instancetype)modalWith:(NSInteger )bikeid induckeyValue:(NSInteger )induckeyValue {
    
    InduckeyModel *model = [[self alloc] init];
    model.bikeid = bikeid;
    model.induckeyValue = induckeyValue;
    
    return model;
    
}

@end
