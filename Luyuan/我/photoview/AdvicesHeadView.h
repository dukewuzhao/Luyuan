//
//  advicesAdvicesHeadView.h
//  JinBang
//
//  Created by QFApple on 15/3/9.
//  Copyright (c) 2015年 qf365.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AdvicesHeadView;
@class IconView;

@protocol AdvicesHeadViewDelegate <NSObject>

- (void)AdvicesHeadView:(AdvicesHeadView *)AdvicesHeadView didClickIconView:(IconView *)iconView;

//- (void)AdvicesHeadView:(AdvicesHeadView *)AdvicesHeadView didClicktitleLabel:(UILabel *)titleLabel;
@end

@interface AdvicesHeadView : UIView

@property (nonatomic,weak) IconView *iconView; // 头像
@property (nonatomic,weak) UIImageView *backImage;

@property (nonatomic, unsafe_unretained) id<AdvicesHeadViewDelegate> delegate;

@end
