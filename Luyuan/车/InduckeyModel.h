//
//  InduckeyModel.h
//  RideHousekeeper
//
//  Created by Apple on 2017/2/6.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InduckeyModel : NSObject

@property (nonatomic, assign) NSInteger bikeid;
@property (nonatomic, assign) NSInteger induckeyValue;


+ (instancetype)modalWith:(NSInteger )bikeid induckeyValue:(NSInteger )induckeyValue ;

@end
