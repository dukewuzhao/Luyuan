//
//  FingerprintModel.m
//  RideHousekeeper
//
//  Created by Apple on 2017/11/23.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "FingerprintModel.h"

@implementation FingerprintModel

+ (instancetype)modalWith:(NSInteger )bikeid fp_id:(NSInteger )fp_id pos:(NSInteger )pos name:(NSString *)name added_time:(NSInteger)added_time {
    
    FingerprintModel *model = [[self alloc] init];
    model.bikeid = bikeid;
    model.fp_id = fp_id;
    model.pos = pos;
    model.name = name;
    model.added_time = added_time;
    
    return model;
}
@end
