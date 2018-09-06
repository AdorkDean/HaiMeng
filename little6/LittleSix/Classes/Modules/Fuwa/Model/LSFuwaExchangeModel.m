//
//  LSFuwaExchangeModel.m
//  LittleSix
//
//  Created by Jim huang on 17/3/22.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaExchangeModel.h"
#import "LSOBaseModel.h"
#import "LSBaseModel.h"

@implementation LSFuwaExchangeModel

+(void)getFuwaExchangeListSuccess:(void (^)(NSArray * listArr))success failure:(void (^)(NSError *error))failure{
    NSString *path = [kBaseFuwa2URL stringByAppendingPathComponent:kFuwaExchangePath];

    
    [LSOBaseModel BGET:path parameters:nil success:^(LSOBaseModel *model) {
        NSArray * listArr =[NSArray modelArrayWithClass:[LSFuwaExchangeModel class] json:model.data];
        !success?:success(listArr);
    } failure:^(NSError *error) {
        !failure?:failure(error);
        
    }];
}

+(void)getFuwaExMyListSuccess:(void (^)(NSArray * listArr))success failure:(void (^)(NSError *error))failure{
    
    NSString *path = [kBaseFuwa2URL stringByAppendingPathComponent:kFuwaExMyListPath];
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    
    params[@"userid"] =ShareAppManager.loginUser.user_id;
    
    [LSOBaseModel BGET:path parameters:params success:^(LSOBaseModel *model) {
        NSArray * listArr =[NSArray modelArrayWithClass:[LSFuwaExchangeModel class] json:model.data];
        !success?:success(listArr);
    } failure:^(NSError *error) {
        !failure?:failure(error);
        
    }];
    
}

+ (void)requestWechatPayWithOrderId:(NSString *)order_id amount:(float)amount goodsId:(NSString *)goodsId success:(void (^)(NSDictionary *dict))success failure:(void (^)(NSError *))failure {
    
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kWechatPayPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    params[@"orderid"] = order_id;
    params[@"amount"] = @(amount);
    params[@"fuwagid"] = goodsId;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        success?:success(model.data);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure?:failure(error);
    }];
}

+ (void)requestAlipay:(NSString *)orderId amount:(NSString *)amount gid:(NSString *)fuwaId success:(void (^)(NSString *))success failure:(void (^)(NSError *))failure {
    
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kAliPayPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    params[@"orderid"] = orderId;
    params[@"amount"] = amount;
    params[@"fuwagid"] = fuwaId;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        NSString *info = model.result[@"order_str"];
        !success ? : success(info);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure ? : failure(error);
    }];
    
}

+(void)revokeFuwaWithOrderID:(NSString *)orderId Gid:(NSString *)gid Success:(void (^)(void))success failure:(void (^)(NSError *error))failure{
    NSString *path = [kBaseFuwa2URL stringByAppendingPathComponent:kFuwacancelSellPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    params[@"orderid"] = orderId;
    params[@"fuwagid"] = gid;
    params[@"userid"] = ShareAppManager.loginUser.user_id;
    
    [LSOBaseModel BGET:path parameters:params success:^(LSOBaseModel *model) {
        success();
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

@end
