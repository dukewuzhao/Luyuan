//
//  FirmwareUpdate.m
//  RideHousekeeper
//
//  Created by Apple on 2017/7/13.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "FirmwareUpdate.h"
#import "Constants.h"
#import "AppFilesViewController.h"
#import "UserFilesViewController.h"
#import "SSZipArchive.h"
#import "UnzipFirmware.h"
#import "Utility.h"
#import "DFUHelper.h"
#import "CustomProgress.h"

@interface FirmwareUpdate()

@property (strong, nonatomic) CBPeripheral *selectedPeripheral;
@property (strong, nonatomic) DFUOperations *dfuOperations;
@property (strong, nonatomic) DFUHelper *dfuHelper;
@property (strong, nonatomic) NSString *selectedFileType;

@property BOOL isTransferring;
@property BOOL isTransfered;
@property BOOL isTransferCancelled;
@property BOOL isConnected;
@property BOOL isErrorKnown;

@end

@implementation FirmwareUpdate

@synthesize selectedPeripheral;
@synthesize dfuOperations;
@synthesize selectedFileType;

    -(instancetype)init
    {
        //调用父类的init方法进行初始化，将初始化得到的对象赋值给self对象
        //如果self对象不为nil，表明父类init方法初始化成功
        self = [super init];
            
        if(self){
        
            PACKETS_NOTIFICATION_INTERVAL=10;
            dfuOperations = [[DFUOperations alloc] initWithDelegate:self];
            self.dfuHelper = [[DFUHelper alloc] initWithData:dfuOperations];
            
        }
            
        
        return self;
    }


-(void)DFUOperation:(CBPeripheral *)choosePeripheral DFUCentralManager:(CBCentralManager *)manager{

    selectedPeripheral = choosePeripheral;
    [dfuOperations setCentralManager:manager];
    [dfuOperations connectDevice:choosePeripheral];
    [self performSelector:@selector(connectSuccess) withObject:nil afterDelay:3];
    
}

- (void)connectSuccess{
    
    self.isConnected = YES;
    self.dfuHelper.isDfuVersionExist = YES;
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/test.zip", pathDocuments];
    NSURL *URL = [NSURL URLWithString:filePath];
    
    [self onFileTypeNotSelected];
    
    // Save the URL in DFU helper
    self.dfuHelper.selectedFileURL = URL;
    
    //if (self.dfuHelper.selectedFileURL) {
    NSMutableArray *availableTypes = [[NSMutableArray alloc] initWithCapacity:4];
    
    // Read file name and size
    NSString *selectedFileName = [[URL path] lastPathComponent];
    NSData *fileData = [NSData dataWithContentsOfURL:URL];
    self.dfuHelper.selectedFileSize = fileData.length;
    
    // Get last three characters for file extension
    NSString *extension = [[selectedFileName substringFromIndex: [selectedFileName length] - 3] lowercaseString];
    if ([extension isEqualToString:@"zip"])
    {
        self.dfuHelper.isSelectedFileZipped = YES;
        self.dfuHelper.isManifestExist = NO;
        // Unzip the file. It will parse the Manifest file, if such exist, and assign firmware URLs
        [self.dfuHelper unzipFiles:URL];
        
        // Manifest file has been parsed, we can now determine the file type based on its content
        // If a type is clear (only one bin/hex file) - just select it. Otherwise give user a change to select
        NSString* type = nil;
        if (((self.dfuHelper.softdevice_bootloaderURL && !self.dfuHelper.softdeviceURL && !self.dfuHelper.bootloaderURL) ||
             (self.dfuHelper.softdeviceURL && self.dfuHelper.bootloaderURL && !self.dfuHelper.softdevice_bootloaderURL)) &&
            !self.dfuHelper.applicationURL)
        {
            type = FIRMWARE_TYPE_BOTH_SOFTDEVICE_BOOTLOADER;
        }
        else if (self.dfuHelper.softdeviceURL && !self.dfuHelper.bootloaderURL && !self.dfuHelper.applicationURL && !self.dfuHelper.softdevice_bootloaderURL)
        {
            type = FIRMWARE_TYPE_SOFTDEVICE;
        }
        else if (self.dfuHelper.bootloaderURL && !self.dfuHelper.softdeviceURL && !self.dfuHelper.applicationURL && !self.dfuHelper.softdevice_bootloaderURL)
        {
            type = FIRMWARE_TYPE_BOOTLOADER;
        }
        else if (self.dfuHelper.applicationURL && !self.dfuHelper.softdeviceURL && !self.dfuHelper.bootloaderURL && !self.dfuHelper.softdevice_bootloaderURL)
        {
            type = FIRMWARE_TYPE_APPLICATION;
        }
        
        // The type has been established?
        if (type)
        {
            // This will set the selectedFileType property
            [self onFileTypeSelected:type];
        }
        else
        {
            if (self.dfuHelper.softdeviceURL)
            {
                [availableTypes addObject:FIRMWARE_TYPE_SOFTDEVICE];
            }
            if (self.dfuHelper.bootloaderURL)
            {
                [availableTypes addObject:FIRMWARE_TYPE_BOOTLOADER];
            }
            if (self.dfuHelper.applicationURL)
            {
                [availableTypes addObject:FIRMWARE_TYPE_APPLICATION];
            }
            if (self.dfuHelper.softdevice_bootloaderURL)
            {
                [availableTypes addObject:FIRMWARE_TYPE_BOTH_SOFTDEVICE_BOOTLOADER];
            }
        }
    }
    else
    {
        // If a HEX/BIN file has been selected user needs to choose the type manually
        self.dfuHelper.isSelectedFileZipped = NO;
        [availableTypes addObjectsFromArray:@[FIRMWARE_TYPE_SOFTDEVICE, FIRMWARE_TYPE_BOOTLOADER, FIRMWARE_TYPE_APPLICATION, FIRMWARE_TYPE_BOTH_SOFTDEVICE_BOOTLOADER]];
    }
    
    [self performDFU];
}

-(void)performDFU
{
    
    [self.dfuHelper checkAndPerformDFU];
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    // The 'scan' or 'select' seque will be performed only if DFU process has not been started or was completed.
    //return !self.isTransferring;
    return YES;
}


- (void) clearUI
{
    selectedPeripheral = nil;
}

-(void)enableUploadButton
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (selectedFileType && self.dfuHelper.selectedFileSize > 0)
        {
            if ([self.dfuHelper isValidFileSelected])
            {
                NSLog(@"Valid file selected");
            }
            else
            {
                NSLog(@"Valid file not available in zip file");
                [Utility showAlert:[self.dfuHelper getFileValidationMessage]];
                return;
            }
        }
        
        if (self.dfuHelper.isDfuVersionExist)
        {
            if (selectedPeripheral && selectedFileType && self.dfuHelper.selectedFileSize > 0 && self.isConnected && self.dfuHelper.dfuVersion > 1)
            {
                if ([self.dfuHelper isInitPacketFileExist])
                {
                    // uploadButton.enabled = YES;
                }
                else
                {
                    [Utility showAlert:[self.dfuHelper getInitPacketFileValidationMessage]];
                }
            }
            else
            {
                if (selectedPeripheral && self.isConnected && self.dfuHelper.dfuVersion < 1)
                {
                    // uploadStatus.text = [NSString stringWithFormat:@"Unsupported DFU version: %d", self.dfuHelper.dfuVersion];
                }
                NSLog(@"Can't enable Upload button");
            }
        }
        else
        {
            if (selectedPeripheral && selectedFileType && self.dfuHelper.selectedFileSize > 0 && self.isConnected)
            {
                // uploadButton.enabled = YES;
            }
            else
            {
                NSLog(@"Can't enable Upload button");
            }
        }
        
    });
}


-(void)appDidEnterBackground:(NSNotification *)_notification
{
    if (self.isConnected && self.isTransferring)
    {
        [Utility showBackgroundNotification:[self.dfuHelper getUploadStatusMessage]];
    }
}

-(void)appDidEnterForeground:(NSNotification *)_notification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}



#pragma mark File Selection Delegate
-(void)onFileTypeSelected:(NSString *)type
{
    selectedFileType = type;
    //fileType.text = selectedFileType;
    if (type)
    {
        [self.dfuHelper setFirmwareType:selectedFileType];
        [self enableUploadButton];
    }
}

-(void)onFileTypeNotSelected
{
    self.dfuHelper.selectedFileURL = nil;
    //    fileName.text = nil;
    //    fileSize.text = nil;
    [self onFileTypeSelected:nil];
}

#pragma mark DFUOperations delegate methods

-(void)onDeviceConnected:(CBPeripheral *)peripheral
{
    self.isConnected = YES;
    self.dfuHelper.isDfuVersionExist = NO;
    [self enableUploadButton];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // uploadStatus.text = @"Device ready";
    });
    
    //Following if condition display user permission alert for background notification
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }
    [NSNOTIC_CENTER addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [NSNOTIC_CENTER addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    if([self.delegate respondsToSelector:@selector(DFUDeviceconnected)])
    {
        [self.delegate DFUDeviceconnected];
    }
    
}

-(void)onDeviceConnectedWithVersion:(CBPeripheral *)peripheral
{
    self.isConnected = YES;
    self.dfuHelper.isDfuVersionExist = YES;
    [self enableUploadButton];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // uploadStatus.text = @"Reading DFU version...";
    });
    
    //Following if condition display user permission alert for background notification
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }
    [NSNOTIC_CENTER addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [NSNOTIC_CENTER addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)onDeviceDisconnected:(CBPeripheral *)peripheral
{
    self.isTransferring = NO;
    self.isConnected = NO;
    
    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.dfuHelper.dfuVersion != 1)
        {
            self.isTransferCancelled = NO;
            self.isTransfered = NO;
            self.isErrorKnown = NO;
        }
        else
        {
            double delayInSeconds = 3.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [dfuOperations connectDevice:peripheral];
            });
        }
    });
    
    if([self.delegate respondsToSelector:@selector(DFUDeviceDisconnected)])
    {
        [self.delegate DFUDeviceDisconnected];
    }
}

-(void)onReadDFUVersion:(int)version
{
    self.dfuHelper.dfuVersion = version;
    NSLog(@"DFU Version: %d",self.dfuHelper.dfuVersion);
    if (self.dfuHelper.dfuVersion == 1)
    {
        
        [dfuOperations setAppToBootloaderMode];
    }
    else
    {
        
        [self enableUploadButton];
    }
}

-(void)onDFUStarted
{
    NSLog(@"DFU Started");
    self.isTransferring = YES;
    
    if([self.delegate respondsToSelector:@selector(DFUStartedUpdate)])
    {
        [self.delegate DFUStartedUpdate];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *uploadStatusMessage = [self.dfuHelper getUploadStatusMessage];
        if ([Utility isApplicationStateInactiveORBackground])
        {
            [Utility showBackgroundNotification:uploadStatusMessage];
        }
        else
        {
            
        }
    });
}

-(void)onDFUCancelled
{
    NSLog(@"DFU Cancelled");
    self.isTransferring = NO;
    self.isTransferCancelled = YES;
    
    if([self.delegate respondsToSelector:@selector(DFUCancelledUpdate)])
    {
        [self.delegate DFUCancelledUpdate];
    }
}

-(void)onSoftDeviceUploadStarted
{
    NSLog(@"SoftDevice Upload Started");
}

-(void)onSoftDeviceUploadCompleted
{
    NSLog(@"SoftDevice Upload Completed");
}

-(void)onBootloaderUploadStarted
{
    NSLog(@"Bootloader Upload Started");
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([Utility isApplicationStateInactiveORBackground])
        {
            [Utility showBackgroundNotification:@"Uploading bootloader..."];
        }
        else
        {
            
        }
    });
}

-(void)onBootloaderUploadCompleted
{
    NSLog(@"Bootloader Upload Completed");
}

-(void)onTransferPercentage:(int)percentage
{
    
    if (self.transferPercentageBlock)
    {
        self.transferPercentageBlock(percentage);
    }
    
}



-(void)onSuccessfulFileTranferred
{
    NSLog(@"File Transferred");
    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isTransferring = NO;
        self.isTransfered = YES;
        NSString* message = [NSString stringWithFormat:@"%lu bytes transfered in %lu seconds", (unsigned long)dfuOperations.binFileSize, (unsigned long)dfuOperations.uploadTimeInSeconds];
        
        if ([Utility isApplicationStateInactiveORBackground])
        {
            [Utility showBackgroundNotification:message];
        }
        else
        {
            if([self.delegate respondsToSelector:@selector(DFUSuccessUpdate)])
            {
                [self.delegate DFUSuccessUpdate];
            }
            
        }
    });
}


-(void)onError:(NSString *)errorMessage
{
    NSLog(@"Error: %@", errorMessage);
    self.isErrorKnown = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        //[Utility showAlert:errorMessage];
        
        [SVProgressHUD showSimpleText:@"固件升级失败"];
        
        [dfuOperations cancelDFU];
        [NSThread sleepForTimeInterval:1.0f];
        [self clearUI];
        
        if([self.delegate respondsToSelector:@selector(DFUUpdateError)])
        {
            [self.delegate DFUUpdateError];
        }
        
    });
}


@end
