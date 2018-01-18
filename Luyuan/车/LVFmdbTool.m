//
//  LVFmdbTool.m
//  LVDatabaseDemo
//
//
//  Copyright (c) 2015年 liuchunlao. All rights reserved.
//

#import "LVFmdbTool.h"


#define LVSQLITE_NAME @"modals.sqlite"

@implementation LVFmdbTool


static FMDatabase *_fmdb;

+ (void)initialize {
    // 执行打开数据库和创建表操作
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:LVSQLITE_NAME];
    _fmdb = [FMDatabase databaseWithPath:filePath];
    
    [_fmdb open];
    
 //#warning 必须先打开数据库才能创建表。。。否则提示数据库没有打开
    
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS bike_modals(id INTEGER PRIMARY KEY, bikeid INTEGER NOT NULL,bikename TEXT,ownerflag INTEGER,hwversion TEXT,firmversion TEXT,keyversion TEXT,mac TEXT,mainpass TEXT ,password TEXT, bindedcount INTEGER,ownerphone TEXT);"];
    
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS brand_modals(id INTEGER PRIMARY KEY,bikeid INTEGER NOT NULL,brandid INTEGER,brandname TEXT,logo TEXT);"];
    
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS key_modals(id INTEGER PRIMARY KEY,keyid INTEGER NOT NULL,keyname TEXT,sn TEXT,deviceid INTEGER);"];
    
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS info_modals(id INTEGER PRIMARY KEY,bikeid INTEGER NOT NULL,modelid INTEGER, modelname TEXT ,batttype INTEGER ,battvol INTEGER,wheelsize INTEGER ,brandid INTEGER , pictures TEXT,pictureb TEXT);"];
    
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS fingerprint_modals(id INTEGER PRIMARY KEY,bikeid INTEGER NOT NULL,fp_id INTEGER,pos INTEGER, name TEXT ,added_time INTEGER);"];
    
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS periphera_modals(id INTEGER PRIMARY KEY,bikeid INTEGER NOT NULL,deviceid INTEGER,type INTEGER,seq INTEGER,mac TEXT ,sn TEXT,firmversion TEXT);"];
    
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS induction_modals(id INTEGER PRIMARY KEY,bikeid INTEGER NOT NULL,inductionValue INTEGER,induction INTEGER);"];
    
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS peripherauuid_modals(id INTEGER PRIMARY KEY,username TEXT NOT NULL,bikeid INTEGER,mac TEXT,uuid TEXT);"];
    
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS induckey_modals(id INTEGER PRIMARY KEY,bikeid INTEGER NOT NULL,induckeyValue INTEGER);"];
    
    [_fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS automaticlock_models(id INTEGER PRIMARY KEY,bikeid INTEGER NOT NULL,automaticlock INTEGER);"];
    
    if (![_fmdb columnExists:@"keyversion" inTableWithName:@"bike_modals"]){
        
        NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",@"bike_modals",@"keyversion"];
        [_fmdb executeUpdate:alertStr];
    }
    
    if (![_fmdb columnExists:@"ownerphone" inTableWithName:@"bike_modals"]){
        
        NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ TEXT",@"bike_modals",@"ownerphone"];
        [_fmdb executeUpdate:alertStr];
    }
}

+ (BOOL)insertBikeModel:(BikeModel *)model{
    
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO bike_modals(bikeid,bikename, ownerflag, hwversion,firmversion,keyversion,mac,mainpass,password,bindedcount,ownerphone) VALUES ('%zd','%@','%zd','%@','%@','%@', '%@','%@','%@', '%zd','%@');", model.bikeid,model.bikename, model.ownerflag, model.hwversion,model.firmversion,model.keyversion,model.mac,model.mainpass,model.password,model.bindedcount,model.ownerphone];
    
    return [_fmdb executeUpdate:insertSql];

    return YES;
}

+ (BOOL)insertKeyModel:(KeyModel *)model{


        NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO key_modals(keyid,keyname,sn,deviceid) VALUES ('%zd','%@','%@','%zd');", model.keyid,model.keyname,model.sn,model.deviceid];
        return [_fmdb executeUpdate:insertSql];
    
    return YES;

}

+ (BOOL)insertBrandModel:(BrandModel *)model{

    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO brand_modals(bikeid,brandid,brandname,logo) VALUES ('%zd','%zd','%@','%@');", model.bikeid,model.brandid,model.brandname,model.logo];
    return [_fmdb executeUpdate:insertSql];
    
    return YES;

}

+ (BOOL)insertModelInfo:(ModelInfo *)model{
    
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO info_modals(bikeid,modelid, modelname, batttype,battvol,wheelsize,brandid,pictures,pictureb) VALUES ('%zd','%zd','%@','%zd','%zd','%zd','%zd','%@', '%@');", model.bikeid,model.modelid, model.modelname, model.batttype,model.battvol,model.wheelsize,model.brandid,model.pictures,model.pictureb];
    
    return [_fmdb executeUpdate:insertSql];
    
    return YES;
}

+ (BOOL)insertFingerprintModel:(FingerprintModel *)model{
    
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO fingerprint_modals(bikeid,fp_id,pos, name, added_time) VALUES ('%zd','%zd','%zd','%@','%zd');", model.bikeid,model.fp_id,model.pos, model.name, model.added_time];
    
    return [_fmdb executeUpdate:insertSql];
    return YES;
}

+ (BOOL)insertDeviceModel:(PeripheralModel *)model{


    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO periphera_modals(bikeid,deviceid, type,seq, mac,sn,firmversion) VALUES ('%zd','%zd','%zd','%zd','%@','%@','%@');", model.bikeid,model.deviceid, model.type,model.seq, model.mac,model.sn,model.firmversion];
    
    return [_fmdb executeUpdate:insertSql];
    
    return YES;

}

+ (BOOL)insertInductionModel:(InductionModel *)model{

    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO induction_modals(bikeid,inductionValue, induction) VALUES ('%zd','%zd','%zd');", model.bikeid,model.inductionValue, model.induction];
    
    return [_fmdb executeUpdate:insertSql];
    
    return YES;
}

+ (BOOL)insertInduckeyModel:(InduckeyModel *)model{
    
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO induckey_modals(bikeid,induckeyValue) VALUES ('%zd','%zd');", model.bikeid,model.induckeyValue];
    
    return [_fmdb executeUpdate:insertSql];
    
    return YES;
}

+ (BOOL)insertPeripheralUUIDModel:(PeripheralUUIDModel *)model{
    
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO peripherauuid_modals(username,bikeid,mac, uuid) VALUES ('%@','%zd','%@','%@');", model.username,model.bikeid, model.mac, model.uuid];
    
    return [_fmdb executeUpdate:insertSql];
    
    return YES;
}

+ (BOOL)insertAutomaticLockModel:(AutomaticLockModel *)model{
    
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO automaticlock_models(bikeid,automaticlock) VALUES ('%zd','%zd');", model.bikeid,model.automaticlock];
    
    return [_fmdb executeUpdate:insertSql];
    
    return YES;
}

+ (NSMutableArray *)queryBikeData:(NSString *)querySql {
    
    if (querySql == nil) {
        querySql = @"SELECT * FROM bike_modals;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSString *bikeid = [set stringForColumn:@"bikeid"];
        NSString *bikename = [set stringForColumn:@"bikename"];
        NSString *ownerflag = [set stringForColumn:@"ownerflag"];
        NSString *hwversion = [set stringForColumn:@"hwversion"];
        NSString *firmversion = [set stringForColumn:@"firmversion"];
        NSString *keyversion = [set stringForColumn:@"keyversion"];
        NSString *mac = [set stringForColumn:@"mac"];
        NSString *password = [set stringForColumn:@"password"];
        NSString *mainpass = [set stringForColumn:@"mainpass"];
        NSString *bindedcount = [set stringForColumn:@"bindedcount"];
        NSString *ownerphone = [set stringForColumn:@"ownerphone"];
        
        BikeModel *modal = [BikeModel modalWith:bikeid.intValue bikename:bikename ownerflag:ownerflag.intValue hwversion:hwversion firmversion:firmversion keyversion:keyversion mac:mac mainpass:mainpass password:password bindedcount:bindedcount.intValue ownerphone:ownerphone];
        [arrM addObject:modal];
    }
    return arrM;
}

+ (NSMutableArray *)queryBrandData:(NSString *)querySql{
    
    if (querySql == nil) {
        querySql = @"SELECT * FROM brand_modals;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSString *bikeid = [set stringForColumn:@"bikeid"];
        NSString *brandid = [set stringForColumn:@"brandid"];
        NSString *brandname = [set stringForColumn:@"brandname"];
        NSString *logo = [set stringForColumn:@"logo"];
        
        BrandModel *modal = [BrandModel modalWith:bikeid.intValue brandid:brandid.intValue brandname:brandname logo:logo];
        [arrM addObject:modal];
    }
    return arrM;
}


+ (NSMutableArray *)queryKeyData:(NSString *)querySql{

    if (querySql == nil) {
        querySql = @"SELECT * FROM key_modals;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSString *keyid = [set stringForColumn:@"keyid"];
        NSString *keyname = [set stringForColumn:@"keyname"];
        NSString *sn = [set stringForColumn:@"sn"];
        NSString *deviceid = [set stringForColumn:@"deviceid"];
        
        KeyModel *modal = [KeyModel modalWith:keyid.intValue keyname:keyname sn:sn deviceid:deviceid.intValue];
        [arrM addObject:modal];
    }
    return arrM;
}

+ (NSMutableArray *)queryModelData:(NSString *)querySql{
    
    if (querySql == nil) {
        
        querySql = @"SELECT * FROM info_modals;";
    }

    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSString *keyid = [set stringForColumn:@"bikeid"];
        NSString *modelid = [set stringForColumn:@"modelid"];
        NSString *modelname = [set stringForColumn:@"modelname"];
        NSString *batttype = [set stringForColumn:@"batttype"];
        NSString *battvol = [set stringForColumn:@"battvol"];
        NSString *wheelsize = [set stringForColumn:@"wheelsize"];
        NSString *brandid = [set stringForColumn:@"brandid"];
        NSString *pictures = [set stringForColumn:@"pictures"];
        NSString *pictureb = [set stringForColumn:@"pictureb"];
        
        ModelInfo *modal = [ModelInfo modalWith:keyid.intValue modelid:modelid.intValue modelname:modelname batttype:batttype.intValue battvol:battvol.intValue wheelsize:wheelsize.intValue brandid:brandid.intValue pictures:pictures pictureb:pictureb];
        [arrM addObject:modal];
    }
    return arrM;
}

//bikeid,deviceid, type, mac,sn
+ (NSMutableArray *)queryPeripheraData:(NSString *)querySql{
    
    if (querySql == nil) {
        querySql = @"SELECT * FROM periphera_modals;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSString *keyid = [set stringForColumn:@"bikeid"];
        NSString *deviceid = [set stringForColumn:@"deviceid"];
        NSString *type = [set stringForColumn:@"type"];
        NSString *seq = [set stringForColumn:@"seq"];
        NSString *mac = [set stringForColumn:@"mac"];
        NSString *sn = [set stringForColumn:@"sn"];
        NSString *firmversion = [set stringForColumn:@"firmversion"];
        
        PeripheralModel *modal = [PeripheralModel modalWith:keyid.intValue deviceid:deviceid.intValue type:type.intValue seq:seq.intValue mac:mac sn:sn firmversion:firmversion];
        [arrM addObject:modal];
    }
    return arrM;
}

+ (NSMutableArray *)queryFingerprintData:(NSString *)querySql{
    
    if (querySql == nil) {
        querySql = @"SELECT * FROM fingerprint_modals;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSInteger bikeid = [set intForColumn:@"bikeid"];
        NSInteger fp_id = [set intForColumn:@"fp_id"];
        NSInteger pos = [set intForColumn:@"pos"];
        NSString *name = [set stringForColumn:@"name"];
        NSString * added_time = [set stringForColumn:@"added_time"];
        
        FingerprintModel *modal = [FingerprintModel modalWith:bikeid fp_id:fp_id pos:pos name:name added_time:added_time.integerValue];
        [arrM addObject:modal];
    }
    return arrM;
}

+ (NSMutableArray *)queryInductionData:(NSString *)querySql{
    
    if (querySql == nil) {
        querySql = @"SELECT * FROM induction_modals;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSString *bikeid = [set stringForColumn:@"bikeid"];
        NSString *inductionValue = [set stringForColumn:@"inductionValue"];
        NSString *induction = [set stringForColumn:@"induction"];
        
        
        InductionModel *modal = [InductionModel modalWith:bikeid.intValue inductionValue:inductionValue.intValue induction:induction.intValue];
        [arrM addObject:modal];
    }
    return arrM;
}

+ (NSMutableArray *)queryInduckeyData:(NSString *)querySql{
    
    if (querySql == nil) {
        querySql = @"SELECT * FROM induckey_modals;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSString *bikeid = [set stringForColumn:@"bikeid"];
        NSString *induckeyValue = [set stringForColumn:@"induckeyValue"];
        
        InduckeyModel *modal = [InduckeyModel modalWith:bikeid.intValue induckeyValue:induckeyValue.intValue];
        [arrM addObject:modal];
    }
    return arrM;
}


+ (NSMutableArray *)queryPeripheraUUIDData:(NSString *)querySql{
    
    if (querySql == nil) {
        querySql = @"SELECT * FROM peripherauuid_modals;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSString *username = [set stringForColumn:@"username"];
        NSString *bikeid = [set stringForColumn:@"bikeid"];
        NSString *mac = [set stringForColumn:@"mac"];
        NSString *uuid = [set stringForColumn:@"uuid"];
        
        PeripheralUUIDModel *modal = [PeripheralUUIDModel modalWith:username bikeid:bikeid.intValue mac:mac uuid:uuid];
        [arrM addObject:modal];
    }
    return arrM;
}

+ (NSMutableArray *)queryAutomaticLockData:(NSString *)querySql{
    
    if (querySql == nil) {
        querySql = @"SELECT * FROM automaticlock_models;";
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    FMResultSet *set = [_fmdb executeQuery:querySql];
    
    while ([set next]) {
        
        NSString *bikeid = [set stringForColumn:@"bikeid"];
        NSString *automaticlock = [set stringForColumn:@"automaticlock"];
        
        AutomaticLockModel *modal = [AutomaticLockModel modalWith:bikeid.intValue automaticlock:automaticlock.intValue];
        [arrM addObject:modal];
    }
    return arrM;
}

+ (BOOL)deleteBikeData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM bike_modals";
    }
    
    return [_fmdb executeUpdate:deleteSql];

}

+ (BOOL)deleteKeyData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM key_modals";
    }
    
    return [_fmdb executeUpdate:deleteSql];
    
}

+ (BOOL)deleteBrandData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM brand_modals";
    }
    
    return [_fmdb executeUpdate:deleteSql];
    
}

+ (BOOL)deleteModelData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM info_modals";
    }
    
    return [_fmdb executeUpdate:deleteSql];
    
}

+ (BOOL)deleteFingerprintData:(NSString *)deleteSql{
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM fingerprint_modals";
    }
    
    return [_fmdb executeUpdate:deleteSql];
}

+ (BOOL)deletePeripheraData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM periphera_modals";
    }
    
    return [_fmdb executeUpdate:deleteSql];
    
}

+ (BOOL)deleteInductionData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM induction_modals";
    }
    
    return [_fmdb executeUpdate:deleteSql];
    
}

+ (BOOL)deleteInduckeyData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM induckey_modals";
    }
    
    return [_fmdb executeUpdate:deleteSql];
    
}

+ (BOOL)deletePeripheraUUIDData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM peripherauuid_modals";
    }
    
    return [_fmdb executeUpdate:deleteSql];
    
}


+ (BOOL)deleteAutomaticLockData:(NSString *)deleteSql {
    
    if (deleteSql == nil) {
        deleteSql = @"DELETE FROM automaticlock_models";
    }
    
    return [_fmdb executeUpdate:deleteSql];
    
}

+ (BOOL)modifyData:(NSString *)modifySql {
    
    if (modifySql == nil) {
        modifySql = @"UPDATE base_modals SET ID_No = '789789' WHERE name = 'lisi'";
    }
    return [_fmdb executeUpdate:modifySql];
}


+ (BOOL)modifyPData:(NSString *)modifySql {
    
    if (modifySql == nil) {
        modifySql = @"UPDATE bike_modals SET stand = '789789' WHERE name = 'lisi'";
    }
    return [_fmdb executeUpdate:modifySql];
}

@end
