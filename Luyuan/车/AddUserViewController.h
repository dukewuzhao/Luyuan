//
//  AddUserViewController.h
//  RideHousekeeper
//
//  Created by smartwallit on 16/8/26.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddUserViewControllerDelegate <NSObject>
@optional

-(void)  AddUserSuccess;

@end

@interface AddUserViewController : BaseViewController

@property (nonatomic,assign) NSInteger bikeId;
@property (nonatomic,weak) id<AddUserViewControllerDelegate> delegate;
@end
