//
//  AutomaticLockTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2017/12/29.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutomaticLockTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *Icon;
@property (strong, nonatomic) UILabel *nameLab;
@property (strong, nonatomic) UILabel *detailLab;
@property (strong, nonatomic) UISwitch *swit;
@end
