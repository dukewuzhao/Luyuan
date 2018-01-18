//
//  IconView.m
//  ylss
//
//  Created by yons on 15/8/11.
//

#import "IconView.h"
#import "UIImage+HC.h"

@interface IconView ()

@property (nonatomic, strong) UIImageView  *iconImageView;

@end

@implementation IconView

@synthesize headImageView = _headImageView;

- (id)init
{
    if (self = [super init]) {
           // iconImage.png
        // 头像
        _headImageView = [[UIImageView alloc] init];
        _headImageView.backgroundColor = [UIColor clearColor];
        
        _headImageView.image = [UIImage imageNamed:@"default_man"];
            
        [self addSubview:_headImageView];
        
        
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    _headImageView.image = image;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setRect:frame];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self setRect:bounds];
}

- (void)setRect:(CGRect)rect
{
    self.layer.cornerRadius = rect.size.width * 0.5;
    self.layer.masksToBounds = YES;
    CGFloat WH = rect.size.width;
    _headImageView.center = CGPointMake(WH * 0.5, WH * 0.5);
    _headImageView.bounds = (CGRect){CGPointZero,{WH,WH}};
    _headImageView.layer.cornerRadius = _headImageView.bounds.size.width * 0.5;
    _headImageView.layer.masksToBounds = YES;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // 添加一个圆
    CGFloat pointXY = rect.size.width * 0.5;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor lightGrayColor] setStroke];
    CGContextSetLineWidth(context, 0);
    CGContextAddArc(context, pointXY, pointXY, pointXY - 3, 0, 2 * M_PI, 0);
    CGContextDrawPath(context, kCGPathStroke);
}


@end
