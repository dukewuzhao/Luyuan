//
//  switchView.h
//  MaintenanceArtisan
//
//  Created by 黄辰 on 15-4-14.
//  Copyright (c) 2015年 Huo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class switchView;

@protocol switchViewDelegate <NSObject>

- (void)switchView:(switchView *)switchView DidBtnClick:(UIButton *)btn;

@end

@interface switchView : UIView

/** 按钮个数，按钮文字 */
@property (nonatomic,strong) NSArray *items;

/** 点击按钮的索引 */
@property (nonatomic,assign) int selectedSegmentIndex;

@property (nonatomic, weak) id<switchViewDelegate> delegate;

@end
