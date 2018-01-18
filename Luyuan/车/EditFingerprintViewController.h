//
//  EditFingerprintViewController.h
//  RideHousekeeper
//
//  Created by Apple on 2017/11/21.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditFingerprinDelegate <NSObject>

@optional

-(void) deleteFingerprintSuccess;

-(void) editFingerprintNameSuccess;

@end

@interface EditFingerprintViewController : BaseViewController
@property(nonatomic,assign) NSInteger deviceNum;
@property(nonatomic,strong) FingerprintModel* fpmodel;
@property (nonatomic,weak) id<EditFingerprinDelegate> delegate;
@end
