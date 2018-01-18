//
//  SuccessInputFingerprint.h
//  RideHousekeeper
//
//  Created by Apple on 2017/11/21.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SuccessInputFingerprintDelegate <NSObject>

@optional

-(void) InputFingerprintSuccess;

-(void) InputFingerprintNext;

@end

@interface SuccessInputFingerprint : UIView

@property (nonatomic,weak) id<SuccessInputFingerprintDelegate> delegate;

@end
