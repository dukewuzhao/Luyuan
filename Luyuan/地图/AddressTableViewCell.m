//
//  AddressTableViewCell.m
//  RideHousekeeper
//
//  Created by Apple on 2017/12/29.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "AddressTableViewCell.h"

@implementation AddressTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        _chooseLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width - 30, 20)];
        
        _chooseLabel.textColor = [UIColor blackColor];
        _chooseLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_chooseLabel];
        
        _adressLab = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_chooseLabel.frame), self.frame.size.width - 20, 30)];
        _adressLab.textColor = [QFTools colorWithHexString:@"#555555"];
        _adressLab.numberOfLines = 0;
        _adressLab.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_adressLab];
        
        
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
