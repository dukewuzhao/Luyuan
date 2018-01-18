//
//  LianUISlider.m
//  RideHousekeeper
//
//  Created by Apple on 2017/8/29.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "LianUISlider.h"

@implementation LianUISlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value{
    
    rect.origin.x = rect.origin.x - 10 ;
    
    rect.size.width = rect.size.width +20;
    
    return CGRectInset ([super thumbRectForBounds:bounds trackRect:rect value:value], 10 , 10);
    
}

@end
