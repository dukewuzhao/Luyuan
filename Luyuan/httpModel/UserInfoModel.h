//
//  UserInfoModel.h
//  RideHousekeeper
//
//  Created by Apple on 2017/11/27.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoModel : NSObject

@property (assign, nonatomic) NSInteger user_id;
@property (copy, nonatomic) NSString* phone_num;
@property (copy, nonatomic) NSString* nick_name;
@property (copy, nonatomic) NSString* birthday;
@property (assign, nonatomic) NSInteger gender;
@property (copy, nonatomic) NSString* real_name;
@property (copy, nonatomic) NSString* id_card_no;
@property (copy, nonatomic) NSString* icon;
@property (copy, nonatomic) NSString* reg_time;

@end
