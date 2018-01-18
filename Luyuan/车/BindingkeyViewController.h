//
//  BindingkeyViewController.h
//  RideHousekeeper
//
//  Created by smartwallit on 16/7/15.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BindingkeyDelegate <NSObject>

@required
- (void)bidingKeyOver;

@end

@interface BindingkeyViewController : BaseViewController

@property(nonatomic,assign) NSInteger deviceNum;
@property(nonatomic,assign) NSInteger seq;
@property(nonatomic,strong) NSString* keyversion;
@property (nonatomic, weak) id<BindingkeyDelegate> delegate;
@end

