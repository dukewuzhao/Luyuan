//
//  FirmwareUpdate.h
//  RideHousekeeper
//
//  Created by Apple on 2017/7/13.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileTypeViewController.h"
#import "DFUOperations.h"

@class FirmwareUpdate;
@protocol FirmwareUpdateDelegate <NSObject>
@optional
-(void)DFUStartedUpdate;
-(void)DFUCancelledUpdate;
-(void)DFUUpdateError;
-(void)DFUSuccessUpdate;
-(void)DFUDeviceDisconnected;
-(void)DFUDeviceconnected;

@end

@interface FirmwareUpdate : NSObject<FileTypeSelectionDelegate, DFUOperationsDelegate>

@property (nonatomic,weak) id<FirmwareUpdateDelegate> delegate;

typedef void (^TransferPercentageBlock)(int percentage);
@property (nonatomic, copy) TransferPercentageBlock transferPercentageBlock;



-(void)DFUOperation:(CBPeripheral *)choosePeripheral DFUCentralManager:(CBCentralManager *)manager;
@end
