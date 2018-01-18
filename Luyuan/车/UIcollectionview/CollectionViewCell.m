//
//  CollectionViewCell.m
//  UICollectionViewDemo1
//
//  Created by user on 15/11/2.
//  Copyright © 2015年 BG. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _icon  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, 65, 65)];
        [self.contentView addSubview:_icon];
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(-10, CGRectGetMaxY(_icon.frame)+10, 85, 20)];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.font = [UIFont systemFontOfSize:15];
        _textLabel.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_textLabel];
        
//        _del = [[UIButton alloc] initWithFrame:CGRectMake(10,0, 45, 30)];
//        _del.backgroundColor = [UIColor blackColor];
//        [self.contentView addSubview:_del];
    }
    
    return self;
}



@end
