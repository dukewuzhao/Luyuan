//
//  DelPopView.h
//  UICollectionViewDemo1
//
//  Created by Apple on 2017/11/10.
//  Copyright © 2017年 BG. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DelPopViewDelegate <NSObject>

@required
- (void)didSelectedAtIndexPath:(NSInteger)tag :(NSInteger)deviceid;

@end
typedef void(^dismissWithOperation)();

@interface DelPopView : UIView
@property (nonatomic, weak) id<DelPopViewDelegate> delegate;
@property (nonatomic, strong) dismissWithOperation dismissOperation;

- (instancetype)initWithorigin:(CGPoint)origin width:(CGFloat)width height:(CGFloat)height tag:(NSInteger)tag deviceId:(NSInteger)deviceId;
- (void)pop;
@end
