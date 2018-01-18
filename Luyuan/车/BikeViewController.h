//
//  BikeViewController.h
//  RideHousekeeper
//
//  Created by 同时科技 on 16/6/20.
//  Copyright © 2016年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FileTypeViewController.h"
#import "DFUOperations.h"
@interface BikeViewController :BaseViewController<FileTypeSelectionDelegate, DFUOperationsDelegate>


@end
