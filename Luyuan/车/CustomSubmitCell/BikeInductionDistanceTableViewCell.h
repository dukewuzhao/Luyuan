//
//  BikeInductionDistanceTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2017/12/29.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LianUISlider.h"
@interface BikeInductionDistanceTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *Icon;
@property (strong, nonatomic) UILabel *nameLab;
@property (strong, nonatomic) UISwitch *swit;
@property (strong, nonatomic) LianUISlider *slider;
@property (strong, nonatomic) UILabel *weak;
@property (strong, nonatomic) UILabel *strong;

@end
