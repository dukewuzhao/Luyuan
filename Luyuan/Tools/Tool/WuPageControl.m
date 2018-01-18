//
//  WuPageControl.m
//  RideHousekeeper
//
//  Created by Apple on 2017/9/1.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "WuPageControl.h"

@implementation WuPageControl

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

- (void) setCurrentPage:(NSInteger)page {
    [super setCurrentPage:page];
    for (NSUInteger subviewIndex = 0; subviewIndex < [self.subviews count]; subviewIndex++) {
        UIImageView* subview = [self.subviews objectAtIndex:subviewIndex];
        CGSize size;
        if (subviewIndex == page) {
            size.height = 8;
            size.width = 8;
            [subview setFrame:CGRectMake(subview.frame.origin.x, subview.frame.origin.y, size.width,size.height)];
            subview.layer.masksToBounds = YES;
            subview.layer.cornerRadius = size.width/2;
            [subview setBackgroundColor:[QFTools colorWithHexString:@"#31d9c9"]];
        } else {
            [subview setBackgroundColor:[UIColor colorWithRed:49/255.0 green:217/255.0 blue:201/255.0 alpha:0.5f]];
        }
    }
}
@end
