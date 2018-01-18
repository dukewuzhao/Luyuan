//
//  MyViewController.h
//  阿尔卑斯
//
//  Created by 同时科技 on 16/3/28.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import "HCTextView.h"

@interface HCTextView()

@property (nonatomic,weak) UILabel *placeholderLabel;

@end
@implementation HCTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer setCornerRadius:8];
        self.font = [UIFont systemFontOfSize:15];
        UILabel *label = [[UILabel alloc] init];
        [self addSubview:label];
        label.font = self.font;
        label.numberOfLines = 0;
        label.y = 10;
        label.textColor = [QFTools colorWithHexString:@"#CCCCCC"];
        self.placeholderLabel = label;

        // 注册一个通知, 当textview文本发生变化的时候就会发送通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(placeholderLabelChange) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

#pragma mark - 接收到通知消息后执行的方法
- (void)placeholderLabelChange
{
    self.placeholderLabel.hidden = self.text.length;
}

#pragma mark - 视图消失取消通知
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 计算提示Label的Frame
- (void)layoutSubviews
{
    [super layoutSubviews];
    self.placeholderLabel.x = 16;
    self.placeholderLabel.y = 8;
    CGSize MaxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 50, MAXFLOAT);
  //  self.placeholderLabel.size = [self.placeholderLabel.text sizeWithFont:self.font constrainedToSize:MaxSize];
    self.placeholderLabel.size = [QFTools boundingRectWithSize:self.placeholderLabel.text Font:[UIFont systemFontOfSize:15] Size:MaxSize];
}

#pragma mark - 重写提示属性的set方法
- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    self.placeholderLabel.text = _placeholder;
}

@end
