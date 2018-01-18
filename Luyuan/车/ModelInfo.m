//
//  ModelInfo.m
//  RideHousekeeper
//
//  Created by smartwallit on 16/8/20.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "ModelInfo.h"

@implementation ModelInfo

+ (instancetype)modalWith:(NSInteger)bikeid modelid:(NSInteger)modelid modelname:(NSString *)modelname batttype:(NSInteger )batttype battvol:(NSInteger)battvol wheelsize:(NSInteger)wheelsize brandid:(NSInteger)brandid pictures:(NSString *)pictures pictureb:(NSString *)pictureb{


    ModelInfo *model = [[self alloc] init];
    model.bikeid = bikeid;
    model.modelid = modelid;
    model.modelname = modelname;
    model.batttype = batttype;
    model.battvol = battvol;
    model.wheelsize = wheelsize;
    model.brandid = brandid;
    model.pictures = pictures;
    model.pictureb = pictureb;
    
    
    return model;

}

@end
