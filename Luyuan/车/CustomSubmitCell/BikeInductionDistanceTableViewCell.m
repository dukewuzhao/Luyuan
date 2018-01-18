//
//  BikeInductionDistanceTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2017/12/29.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "BikeInductionDistanceTableViewCell.h"

@implementation BikeInductionDistanceTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _Icon = [[UIImageView alloc] initWithFrame:CGRectMake(13, 7.5, 25, 25)];
        _Icon.image = [UIImage imageNamed:@"icon_p4"];
        [self.contentView addSubview:_Icon];
        
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_Icon.frame)+15, 10, 80, 20)];
        _nameLab.textColor = [UIColor blackColor];
        _nameLab.textAlignment = NSTextAlignmentLeft;
        _nameLab.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_nameLab];
        
        _swit = [[UISwitch alloc]initWithFrame:CGRectMake(ScreenWidth - 70, 5, 40, 25)];
        _swit.onTintColor = [QFTools colorWithHexString:MainColor];
        _swit.backgroundColor=[UIColor grayColor];
        _swit.thumbTintColor=[UIColor whiteColor];
        _swit.layer.masksToBounds = YES;
        _swit.layer.cornerRadius = 15;
        [self.contentView addSubview:_swit];
        
        _slider = [[LianUISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_Icon.frame) + 20, CGRectGetMaxY(_nameLab.frame)+10, self.frame.size.width - 120, 20)];
        _slider.minimumTrackTintColor=[UIColor whiteColor];
        _slider.thumbTintColor=[UIColor whiteColor];
        [_slider setThumbImage:[UIImage imageNamed:@"slideimage"] forState:UIControlStateHighlighted];
        [_slider setThumbImage:[UIImage imageNamed:@"slideimage"] forState:UIControlStateNormal];
        [_slider setMinimumTrackImage:[UIImage imageNamed:@"max"] forState:UIControlStateNormal];
        [_slider setMaximumTrackImage:[UIImage imageNamed:@"min"] forState:UIControlStateNormal];
        [self.contentView addSubview:_slider];
        
        _weak = [[UILabel alloc] initWithFrame:CGRectMake(_slider.x, CGRectGetMaxY(_slider.frame), 40, 15)];
        _strong.text = @"近";
        _weak.textAlignment = NSTextAlignmentCenter;
        _weak.textColor = [UIColor blackColor];
        _weak.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_weak];
        
        _strong = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_slider.frame)- 40, CGRectGetMaxY(_slider.frame), 40, 15)];
        _strong.text = @"远";
        _strong.textColor = [UIColor blackColor];
        _strong.font = [UIFont systemFontOfSize:13];
        _strong.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_strong];
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
