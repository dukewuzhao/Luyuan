//
//  bikeFunctionTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2017/12/29.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "bikeFunctionTableViewCell.h"

@implementation bikeFunctionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _Icon = [[UIImageView alloc] initWithFrame:CGRectMake(13, 7.5, 25, 25)];
        [self.contentView addSubview:_Icon];
        
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_Icon.frame)+15, 10, 80, 20)];
        _nameLab.textColor = [UIColor blackColor];
        _nameLab.textAlignment = NSTextAlignmentLeft;
        _nameLab.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_nameLab];
        
        _detailLab = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 160, 10, 135, 20)];
        _detailLab.textAlignment = NSTextAlignmentRight;
        _detailLab.font = [UIFont systemFontOfSize:13];
        _detailLab.textColor = [QFTools colorWithHexString:@"999999"];
        [self.contentView addSubview:_detailLab];
        
        _arrow = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 20, 12.5, 8.4, 15)];
        _arrow.image = [UIImage imageNamed:@"arrow"];
        [self.contentView addSubview:_arrow];
        
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
