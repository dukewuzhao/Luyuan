//
//  SuccessInputFingerprint.m
//  RideHousekeeper
//
//  Created by Apple on 2017/11/21.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "SuccessInputFingerprint.h"

@implementation SuccessInputFingerprint

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor whiteColor];
        UIImageView *successImg = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth*.28, 75, ScreenWidth*.44, ScreenWidth*.44*1.48)];
        successImg.image = [UIImage imageNamed:@"fingerprint_step_three"];
        [self addSubview:successImg];
        
        UILabel *successLab = [[UILabel alloc] initWithFrame:CGRectMake(40, ScreenHeight- navHeight - 170, ScreenWidth - 80, 20)];
        successLab.textColor = [QFTools colorWithHexString:@"#111111"];
        successLab.textAlignment = NSTextAlignmentCenter;
        successLab.text = @"录入成功";
        [self addSubview:successLab];
        
        @weakify(self);
        UIButton *inputNext = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 80, CGRectGetMaxY(successLab.frame)+10, 160, 35)];
        [inputNext setTitle:@"录入下一个指纹" forState:UIControlStateNormal];
        [inputNext setTitleColor:[QFTools colorWithHexString:MainColor] forState:UIControlStateNormal];
        [[inputNext rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if([self.delegate respondsToSelector:@selector(InputFingerprintNext)])
            {
                [self.delegate InputFingerprintNext];
            }
        }];
//        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"查看所有中奖记录"];
//        NSRange strRange = {0,[str length]};
//        [str addAttribute:NSForegroundColorAttributeName value:[QFTools colorWithHexString:@"#06c1ae"] range:strRange];
//        [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
//        [inputNext setAttributedTitle:str forState:UIControlStateNormal];
        [self addSubview:inputNext];
        
        UIView *partingline = [[UIView alloc] initWithFrame:CGRectMake(inputNext.x+10, CGRectGetMaxY(inputNext.frame), inputNext.width - 20, 1.0)];
        partingline.backgroundColor = [QFTools colorWithHexString:MainColor];
        [self addSubview:partingline];
        
        UIButton *successBtn = [[UIButton alloc] initWithFrame:CGRectMake(25, CGRectGetMaxY(inputNext.frame)+30, ScreenWidth - 50, 45)];
        successBtn.backgroundColor = [UIColor redColor];
        [[successBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if([self.delegate respondsToSelector:@selector(InputFingerprintSuccess)])
            {
                [self.delegate InputFingerprintSuccess];
            }
        }];
        [successBtn setTitle:@"完成" forState:UIControlStateNormal];
        successBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [successBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        successBtn.backgroundColor = [QFTools colorWithHexString:MainColor];
        [successBtn.layer setCornerRadius:10.0]; // 切圆角
        [self addSubview:successBtn];
    }
    return self;
}

@end
