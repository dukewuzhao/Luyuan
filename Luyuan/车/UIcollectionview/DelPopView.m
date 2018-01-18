//
//  DelPopView.m
//  UICollectionViewDemo1
//
//  Created by Apple on 2017/11/10.
//  Copyright © 2017年 BG. All rights reserved.
//

#import "DelPopView.h"
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface DelPopView ()

@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, strong) UIButton *delBtn;
@property (nonatomic, assign) NSInteger selectTag;
@property (nonatomic, assign) NSInteger deviceId;
@end

@implementation DelPopView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithorigin:(CGPoint)origin width:(CGFloat)width height:(CGFloat)height tag:(NSInteger)tag deviceId:(NSInteger)deviceId{
    if (self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)]) {
        //背景色为clearColor
        self.backgroundColor = [UIColor clearColor];
        self.origin = origin;
        self.height = height;
        self.width = width;
        self.selectTag = tag;
        self.deviceId = deviceId;
        self.delBtn = [[UIButton alloc] initWithFrame:CGRectMake(origin.x, origin.y, width, height)];
        [self.delBtn setTitle:@"删除" forState:UIControlStateNormal];
        [self.delBtn setBackgroundColor:[UIColor blackColor]];
        self.delBtn.layer.cornerRadius = 5;
        [self.delBtn addTarget:self action:@selector(delBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.delBtn];
    }
    return self;
}

//画出尖尖
- (void)drawRect:(CGRect)rect {
    //拿到当前视图准备好的画板
    CGContextRef context = UIGraphicsGetCurrentContext();
    //利用path进行绘制三角形
    CGContextBeginPath(context);//标记
    CGFloat startX = self.origin.x + self.width/2 - 5;
    CGFloat startY = self.origin.y +self.height;
    CGContextMoveToPoint(context, startX, startY);//设置起点
    
    CGContextAddLineToPoint(context, startX + 5, startY + 5);
    
    CGContextAddLineToPoint(context, startX + 10, startY);
    CGContextClosePath(context);//路径结束标志，不写默认封闭
    [self.delBtn.backgroundColor setFill]; //设置填充色
    [self.delBtn.backgroundColor setStroke];
    CGContextDrawPath(context, kCGPathFillStroke);//绘制路径path
}

- (void)pop {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    //动画效果弹出
    self.alpha = 0;
    CGRect frame = self.delBtn.frame;
    self.delBtn.frame = CGRectMake(self.origin.x, self.origin.y, 0, 0);
    self.alpha = 1;
    self.delBtn.frame = frame;
    [UIView animateWithDuration:0.2 animations:^{
//        self.alpha = 1;
//        self.delBtn.frame = frame;
    }];
}

- (void)dismiss {
    //动画效果淡出
    self.alpha = 0;
    self.delBtn.frame = CGRectMake(self.origin.x, self.origin.y, 0, 0);
    [UIView animateWithDuration:0.2 animations:^{
//        self.alpha = 0;
//        self.delBtn.frame = CGRectMake(self.origin.x, self.origin.y, 0, 0);
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
            if (self.dismissOperation) {
                self.dismissOperation();
            }
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (![touch.view isEqual:self.delBtn]) {
        [self dismiss];
    }
}

-(void)delBtnClick:(id *)sender{
    
    if ([self.delegate respondsToSelector:@selector(didSelectedAtIndexPath: :)]) {
        [self.delegate didSelectedAtIndexPath:self.selectTag :self.deviceId];
    }
    [self dismiss];
}

@end
