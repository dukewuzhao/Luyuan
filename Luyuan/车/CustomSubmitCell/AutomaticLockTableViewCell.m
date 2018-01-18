//
//  AutomaticLockTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2017/12/29.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "AutomaticLockTableViewCell.h"

@implementation AutomaticLockTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _Icon = [[UIImageView alloc] initWithFrame:CGRectMake(13, 7.5, 25, 25)];
        [self.contentView addSubview:_Icon];
        
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_Icon.frame)+15, 5, 80, 20)];
        _nameLab.textColor = [UIColor blackColor];
        _nameLab.textAlignment = NSTextAlignmentLeft;
        _nameLab.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_nameLab];
        
        _detailLab = [[UILabel alloc] initWithFrame:CGRectMake(_nameLab.x, CGRectGetMaxY(_nameLab.frame), 150, 15)];
        _detailLab.textColor = [UIColor blackColor];
        _detailLab.textAlignment = NSTextAlignmentLeft;
        _detailLab.font = [UIFont systemFontOfSize:8];
        [self.contentView addSubview:_detailLab];
        
        _swit = [[UISwitch alloc]initWithFrame:CGRectMake(ScreenWidth - 70, 5, 40, 25)];
        _swit.onTintColor = [QFTools colorWithHexString:MainColor];
        _swit.backgroundColor=[UIColor grayColor];
        _swit.thumbTintColor=[UIColor whiteColor];
        _swit.layer.masksToBounds = YES;
        _swit.layer.cornerRadius = 15;
        [self.contentView addSubview:_swit];
        
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
