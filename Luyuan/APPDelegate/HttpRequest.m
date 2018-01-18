//
//  HttpRequest.m
//  RideHousekeeper
//
//  Created by Apple on 2017/12/26.
//  Copyright © 2017年 Duke Wu. All rights reserved.
//

#import "HttpRequest.h"
#import "UploadParam.h"
@implementation HttpRequest

static id _instance = nil;
+ (instancetype)sharedInstance {
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super init];
        
    });
    return _instance;
}

#pragma mark -- GET请求 --
- (void)getWithURLString:(NSString *)URLString
              parameters:(id)parameters
                 success:(void (^)(id))success
                 failure:(void (^)(NSError *))failure {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    /**
     *  可以接受的类型
     */
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    /**
     *  请求队列的最大并发数
     */
    //    manager.operationQueue.maxConcurrentOperationCount = 5;
    /**
     *  请求超时的时间
     */
    manager.requestSerializer.timeoutInterval = 15;
    [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark -- POST请求 --
- (void)postWithURLString:(NSString *)URLString
               parameters:(id)parameters
                  success:(void (^)(id))success
                  failure:(void (^)(NSError *))failure {
    
    AFHTTPSessionManager *manager = [QFTools sharedManager];
    [manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            //NSLog(@"KAOKAOKAO  ------%@",responseObject);
            if ([responseObject[@"status"] intValue] == 0){
                NSLog(@"token没有失效  ------");
                success(responseObject);
            }else if ([responseObject[@"status"] intValue] == 1009){
                NSLog(@"token失效了  ------");
                NSString *password= [QFTools getdata:@"password"];
                NSString *phonenum= [QFTools getdata:@"phone_num"];
                
                NSString *pwd = [NSString stringWithFormat:@"%@%@%@",@"QGJ",password,@"BLE"];
                NSString * md5=[QFTools md5:pwd];
                NSString *loginURL = [NSString stringWithFormat:@"%@%@",QGJURL,@"app/login"];
                NSDictionary *loginParameters = @{@"account": phonenum, @"passwd": md5.uppercaseString};
                [self postWithURLString:loginURL parameters:loginParameters success:^(id responseObject) {
                    
                    if ([responseObject[@"status"] intValue] == 0){
                        
                        NSDictionary *data = responseObject[@"data"];
                        LoginDataModel *loginModel = [LoginDataModel yy_modelWithDictionary:data];
                        NSString * token=loginModel.token;
                        NSString * defaultlogo = loginModel.default_brand_logo;
                        NSString * defaultimage = loginModel.default_model_picture;
                        UserInfoModel *userinfo = loginModel.user_info;
                        NSString * birthday=userinfo.birthday;
                        NSString * nick_name=userinfo.nick_name;
                        NSNumber * gender = [NSNumber numberWithInteger:userinfo.gender];
                        NSString * icon = userinfo.icon;
                        NSString * realName = userinfo.real_name;
                        NSString *idcard = userinfo.id_card_no;
                        NSNumber *userId = [NSNumber numberWithInteger:userinfo.user_id];
                        
                        NSDictionary *userDic = [NSDictionary dictionaryWithObjectsAndKeys:token,@"token",phonenum,@"phone_num",password,@"password",defaultlogo,@"defaultlogo",defaultimage,@"defaultimage",userId,@"userid",nil];
                        [USER_DEFAULTS setObject:userDic forKey:logInUSERDIC];
                        [USER_DEFAULTS synchronize];
                        
                        NSDictionary *userDic2 = [NSDictionary dictionaryWithObjectsAndKeys:phonenum,@"username",birthday,@"birthday",nick_name,@"nick_name",gender,@"gender",icon,@"icon",realName,@"realname",idcard,@"idcard",nil];
                        [USER_DEFAULTS setObject:userDic2 forKey:userInfoDic];
                        [USER_DEFAULTS synchronize];
                        NSMutableDictionary *dict002 = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)parameters];
                        [dict002 setValue:token forKey:@"token"];
                        [[HttpRequest sharedInstance] postWithURLString:URLString parameters:dict002 success:success failure:failure];
                    }
                    
                } failure:^(NSError *error) {
                    
                    [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
                    
                }];
            }else{
                success(responseObject);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
        [SVProgressHUD showSimpleText:TIP_OF_NO_NETWORK];
    }];
}

#pragma mark -- POST/GET网络请求 --
- (void)requestWithURLString:(NSString *)URLString
                  parameters:(id)parameters
                        type:(HttpRequestType)type
                     success:(void (^)(id))success
                     failure:(void (^)(NSError *))failure {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    switch (type) {
        case HttpRequestTypeGet:
        {
            [manager GET:URLString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    success(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    failure(error);
                }
            }];
        }
            break;
        case HttpRequestTypePost:
        {
            [manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    success(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    failure(error);
                }
            }];
        }
            break;
    }
}

- (void)uploadWithURLString:(NSString *)URLString parameters:(id)parameters uploadParam:(NSArray<UploadParam *> *)uploadParams success:(void (^)())success failure:(void (^)(NSError *))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (UploadParam *uploadParam in uploadParams) {
            [formData appendPartWithFileData:uploadParam.data name:uploadParam.name fileName:uploadParam.filename mimeType:uploadParam.mimeType];
        }
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - 下载数据
- (void)downLoadWithURLString:(NSString *)URLString parameters:(id)parameters progerss:(void (^)())progress success:(void (^)())success failure:(void (^)(NSError *))failure {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    NSURLSessionDownloadTask *downLoadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progress) {
            progress();
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return targetPath;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
    [downLoadTask resume];
}

@end
