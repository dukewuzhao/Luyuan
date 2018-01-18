//
//  BindingUserViewController.h
//  RideHousekeeper
//
//  Created by smartwallit on 16/8/26.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BindingUserViewControllerDelegate <NSObject>
@optional

-(void)UpdateUsernumberSuccess;

@end

@interface BindingUserViewController : BaseViewController

@property (nonatomic ,assign) NSInteger bikeid;
@property (nonatomic,weak) id<BindingUserViewControllerDelegate> delegate;
@end
