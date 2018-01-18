//
//  TFSheetView.m
//  RideHousekeeper
//
//  Created by Apple on 2017/8/29.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "TFSheetView.h"

@interface TFSheetView()
{
    UIView *_mainView;
    UIView *_contentView;
}

@end

@implementation TFSheetView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame])
    {
        [self initContent];
    }
    
    return self;
}

- (void)initContent
{
    self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    
    _mainView = [[UIView alloc]initWithFrame:self.frame];
    
    //alpha 0.0  白色   alpha 1 ：黑色   alpha 0～1 ：遮罩颜色，逐渐
    _mainView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _mainView.userInteractionEnabled = YES;
    [_mainView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disMissView)]];
    
    if (_contentView == nil)
    {
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 90, ScreenWidth, 90)];
        _contentView.backgroundColor = [UIColor whiteColor];
        [_mainView addSubview:_contentView];
    }
}

- (void)loadMaskView
{
}



//展示从底部向上弹出的UIView（包含遮罩）
- (void)showInView:(UIView *)view
{
    if (!view)
    {
        return;
    }
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:_mainView];
    [_mainView addSubview:_contentView];
    
    UIView *man = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 45)];
    [_contentView addSubview:man];
    man.userInteractionEnabled = YES;
    UITapGestureRecognizer *manTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sexChooseClicked:)];
    manTap.numberOfTapsRequired = 1;
    man.tag = 70;
    [man addGestureRecognizer:manTap];
    
    
    [_contentView setFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 90)];
    
    UIImageView *manImg = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 32.5, 10, 25, 25)];
    manImg.image = [UIImage imageNamed:@"man"];
    [man addSubview:manImg];
    
    UILabel *manLab = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth/2 + 7.5, 12.5, 100, 20)];
    manLab.textColor = [UIColor blackColor];
    manLab.text = @"男";
    [man addSubview:manLab];
    
    UIView *women = [[UIView alloc] initWithFrame:CGRectMake(0, 45, ScreenWidth, 45)];
    [_contentView addSubview:women];
    women.userInteractionEnabled = YES;
    UITapGestureRecognizer *womenTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sexChooseClicked:)];
    womenTap.numberOfTapsRequired = 1;
    women.tag = 71;
    [women addGestureRecognizer:womenTap];
    
    UIImageView *womenImg = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth/2 - 32.5, 10, 25, 25)];
    womenImg.image = [UIImage imageNamed:@"women"];
    [women addSubview:womenImg];
    
    UILabel *womenLab = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth/2 + 7.5, 12.5, 100, 20)];
    womenLab.textColor = [UIColor blackColor];
    womenLab.text = @"女";
    [women addSubview:womenLab];
    
    UIView *partingline = [[UIView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(man.frame), ScreenWidth - 10, 0.5)];
    partingline.backgroundColor = [QFTools colorWithHexString:@"#cccccc"];
    [_contentView addSubview:partingline];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.alpha = 1.0;
        
        [_contentView setFrame:CGRectMake(0, ScreenHeight - 90, ScreenWidth, 90)];
        
    } completion:nil];
}

//移除从上向底部弹下去的UIView（包含遮罩）
- (void)disMissView
{
    [_contentView setFrame:CGRectMake(0, ScreenHeight - 90, ScreenWidth, 90)];
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         _mainView.alpha = 0.0;
                         
                         [_contentView setFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 90)];
                     }
                     completion:^(BOOL finished){
                         
                         [_mainView removeFromSuperview];
                         [_contentView removeFromSuperview];
                         
                     }];
    
}

- (void)sexChooseClicked:(UITapGestureRecognizer *)gesture {
    
    
    if ([gesture view].tag == 70) {
        
        if ([self.delegate respondsToSelector:@selector(TFSheetViewchooseSex:)]) {
            [self.delegate TFSheetViewchooseSex:@"男"];
        }
        
        [self disMissView];
    
    }else if ([gesture view].tag == 71) {
        
        if ([self.delegate respondsToSelector:@selector(TFSheetViewchooseSex:)]) {
            [self.delegate TFSheetViewchooseSex:@"女"];
        }
        [self disMissView];
        
    }
    
}

@end
