//
//  AutomaticLockModel.m
//  RideHousekeeper
//
//  Created by Apple on 2017/8/28.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "AutomaticLockModel.h"

@implementation AutomaticLockModel

+ (instancetype)modalWith:(NSInteger )bikeid automaticlock:(NSInteger )automaticlock {
    
    AutomaticLockModel *model = [[self alloc] init];
    model.bikeid = bikeid;
    model.automaticlock = automaticlock;
    
    return model;
    
}

@end
