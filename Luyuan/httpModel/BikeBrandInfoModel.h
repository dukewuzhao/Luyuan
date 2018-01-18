//
//  BikeBrandInfoModel.h
//  RideHousekeeper
//
//  Created by Apple on 2017/11/27.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BikeBrandInfoModel : NSObject

@property (assign, nonatomic) NSInteger brand_id;
@property (copy, nonatomic) NSString* brand_name;
@property (copy, nonatomic) NSString* logo;

@end
