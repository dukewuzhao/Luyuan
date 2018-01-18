//
//  FingerModel.h
//  RideHousekeeper
//
//  Created by Apple on 2017/11/28.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FingerModel : NSObject

@property (assign, nonatomic) NSInteger fp_id;
@property (copy, nonatomic) NSString* name;
@property (assign, nonatomic) NSInteger pos;
@property (assign, nonatomic) NSInteger added_time;

@end
