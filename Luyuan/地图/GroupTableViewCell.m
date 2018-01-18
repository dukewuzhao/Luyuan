//
//  GroupTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2017/12/28.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "GroupTableViewCell.h"

@implementation GroupTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _cityLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 150, 20)];
        _cityLab.textAlignment = NSTextAlignmentLeft;
        _cityLab.textColor = [UIColor blackColor];
        _cityLab.font = [UIFont systemFontOfSize:16];
        _cityLab.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_cityLab];
        
        _sizelabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 125, 10, 100, 20)];
        _sizelabel.textAlignment = NSTextAlignmentCenter;
        _sizelabel.textColor = [UIColor blackColor];
        _sizelabel.font = [UIFont systemFontOfSize:13];
        _sizelabel.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_sizelabel];
        
        _down  = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 25, 12.5, 15, 15)];
        [self.contentView addSubview:_down];
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
