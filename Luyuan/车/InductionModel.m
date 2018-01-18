//
//  InductionModel.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/9/26.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "InductionModel.h"

@implementation InductionModel

+ (instancetype)modalWith:(NSInteger )bikeid inductionValue:(NSInteger )inductionValue induction:(NSInteger )induction{

    InductionModel *model = [[self alloc] init];
    model.bikeid = bikeid;
    model.inductionValue = inductionValue;
    model.induction = induction;
    
    return model;

}

@end
