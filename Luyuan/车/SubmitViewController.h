//
//  SubmitViewController.h
//  RideHousekeeper
//
//  Created by smartwallit on 16/7/14.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SubmitViewController;
@protocol SubmitDelegate <NSObject>

@optional
-(void) addViewController:(SubmitViewController *) wuschool didAddString:(NSString *) nameText deviceTag:(NSInteger)deviceNum;

-(void) submitBegainUpgrate;

-(void) submitUnbundDevice;

@end

@interface SubmitViewController : BaseViewController

@property(nonatomic,assign) NSInteger deviceNum;
@property(nonatomic,weak) NSString* keystate;
@property (nonatomic,weak) id<SubmitDelegate> delegate;
@end


