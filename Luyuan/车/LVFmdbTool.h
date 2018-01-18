//
//  LVFmdbTool.h
//  LVDatabaseDemo
//
//  Created by 刘春牢 on 15/3/26.
//  Copyright (c) 2015年 liuchunlao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@class KeyModel;
@class BikeModel;
@class BrandModel;
@class ModelInfo;
@class PeripheralModel;
@class InductionModel;
@class PeripheralUUIDModel;
@class InduckeyModel;
@class AutomaticLockModel;
@class FingerprintModel;

@interface LVFmdbTool : NSObject

// 插入模型数据 bike_modals
+ (BOOL)insertBikeModel:(BikeModel *)model;

// 插入车辆品牌信息 brand_modals
+ (BOOL)insertBrandModel:(BrandModel *)model;

// 插入钥匙数据 key_modals
+ (BOOL)insertKeyModel:(KeyModel *)model;

// 插入modelinfo数据 info_modals
+ (BOOL)insertModelInfo:(ModelInfo *)model;

// 插入外设数据 periphera_modals
+ (BOOL)insertDeviceModel:(PeripheralModel *)model;

// 插入指纹数据 periphera_modals
+ (BOOL)insertFingerprintModel:(FingerprintModel *)model;

// 插入感应数据 induction_modals
+ (BOOL)insertInductionModel:(InductionModel *)model;

// 插入感应钥匙感应距离数据 induckey_modals
+ (BOOL)insertInduckeyModel:(InduckeyModel *)model;

// 插入绑定设备外设uuid peripherauuid_modals
+ (BOOL)insertPeripheralUUIDModel:(PeripheralUUIDModel *)model;
// 插入是否自动锁车数据 automaticlock_models
+ (BOOL)insertAutomaticLockModel:(AutomaticLockModel *)model;

/** 查询数据,如果 传空 默认会查询表中所有数据 */
+ (NSMutableArray *)queryBikeData:(NSString *)querySql;

/** 查询钥匙数据,如果 传空 默认会查询表中所有数据 */
+ (NSMutableArray *)queryKeyData:(NSString *)querySql;

//查询车量品牌数据
+ (NSMutableArray *)queryBrandData:(NSString *)querySql;

//查询车型数据
+ (NSMutableArray *)queryModelData:(NSString *)querySql;

//查询外设连接数据
+ (NSMutableArray *)queryPeripheraData:(NSString *)querySql;

//查询指纹数据
+ (NSMutableArray *)queryFingerprintData:(NSString *)querySql;

//查询感应数据
+ (NSMutableArray *)queryInductionData:(NSString *)querySql;

//查询感应钥匙数据
+ (NSMutableArray *)queryInduckeyData:(NSString *)querySql;

//查询外设uuid数据
+ (NSMutableArray *)queryPeripheraUUIDData:(NSString *)querySql;

+ (NSMutableArray *)queryAutomaticLockData:(NSString *)querySql;

/** 删除数据,如果 传空 默认会删除表中所有数据 */
+ (BOOL)deleteBikeData:(NSString *)deleteSql;

/** 删除钥匙数据,如果 传空 默认会删除表中所有数据 */
+ (BOOL)deleteKeyData:(NSString *)deleteSql;

//删除车辆品牌信息
+ (BOOL)deleteBrandData:(NSString *)deleteSql ;

//删除车型信息
+ (BOOL)deleteModelData:(NSString *)deleteSql;

//删除外设信息
+ (BOOL)deletePeripheraData:(NSString *)deleteSql;

//删除指纹信息
+ (BOOL)deleteFingerprintData:(NSString *)deleteSql;

//删除感应信息
+ (BOOL)deleteInductionData:(NSString *)deleteSql;

//删除感应信息
+ (BOOL)deleteInduckeyData:(NSString *)deleteSql;

//删除外设uuid信息
+ (BOOL)deletePeripheraUUIDData:(NSString *)deleteSql;
//删除自动锁车信息
+ (BOOL)deleteAutomaticLockData:(NSString *)deleteSql;

/** 修改数据 */
+ (BOOL)modifyData:(NSString *)modifySql;


+ (BOOL)modifyPData:(NSString *)modifySql ;

@end
