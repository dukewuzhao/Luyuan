//
//  QRViewController.h
//  SmartWallitAdv
//
//  Created by AlanWang on 15/8/4.
//  Copyright (c) 2015年 AlanWang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol TwoDimensionalCodecanDelegate <NSObject>

@optional
- (void)TwoDimensionalCodecanBidingKeySuccess;

@end

@interface TwoDimensionalCodecanViewController : BaseViewController

@property(nonatomic,assign) NSInteger deviceNum;
@property (nonatomic, weak) id<TwoDimensionalCodecanDelegate> delegate;
@end
