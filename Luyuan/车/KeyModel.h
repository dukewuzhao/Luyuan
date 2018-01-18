//
//  KeyModel.h
//  RideHousekeeper
//
//  Created by smartwallit on 16/8/11.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyModel : NSObject

@property (nonatomic, assign) NSInteger keyid;
@property (nonatomic, copy) NSString *keyname;
@property (nonatomic, copy) NSString *sn;
@property (nonatomic, assign) NSInteger deviceid;

+ (instancetype)modalWith:(NSInteger )keyid keyname:(NSString *)keyname sn:(NSString *)sn deviceid:(NSInteger)deviceid;

@end
