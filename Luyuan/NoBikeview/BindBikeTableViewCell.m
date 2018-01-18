//
//  BindBikeTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2017/12/29.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "BindBikeTableViewCell.h"

@implementation BindBikeTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _Icon  = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 25, 25)];
        [self.contentView addSubview:_Icon];
        
        _IntelligenceBike = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_Icon.frame)+25, 12.5, 100, 20)];
        _IntelligenceBike.textAlignment = NSTextAlignmentLeft;
        _IntelligenceBike.textColor = [UIColor blackColor];
        _IntelligenceBike.font = [UIFont systemFontOfSize:17];
        _IntelligenceBike.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_IntelligenceBike];
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
