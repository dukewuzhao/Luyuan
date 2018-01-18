//
//  PlainTableViewCell.h
//  RideHousekeeper
//
//  Created by Apple on 2017/12/28.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlainTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *cityLab;
@property (strong, nonatomic) UILabel *sizelabel;
@property (strong, nonatomic) UIImageView *down;
@property (strong, nonatomic) UIProgressView *processView;
@property (strong, nonatomic) UIButton *stopBtn;
@property (strong, nonatomic) UIButton *deleteBtn;
@end
