//
//  AutomaticLockModel.h
//  RideHousekeeper
//
//  Created by Apple on 2017/8/28.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AutomaticLockModel : NSObject
@property (nonatomic, assign) NSInteger bikeid;
@property (nonatomic, assign) NSInteger automaticlock;


+ (instancetype)modalWith:(NSInteger )bikeid automaticlock:(NSInteger )automaticlock ;
@end
