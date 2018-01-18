//
//  BikeNameTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2017/12/29.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "BikeNameTableViewCell.h"

@implementation BikeNameTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _bikeimage = [[UIImageView alloc] initWithFrame:CGRectMake(10, (ScreenHeight *.13 +5)/2 - 25, 50, 50)];
        _bikeimage.layer.masksToBounds = YES;
        _bikeimage.layer.cornerRadius = 25;
        _bikeimage.image = [UIImage imageNamed:@"default_logo"];
        [self.contentView addSubview:_bikeimage];
        
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_bikeimage.frame) + 25, _bikeimage.y, 150, 20)];
        _nameLab.font = [UIFont systemFontOfSize:16];
        _nameLab.textColor = [UIColor blackColor];
        [self.contentView addSubview:_nameLab];
        
        _usericon = [[UIImageView alloc] initWithFrame:CGRectMake(_nameLab.x, CGRectGetMaxY(_nameLab.frame)+10, 15, 15)];
        [self.contentView addSubview:_usericon];
        
        _phone = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_usericon.frame) + 5, _usericon.y, 100, 15)];
        _phone.textColor = [QFTools colorWithHexString:@"999999"];
        _phone.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_phone];
        
        _modifyBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 60, (ScreenHeight *.13 +5)/2 - 25, 50, 50)];
        [self.contentView addSubview:_modifyBtn];
        
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
