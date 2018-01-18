//
//  WYDevice.h
//  WYDevice
//
//  Created by AlanWang on 14-9-10.
//  Copyright (c) 2014年 AlanWang. All rights reserved.
//
//  Email:alan.wang@smartwallit.com
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol DeviceDelegate <NSObject>
@required

-(void)didConnect:(NSInteger) tag :(CBPeripheral *)peripheral;//

-(void)didDisconnect:(NSInteger)tag :(CBPeripheral *)peripheral;

@optional

-(void)didGetRssi:(NSInteger)tag :(NSInteger)rssi :(CBPeripheral *)peripheral;

-(void)didGetSensorData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral;

-(void)didGetEditionCharData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral;

-(void)didGetVersionCharData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral;

-(void)didGetBurglarCharData:(NSInteger)tag :(NSData *)data :(CBPeripheral *)peripheral;

@end

@protocol ScanDelegate <NSObject>
@required
-(void) didDiscoverPeripheral:(NSInteger)tag :(CBPeripheral *)peripheral scanData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
@optional
-(void) bluetoohPowerOn;
-(void) bluetoohPowerOff;

@end

@interface WYDevice : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>
@property (weak, nonatomic) id<DeviceDelegate> deviceDelegate;
@property (weak, nonatomic ) id<ScanDelegate>  scanDelete;
@property ( retain, nonatomic )   CBCentralManager *centralManager;
@property (nonatomic ,assign) int tag;

@property (nonatomic ,retain) CBPeripheral *peripheral;

@property (nonatomic)  int deviceStatus;

@property (nonatomic)  BOOL binding;

@property (nonatomic)  BOOL upgrate;

@property (nonatomic)  BOOL bindingaccessories;//判断是否配置外设

@property (nonatomic)  BOOL blueToothOpen;

/* Using this can make sure your app relaunch in background  even if it was killed because of  out of memory */
-(id)initWithRestoreIdentifier:(NSString *)identifier;

/*
  You can use this to retrieve the peripheral with the peripheral's uuidString you have saved before. if return is YES,retrieved succefully, else failed.
  This method is normally used  after your app launched, you can quickly reConnect the device you have connected before.
 
 e.g:
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 {
    WYDevice *device=[[WYDevice alloc]init];
 
    if([device retrievePeripheralWithUUID:@"the uuid you  have saved before"]){
       [device  connect];
    }

 }
  */

-(BOOL)retrievePeripheralWithUUID:(NSString *)uuidString;

/*
 You can use this method to get all CBPeripheral that being connected by Comtime APP.And then,connect the one you want use below code:
      WYDevice.peripheral=peripheral;
     [WYDevice.peripheral connect];
 
 @return		A list of <code>CBPeripheral</code> objects.
 */

-(void)startScan;// start scan the peripheral nearby
-(void)startInfiniteScan;//不间断的扫描
-(void)startBackstageScan;//后台也能扫描
-(void)stopScan;// stop scan

-(void)remove; // cancel and unbind the connection

-(void)connect; //开始连接

-(void)cancelConnect;//取消连接

-(void)readDiviceInformation;

-(void)readDiviceVersion;//硬件版本号

-(void)sendKeyValue:(NSData *)data;

-(void)sendAccelerationValue:(NSData *)data;

-(void)sendHexstring:(NSString *)string;//多个数据包的处理方式

-(BOOL)isConnected;

@end
