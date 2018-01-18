//
//  switchView.m
//  MaintenanceArtisan
//
//  Created by 黄辰 on 15-4-14.
//  Copyright (c) 2015年 Huo. All rights reserved.
//

#import "switchView.h"
#import "HCButton.h"
#import "UIView+Extension.h"

@interface switchView()

@property (nonatomic,weak) HCButton *selectBtn;

@end

@implementation switchView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self.layer setMasksToBounds:YES];
        [self.layer setCornerRadius:5.0]; //设置矩形四个圆角半径
        [self.layer setBorderWidth:1]; //边框宽框
        self.layer.borderColor = [[QFTools colorWithHexString:@"#ffffff"] CGColor];
    }
    return self;
}

#pragma mark - 创建按钮
- (void)setItems:(NSArray *)items
{
    _items = items;
    // 创建对应个数的按钮
    NSUInteger count = _items.count;
    for (int i = 0; i < count; i++) {
        HCButton *btn = [[HCButton alloc] init];
        btn.tag = i + 20;
        
        // 设置按钮属性
        [btn setTitle:items[i] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:btn];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
    }
}

#pragma mark - 设置按钮Frame
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSUInteger count = self.subviews.count;
    
    CGFloat btnW = self.width / count;
    CGFloat btnH = self.height;
    CGFloat btnY = 0;
    for (int i = 0; i < count; i++) {
        HCButton *btn = self.subviews[i];
        btn.x = i * btnW;
        btn.y = btnY;
        btn.width = btnW;
        btn.height = btnH;
    }
}

#pragma mark - 按钮点击
- (void)btnClick:(HCButton *)button
{
    self.selectBtn.selected = NO;
    self.selectBtn.backgroundColor = [UIColor clearColor];
    self.selectBtn.titleLabel.textColor = [QFTools colorWithHexString:MainColor];
    button.selected = YES;
    button.backgroundColor = [QFTools colorWithHexString:@"#ffffff"];
    self.selectBtn = button;
    
    if ([self.delegate respondsToSelector:@selector(switchView:DidBtnClick:)]) {
        [self.delegate switchView:self DidBtnClick:button];
    }
}

#pragma mark - 使传入的对应索引数的按钮选中
- (void)setSelectedSegmentIndex:(int)selectedSegmentIndex
{
    if (selectedSegmentIndex < 0 || selectedSegmentIndex >= self.subviews.count) return;
    
    HCButton *btn = self.subviews[selectedSegmentIndex];
    [self btnClick:btn];
}

#pragma mark - 获得选中按钮的索引数
- (int)selectedSegmentIndex
{
    return (int)self.selectBtn.tag;
}

@end
