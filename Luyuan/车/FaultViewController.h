//
//  FaultViewController.h
//  RideHousekeeper
//
//  Created by smartwallit on 16/9/3.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FaultViewController : BaseViewController

@property(nonatomic, assign) NSInteger motorfaultNum;//电机故障
@property(nonatomic, assign) NSInteger rotationfaultNum;//转把故障
@property(nonatomic, assign) NSInteger controllerfaultNum;//控制器故障
@property(nonatomic, assign) NSInteger brakefaultNum;//刹车故障
@property(nonatomic, assign) NSInteger lackvoltageNum;//电池欠压
@property(nonatomic, assign) NSInteger motordefectNum;//电机缺陷故障

@end
