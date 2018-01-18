//
//  PhotoPickerManager.m
//  ShunTian
//
//  Created by zhanshu on 15/9/6.
//  Copyright (c) 2015年 zhanshu. All rights reserved.
//

#import "PhotoPickerManager_Edit.h"
@interface PhotoPickerManager_Edit () <UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIActionSheetDelegate>

@property (nonatomic, weak)     UIViewController          *fromController;
@property (nonatomic, copy)     HYBPickerCompelitionBlock completion;
@property (nonatomic, copy)     HYBPickerCancelBlock      cancelBlock;

@end
@implementation PhotoPickerManager_Edit

+ (PhotoPickerManager_Edit *)shared {
    static PhotoPickerManager_Edit *sharedObject = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (!sharedObject) {
            sharedObject = [[[self class] alloc] init];
        }
    });
    
    return sharedObject;
}

- (void)showActionSheetInView:(UIView *)inView
               fromController:(UIViewController *)fromController
                   completion:(HYBPickerCompelitionBlock)completion
                  cancelBlock:(HYBPickerCancelBlock)cancelBlock {
    self.completion = [completion copy];
    self.cancelBlock = [cancelBlock copy];
    self.fromController = fromController;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIActionSheet *actionSheet = nil;
        BOOL isCamera=[UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
        if (isCamera) {
            actionSheet  = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:(id<UIActionSheetDelegate>)self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"从相册选择", @"拍照上传", nil];
        } else {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:(id<UIActionSheetDelegate>)self
                                             cancelButtonTitle:@"取消"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:@"从相册选择", nil];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [actionSheet showInView:inView];
        });
    });
    
    
    return;
}
- (void)showActionSheetInView:(UIView *)inView
               fromController:(UIViewController *)fromController
                   completion:(HYBPickerCompelitionBlock)completion
                  cancelBlock:(HYBPickerCancelBlock)cancelBlock
                      clickAt:(NSInteger)index {
    self.completion = [completion copy];
    self.cancelBlock = [cancelBlock copy];
    self.fromController = fromController;
    [self actionSheet:nil clickedButtonAtIndex:index];
}
- (void)showActionSheetInView:(UIView *)inView fromController:(UIViewController *)fromController completion:(HYBPickerCompelitionBlock)completion cancelBlock:(HYBPickerCancelBlock)cancelBlock maxCount:(NSInteger)maxCount {
    _maxCount = maxCount;
    [self showActionSheetInView:inView fromController:fromController completion:completion cancelBlock:cancelBlock];
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    BOOL isCamera=[UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    if (buttonIndex == 0) {
        // 从相册选择
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
        picker.allowsEditing = YES;
        picker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                         NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
        [[AppDelegate currentAppDelegate].window.rootViewController presentViewController:picker animated:YES completion:nil];
    } else if (buttonIndex == 1) { // 拍照
        if (isCamera) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.delegate = self;
            picker.allowsEditing = YES;
            // 设置导航默认标题的颜色及字体大小
            picker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                         NSFontAttributeName : [UIFont boldSystemFontOfSize:17]};
            [[AppDelegate currentAppDelegate].window.rootViewController presentViewController:picker animated:YES completion:nil];
        }else {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"没有摄像头" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
    }
    return;
}

#pragma mark - UIImagePickerControllerDelegate
// 选择了图片或者拍照了
- (void)imagePickerController:(UIImagePickerController *)aPicker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [aPicker dismissViewControllerAnimated:YES completion:nil];
    __block UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    
    if (image && self.completion) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [self.fromController setNeedsStatusBarAppearanceUpdate];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completion(@[image]);
            });
        });
    }
    return;
}

// 取消
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)aPicker {
    [aPicker dismissViewControllerAnimated:YES completion:nil];  
    
    if (self.cancelBlock) {  
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];  
        [self.fromController setNeedsStatusBarAppearanceUpdate];  
        
        self.cancelBlock();  
    }  
    return;  
}  


@end
