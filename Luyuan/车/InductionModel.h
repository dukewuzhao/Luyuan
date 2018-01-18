//
//  InductionModel.h
//  RideHousekeeper
//
//  Created by smartwallit on 16/9/26.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InductionModel : NSObject


@property (nonatomic, assign) NSInteger bikeid;
@property (nonatomic, assign) NSInteger inductionValue;
@property (nonatomic, assign) NSInteger induction;


+ (instancetype)modalWith:(NSInteger )bikeid inductionValue:(NSInteger )inductionValue induction:(NSInteger )induction;

@end
