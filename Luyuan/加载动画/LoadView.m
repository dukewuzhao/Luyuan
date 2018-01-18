//
//  LoadView.m
//  RideHousekeeper
//
//  Created by Apple on 2017/2/18.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "LoadView.h"
#import "AView.h"
#import "UIView+i7Rotate360.h"

@interface LoadView()

@property(nonatomic, retain)UIView *midview;


@end

@implementation LoadView
@synthesize protetitle,undery,leftx,midview;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        
        UIView *loading = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        loading.backgroundColor = [UIColor clearColor];
        [self addSubview:loading];
        
        midview = [[UIView alloc] initWithFrame:CGRectMake(leftx, self.center.y - undery, self.size.width - leftx*2, 40)];
        midview.layer.masksToBounds = YES;
        midview.layer.cornerRadius = 10;
        midview.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        [loading addSubview:midview];
        
        AView *aView = [[AView alloc] initWithImage:[UIImage imageNamed:@"toast_loading.png"]];
        aView.frame = CGRectMake(10,5,30,30);
        aView.userInteractionEnabled = YES;
        [aView rotate360WithDuration:1.0 repeatCount:HUGE_VALF timingMode:i7Rotate360TimingModeLinear];
        [midview addSubview:aView];
        
        protetitle = [[UILabel alloc]  initWithFrame:CGRectMake(CGRectGetMaxX(aView.frame) + 10, 10, midview.width - 50, 20)];
        protetitle.textColor = [UIColor whiteColor];
        protetitle.textAlignment = NSTextAlignmentCenter;
        [midview addSubview:protetitle];
        
    }
    return self;
}

- (void)layoutSubviews {

    if (undery == 0) {
        
        undery = 20;
        
    }
    
    if (leftx == 0) {
        
        leftx = ScreenWidth *.25;
        
    }

    midview.frame = CGRectMake(leftx, self.center.y - undery, self.size.width - leftx*2, 40);
    protetitle.frame = CGRectMake(50, 10, midview.width - 50, 20);
}


@end
