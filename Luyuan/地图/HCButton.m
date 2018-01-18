//
//  HCButton.m
//  57-ipad(QQ空间)
//
//  Created by 黄辰 on 14-8-25.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "HCButton.h"
#define FONT_YAHEI(s) [UIFont fontWithName:@"MicrosoftYahei" size:s]
@implementation HCButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitleColor:[QFTools colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
        [self setTitleColor:[QFTools colorWithHexString:MainColor] forState:UIControlStateSelected];
        self.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = FONT_YAHEI(12);
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted{}

@end
