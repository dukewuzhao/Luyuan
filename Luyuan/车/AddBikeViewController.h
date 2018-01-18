//
//  AddBikeViewController.h
//  RideHousekeeper
//
//  Created by smartwallit on 16/7/12.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AddBikeDelegate <NSObject>

@optional

-(void)bidingBikeSuccess;

@end
@interface AddBikeViewController : BaseViewController

@property (nonatomic,weak) id<AddBikeDelegate> delegate;

@end
