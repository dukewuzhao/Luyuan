//
//  TFSheetView.h
//  RideHousekeeper
//
//  Created by Apple on 2017/8/29.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFSheetView;

@protocol TFSheetViewDelegate <NSObject>

- (void)TFSheetViewchooseSex:(NSString *)sexLab;

@end


@interface TFSheetView : UIView

- (void)showInView:(UIView *)view ;

@property (nonatomic, weak) id<TFSheetViewDelegate> delegate;

@end
