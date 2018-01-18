//
//  AnnotatedHeader.h
//  RideHousekeeper
//
//  Created by Apple on 2017/11/29.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#ifndef AnnotatedHeader_h
#define AnnotatedHeader_h

#define KNOTIFICATION_LOGINCHANGE @"loginStateChange"
//蓝牙通知
#define NSNOTIC_CENTER  [NSNotificationCenter defaultCenter]//通知

#define KNotification_BluetoothPowerOn @"KNotification_BluetoothPowerOn"//蓝牙开关开启

#define KNotification_BluetoothPowerOff @"KNotification_BluetoothPowerOff"//蓝牙开关关闭

#define KNotification_UpdateDeviceStatus @"KNotification_UpdateDeviceStatus"//蓝牙连接断开与连上

#define KNotification_ConnectStatus @"KNotification_ConnectStatus"

#define KNotification_UpdateAllValue @"KNotification_UpdateAllValue"

#define KNotification_UpdateeditionValue @"KNotification_UpdateeditionValue"

#define KNotification_VersionValue @"KNotification_VersionValue"//硬件版本号读取

#define KNotification_Updatepassword @"KNotification_Updatepassword"

#define KNotification_Bindingkey @"KNotification_Bindingkey"

#define KNotification_QueryData @"KNotification_QueryData"

#define KNotification_QueryBleKeyData @"KNotification_QueryBleKeyData"

#define KNotification_Dataupdate @"KNotification_Dataupdate"

#define KNotification_RemoteJPush @"KNotification_RemoteJPush"

#define KNotification_UpdateValue @"KNotification_UpdateValue"

#define KNotification_BindingQGJSuccess @"KNotification_BindingQGJSuccess"

#define KNotification_BindingBLEKEY @"KNotification_BindingBLEKEY"//配置蓝牙钥匙

#define KNotification_QueryKeyType @"KNotification_QueryKeyType"//获取钥匙版本好的通知，1005命令

#define KNotification_SwitchDevice @"KNotification_SwitchDevice"//绑定车辆后通知主页切换车辆

#define KNotification_ConnectDefaultBike @"KNotification_ConnectDefaultBike"//有多辆车时，删除当前车辆后连接第一辆

#define RefreshFittingsManagement @"RefreshFittingsManagement"//刷新配件管理列表

#define KNotification_SwitchingVehicle @"KNotification_SwitchingVehicle"//车库点击切换车辆

#define KNotification_FirmwareUpgradeCompleted @"KNotification_FirmwareUpgradeCompleted"//固件升级完成通知

#define KNotification_reloadTableViewData @"KNotification_reloadTableViewData"//页面刷新

#define KNotification_FingerPrint @"KNotification_FingerPrint"//配置指纹

#define KNotification_DeleteFinger @"KNotification_DeleteFinger"//删除指纹

#define KNotification_TestFingerPress @"KNotification_TestFingerPress"//检测指纹按压

#define USER_DEFAULTS [NSUserDefaults standardUserDefaults]
#define Key_DeviceUUID @"com.comtime.smartbike.DeviceUUID"
#define Key_MacSTRING @"com.comtime.smartbike.DeviceSTRING"

#endif /* AnnotatedHeader_h */
