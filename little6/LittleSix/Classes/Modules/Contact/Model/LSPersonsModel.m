//
//  LSPersonsModel.m
//  LittleSix
//
//  Created by GMAR on 2017/3/16.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSPersonsModel.h"
#import <YYKit/YYKit.h>
#import "LSBaseModel.h"
#import "ConstKeys.h"

@implementation LSPersonsModel

+(void)personerWithUser_id:(NSString *)u_id
                   success:(void (^)(LSPersonsModel * model))success
                   failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,kUserinfoPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    params[@"user_id"] = u_id;
    
    [LSBaseModel BPOSTWithCache:path parameters:params success:^(NSURLSessionDataTask *task, BOOL fromCache, LSBaseModel *model) {
        LSPersonsModel * cmodel = [LSPersonsModel modelWithJSON:model.result];
        !success?:success(cmodel);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)peopleNearbyWithSex:(NSString *)sex
                   success:(void (^)(NSArray * list))success
                   failure:(void (^)(NSError *))failure {

    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,kNearUserPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    params[@"sex"] = sex;
    
    [LSBaseModel BPOSTWithCache:path parameters:params success:^(NSURLSessionDataTask *task, BOOL fromCache, LSBaseModel *model) {
        
        NSMutableArray * arr = [NSMutableArray array];
        for (NSDictionary *dic in model.result) {
            
            LSPersonsModel * cmodel = [LSPersonsModel modelWithJSON:dic];
            [arr addObject:cmodel];
            
        }
        
        !success?:success(arr);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)positioningLongitude:(NSString *)longitude
                   latitude:(NSString *)latitude
                    success:(void (^)())success
                    failure:(void (^)(NSError *))failure {

    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,kUpdateLocationPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    params[@"lng"] = longitude;
    params[@"lat"] = latitude;
    
    [LSBaseModel BPOSTWithCache:path parameters:params success:^(NSURLSessionDataTask *task, BOOL fromCache, LSBaseModel *model) {
        
        NSMutableArray * arr = [NSMutableArray array];
        for (NSDictionary *dic in model.result) {
            
            LSPersonsModel * cmodel = [LSPersonsModel modelWithJSON:dic];
            [arr addObject:cmodel];
            
        }
        
        !success?:success(arr);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

@end
