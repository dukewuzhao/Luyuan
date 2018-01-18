//
//  WYDevice.m
//  WYDevice
//
//  Created by AlanWang on 14-9-10.
//  Copyright (c) 2014年 AlanWang. All rights reserved.
//

#import "WYDevice.h"

@implementation WYDevice{

    CBService           *services;//设备下发值 服务
    CBCharacteristic    *keyAChar;//write特征值属性
    CBCharacteristic    *AccelerationChar;//Read 设备的mac地址值
    CBCharacteristic    *SensorChar;//Indicate通知上报传感器数据
    CBCharacteristic *  editionChar;//固件版本号
    CBCharacteristic *  versionChar;//硬件版本号
    
    NSMutableArray *instructionsArray;
}

@synthesize deviceDelegate;
@synthesize scanDelete;
@synthesize centralManager;

-(id)init{
    
    self = [super init];
    //centralManager   = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    centralManager=[[CBCentralManager alloc]initWithDelegate:self queue:nil options: @{ CBCentralManagerOptionRestoreIdentifierKey:@"myCentralManagerIdentifier"}];
    
    instructionsArray = [[NSMutableArray alloc]init];

    return self;
}
-(id)initWithRestoreIdentifier:(NSString *)identifier{
    self = [super init];
    if(self){
        centralManager=[[CBCentralManager alloc]initWithDelegate:self queue:nil options: @{ CBCentralManagerOptionRestoreIdentifierKey:identifier}];
   }
    return  self;
}

//这个方法的作用,就是根据uuid取到外设.
-(BOOL)retrievePeripheralWithUUID:(NSString *)uuidString{
    if(uuidString!=nil && ![uuidString isEqualToString:@""]){
        NSUUID *nsuuid=[[NSUUID alloc]initWithUUIDString:uuidString];
        NSArray *deices=  [centralManager retrievePeripheralsWithIdentifiers:[[NSArray alloc]initWithObjects:nsuuid, nil]];
        if(deices.count>0){
            _peripheral=deices[0];
            return YES;
        }
    }      
    return NO;
}

-(void)startScan{
      //[centralManager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"FFE1"]]  options:nil];//能在后台扫描特定的设备，不被后台挂起
    [centralManager scanForPeripheralsWithServices:nil options:nil];
}

-(void)startBackstageScan{
    [centralManager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"FFE1"]]  options:@{ CBCentralManagerScanOptionAllowDuplicatesKey:@YES }];//能在后台扫描特定的设备，不被后台挂起
}

-(void)startInfiniteScan{
    
    [centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey:@YES }];
    
}

-(void)stopScan{
    [centralManager stopScan];
}
-(void)remove{
    if(_peripheral){
        [centralManager cancelPeripheralConnection:_peripheral];
    }
    
    _peripheral=nil;
    _deviceStatus=0;
    [self reset];
}
-(void)reset{
    
    services=nil;
    keyAChar=nil;
    AccelerationChar = nil;
    SensorChar = nil;
    editionChar = nil;
    versionChar = nil;
}



-(void)connect{
    if(_peripheral){
        [centralManager connectPeripheral:_peripheral options:nil];
    }
}

-(void)cancelConnect{
    if(_peripheral)
        [centralManager cancelPeripheralConnection:_peripheral];
}

//写操作
-(void)sendKeyValue:(NSData *)data{
    //NSLog(@"发送的指令%@",data);
    if(_peripheral.state==CBPeripheralStateConnected&& keyAChar){
        
        [_peripheral writeValue:data forCharacteristic:keyAChar type:CBCharacteristicWriteWithResponse];
    }
}

//读操作
-(void)sendAccelerationValue:(NSData *)data{
    
    if(AccelerationChar==nil){
        NSLog(@"AccelerationChar is nil");
        return;
    }
    if(_peripheral==nil){
        NSLog(@"peripheral is nil");
        return;
    }
    
    [_peripheral readValueForCharacteristic: AccelerationChar];
    
}

-(void)readDiviceInformation{
    
    if(editionChar==nil){
        NSLog(@"editionChar is nil");
        return;
    }
    if(_peripheral==nil){
        NSLog(@"peripheral is nil");
        return;
        
    }

        [_peripheral readValueForCharacteristic: editionChar];
}

-(void)readDiviceVersion{
    
    if(versionChar==nil){
        NSLog(@"versionChar is nil");
        return;
    }
    if(_peripheral==nil){
        NSLog(@"peripheral is nil");
        return;
        
    }
    
    [_peripheral readValueForCharacteristic: versionChar];
}


#pragma mark - CBCentralManager delegate
-(void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict{
    NSLog(@"willRestoreState:%@",dict);
    NSArray *peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey];
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    if(peripheral.name){
        //NSLog(@"扫描的设备名称:%@",peripheral.name);
        if (!scanDelete) {
            
            NSLog(@"scandelete为空:%@",peripheral.name);
            
        }
        if(scanDelete && [scanDelete respondsToSelector:@selector(didDiscoverPeripheral::scanData:RSSI:)]){
            
            [scanDelete didDiscoverPeripheral:_tag :peripheral scanData:advertisementData RSSI:RSSI];
        }
    }
}
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
   
    NSLog(@"---SDK---- :  didConnectPeripheral, start discover services  tag:%@---%@",peripheral.name,peripheral.identifier.UUIDString);
    
    _peripheral=peripheral;
    _peripheral.delegate=self;
    [_peripheral discoverServices:nil];
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"---SDK---- :  didFailToConnectPeripheral, error %@",error);
}
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    [self reset];
    _deviceStatus=5;
    NSLog(@"---SDK---- :  didDisconnectPeripheral,   tag:%d  ,error:%@",_tag, error);
    
    if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didDisconnect::)]){
        [deviceDelegate didDisconnect:_tag :peripheral];
    }
    
    if (!_binding && !_upgrate){
    
        [WYDevice cancelPreviousPerformRequestsWithTarget:self selector:@selector(connect) object:nil];
        [self performSelector:@selector(connect) withObject:nil  afterDelay:1.0];
    }
    
}


-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            [NSNOTIC_CENTER postNotificationName:KNotification_BluetoothPowerOff object:[NSNumber numberWithInt:_tag]];
            
            self.blueToothOpen = NO;
//            if(scanDelete&& [scanDelete respondsToSelector:@selector(bluetoohPowerOff)]){
//                [scanDelete bluetoohPowerOff];
//            }
            break;
        case CBCentralManagerStatePoweredOn:
            [NSNOTIC_CENTER postNotificationName:KNotification_BluetoothPowerOn object:[NSNumber numberWithInt:_tag]];
            
            self.blueToothOpen = YES;
//            if(scanDelete&& [scanDelete respondsToSelector:@selector(bluetoohPowerOn)]){
//                [scanDelete bluetoohPowerOn];
//            }
//
            break;
        default:
            break;
    }
    
}

#pragma mark - CBCentralManager delegate


#pragma mark - peripheral delegate

-(void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error{
    if(deviceDelegate && [deviceDelegate respondsToSelector:@selector(didGetRssi:::)]){
        [deviceDelegate didGetRssi:_tag :[peripheral.RSSI intValue] :_peripheral];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (!error)
    {
        [WYDevice cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkSuccess:) object:peripheral];
        [self performSelector:@selector(checkSuccess:) withObject:peripheral  afterDelay:1.0];
        for (CBService *aService in peripheral.services)
        {
            NSLog(@"---------didDiscoverServices-- = %@   tag:%d",aService.UUID,_tag);
            // Discovers the characteristics for a given service
            if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"FFE1"]])
            {
                [peripheral discoverCharacteristics:nil forService:aService];
            }
        
            if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"180A"]])
            {
                [peripheral discoverCharacteristics:nil forService:aService];
            }
        }
    }else{
         NSLog(@"---SDK---- :  didDiscoverServices, error %@",error);
    }
    
}
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if(!error){
        
        if([service.UUID isEqual:[CBUUID UUIDWithString:@"180A"]]){
            
            for (CBCharacteristic *BChar in service.characteristics)
            {
                if ([BChar.UUID isEqual:[CBUUID UUIDWithString:@"2A26"]]){
                    //[peripheral setNotifyValue:YES forCharacteristic:BChar];
                    editionChar = BChar;
                    
                }else if ([BChar.UUID isEqual:[CBUUID UUIDWithString:@"2A27"]]){
                    //[peripheral setNotifyValue:YES forCharacteristic:BChar];
                    versionChar = BChar;
                }
            }
        }
        
        if([service.UUID isEqual:[CBUUID UUIDWithString:@"FFE1"]]){
            
            for (CBCharacteristic *aChar in service.characteristics)
            {
                NSLog(@" aChar:%@",aChar.UUID.UUIDString);
                
                if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FEE2"]]){
                    
                    //[peripheral setNotifyValue:YES forCharacteristic:aChar];
                    keyAChar = aChar;
                    
                }else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FEE3"]]){
                    
                    [peripheral setNotifyValue:YES forCharacteristic:aChar];
                    SensorChar = aChar;
                }else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FEE4"]]){
                    
                    //[peripheral setNotifyValue:YES forCharacteristic:aChar];
                    AccelerationChar = aChar;
                }
            }
        }
    }else{
        NSLog(@"---SDK---- :  didDiscoverCharacteristics, error %@",error);
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    //2秒之后检测是否还是连接状态，来决定连接是否稳定了，因为有时候一开始会反复断连
    
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Notification has started
        if (!characteristic.isNotifying) {
    
            // so disconnect from the peripheral
            NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
            //[self updateLog:[NSString stringWithFormat:@"Notification stopped on %@.  Disconnecting", characteristic]];
            [centralManager cancelPeripheralConnection:_peripheral];
        }
}

//上报值
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (!error){
       // NSLog(@"设备%d收到数据：%@    uuid:%@",_tag,characteristic.value,characteristic.UUID);

//        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FEE2"]])
//        {//获取到密钥信息
//            if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didGetKeyData:::)])
//            {
//
//                [deviceDelegate didGetKeyData:_tag :characteristic.value :_peripheral];
//            }
//        }
//        else
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A26"]]){
            if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didGetEditionCharData:::)])
            {
                
                [deviceDelegate didGetEditionCharData:_tag :characteristic.value :_peripheral];
            }
            
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A27"]]){
            if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didGetVersionCharData:::)])
            {
                
                [deviceDelegate didGetVersionCharData:_tag :characteristic.value :_peripheral];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FEE3"]]){
        
            if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didGetSensorData:::)])
            {
                
                [deviceDelegate didGetSensorData:_tag :characteristic.value :_peripheral];
            }
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FEE4"]]){
            
            if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didGetBurglarCharData:::)]){
                
                [deviceDelegate didGetBurglarCharData:_tag :characteristic.value :_peripheral];
            }
        }
    }else{
        
        NSLog(@"设备收到数据：error");
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
   //NSLog(@"didWriteValueForCharacteristic :%@   %@",characteristic.UUID.UUIDString,[self dataToString:characteristic.value]);
    //NSLog(@"发送的指令%@",characteristic.value);
    if (instructionsArray.count != 0) {
        [instructionsArray removeObjectAtIndex:0];
        
        if (!_upgrate  && instructionsArray.count != 0) {
            
            [self sendKeyValue:instructionsArray[0]];
        }
        
    }else if (instructionsArray.count == 0) {
      //  NSLog(@"已经传完了");
        
    }
}

#pragma mark - peripheral delegate
//检测连接是否稳定
-(void)checkSuccess:(CBPeripheral *)peripheral{
    if( peripheral.state==CBPeripheralStateConnected){
          NSLog(@"检测设备%d 蓝牙已经连接稳定  ",_tag);
        _deviceStatus=2;
        
        if (deviceDelegate && [deviceDelegate respondsToSelector:@selector(didConnect::)])
        {
            [deviceDelegate didConnect:_tag :peripheral];
        }
        
        if (!_binding && !_upgrate) {
            
            NSDictionary *userDic = [[NSUserDefaults standardUserDefaults] objectForKey:passwordDIC];
            NSString *passwordHEX = [@"A500000A1002" stringByAppendingFormat:@"%@", userDic[@"main"]];
            [self sendKeyValue:[ConverUtil parseHexStringToByteArray:passwordHEX]];
        }else if (_binding){
            NSLog(@"正在绑定中");
            
        }
    }
}


-(void)sendHexstring:(NSString *)string{

    [instructionsArray removeAllObjects];
    
    float floatStringlength = string.length/40.0;
    NSInteger intStringlength = string.length/40;
    if (floatStringlength > intStringlength) {
        
        for (int i = 0; i < intStringlength; i++) {
            
           NSString *subsection = [string substringWithRange:NSMakeRange(i * 40, 40)];
            NSData *data01 = [ConverUtil parseHexStringToByteArray:subsection];
            [instructionsArray addObject:data01];
          //  [self sendKeyValue:data01];
        }
        
        NSString *lastString =  [string substringWithRange:NSMakeRange(intStringlength * 40, string.length - intStringlength * 40)];
        NSData *data02 = [ConverUtil parseHexStringToByteArray:lastString];
        [instructionsArray addObject:data02];
        
    }else{
    
        NSString *lastString =  [string substringWithRange:NSMakeRange(0, string.length)];
        NSData *data02 = [ConverUtil parseHexStringToByteArray:lastString];
        [instructionsArray addObject:data02];
    }
}

-(BOOL)isConnected{
    return   _deviceStatus>=2 && _deviceStatus<5;
}



@end
