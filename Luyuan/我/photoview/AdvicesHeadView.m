//
//  advicesHeadView.m
//  JinBang
//
//  Created by QFApple on 15/3/9.
//

#import "AdvicesHeadView.h"
#import "IconView.h"

@interface AdvicesHeadView ()

@property (nonatomic,strong) UILabel *titleLabel; // 头像名
@property (nonatomic,weak) UIView *divider;  // 分割线
@property (nonatomic,weak) UIImageView *arrows;  // 箭头

@end

@implementation AdvicesHeadView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        // 头像
        IconView *iconView = [[IconView alloc] init];
        iconView.backgroundColor = [QFTools colorWithHexString:@"#1da3d0"];
        iconView.backgroundColor = [QFTools colorWithHexString:@"#eaeaea"];
        [self addSubview:iconView];
        self.iconView = iconView;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconClick)];
        [iconView addGestureRecognizer:tap];
        

    
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.width = ScreenWidth;

    self.iconView.bounds = (CGRect){CGPointZero,{ScreenHeight * 0.18,ScreenHeight * 0.18}};
    self.iconView.x = (self.width - self.iconView.width) * 0.5;
    self.iconView.y = 40;
    
    self.titleLabel.x = 0;
    self.titleLabel.width = ScreenWidth;
    self.titleLabel.height = 20;
    self.titleLabel.y =CGRectGetMaxY(self.iconView.frame) + 10;
    
    }

#pragma mark - 头像点击
- (void)iconClick
{
    if ([self.delegate respondsToSelector:@selector(AdvicesHeadView:didClickIconView:)]) {
        [self.delegate AdvicesHeadView:self didClickIconView:self.iconView];
    }
}

//- (void)labelTap
//{
//    if ([self.delegate respondsToSelector:@selector(AdvicesHeadView:didClicktitleLabel:)]) {
//        [self.delegate AdvicesHeadView:self didClicktitleLabel:self.titleLabel];
//    }
//}

@end
