//
//  PhotoPickerManager.h
//  ShunTian
//
//  Created by zhanshu on 15/9/6.
//  Copyright (c) 2015年 zhanshu. All rights reserved.
//


//选择相片

#import <Foundation/Foundation.h>

@interface PhotoPickerManager_Edit : NSObject

+ (PhotoPickerManager_Edit *)shared;
/*!
 * @brief 选择图片或者拍照完成选择使用拍照的图片后，会调用此block
 * @param image 选择的图片或者拍照后选择使用的图片
 */
typedef void (^HYBPickerCompelitionBlock)(NSArray *image);
/*!
 * @brief 用户点击取消时的回调block
 */
typedef void (^HYBPickerCancelBlock)();
@property (nonatomic) NSInteger maxCount;
/*!
 * @brief 此方法为调起选择图片或者拍照的入口，当选择图片或者拍照后选择使用图片后，回调completion，
 *        当用户点击取消后，回调cancelBlock
 * @param inView UIActionSheet呈现到inView这个视图上
 * @param fromController 用于呈现UIImagePickerController的控制器
 * @param completion 当选择图片或者拍照后选择使用图片后，回调completion
 * @param cancelBlock 当用户点击取消后，回调cancelBlock
 */
- (void)showActionSheetInView:(UIView *)inView
               fromController:(UIViewController *)fromController
                   completion:(HYBPickerCompelitionBlock)completion
                  cancelBlock:(HYBPickerCancelBlock)cancelBlock;
- (void)showActionSheetInView:(UIView *)inView
               fromController:(UIViewController *)fromController
                   completion:(HYBPickerCompelitionBlock)completion
                  cancelBlock:(HYBPickerCancelBlock)cancelBlock
                      clickAt:(NSInteger)index;
- (void)showActionSheetInView:(UIView *)inView
               fromController:(UIViewController *)fromController
                   completion:(HYBPickerCompelitionBlock)completion
                  cancelBlock:(HYBPickerCancelBlock)cancelBlock
                     maxCount:(NSInteger)maxCount;
@end
