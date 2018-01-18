//
//  LoginDataModel.h
//  TaiwanIntelligence
//
//  Created by Apple on 2017/11/30.
//  Copyright © 2017年 DUKE.Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginDataModel : NSObject

@property (copy, nonatomic) NSString* token;
@property (strong, nonatomic) UserInfoModel* user_info;
@property (strong, nonatomic) NSMutableArray* bike_info;
@property (copy, nonatomic) NSString* default_brand_logo;
@property (copy, nonatomic) NSString* default_model_picture;


@end
