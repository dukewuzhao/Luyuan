//
//  BottomBtn.m
//  ylss
//
//  Created by yons on 15/8/15.
//  Copyright (c) 2015年 yfapp. All rights reserved.
//

#import "BottomBtn.h"

@implementation BottomBtn

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.titleLabel.font = FONT_YAHEI(12);
    }
    return self;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleX,titleW,titleH,titleY;
    
    if ([self.direction isEqualToString:@"left"]) {
        titleX = 30;
        titleW = self.width - 30;
        titleH = 20;
        titleY = (self.height - titleH) * 0.5;
    }else{
        
        titleX = 5;
        titleW = self.width - 30;
        titleH = 20;
        titleY = (self.height - titleH) * 0.5;
    }
    
    return CGRectMake(titleX, titleY, titleW, titleH);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageX,imageY,imageW,imageH;
    if ([self.direction isEqualToString:@"left"]) {
        imageW = 20;
        imageH = 20;
        imageX = 5;
        imageY = (self.height - imageH) * 0.5;
    }else{
        
        imageW = 20;
        imageH = 20;
        imageX = self.width - 30;
        imageY = (self.height - imageH) * 0.5;
    }
    
    
    
    return CGRectMake(imageX, imageY, imageW, imageH);
}

@end
