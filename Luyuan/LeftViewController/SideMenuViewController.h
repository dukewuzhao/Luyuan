//
//  SideMenuViewController.h
//  RideHousekeeper
//
//  Created by Apple on 2017/8/22.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,DrawerType) {
    DrawerDefaultLeft = 1, // 默认动画，左侧划出
    DrawerDefaultRight,    // 默认动画，右侧滑出
    DrawerTypeMaskLeft,    // 遮盖动画，左侧划出
    DrawerTypeMaskRight    // 遮盖动画，右侧滑出
};

@interface SideMenuViewController : UIViewController
@property (nonatomic,assign) DrawerType drawerType; // 抽屉类型
@end
