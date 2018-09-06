//
//  LSHobbieModel.m
//  LittleSix
//
//  Created by GMAR on 2017/3/3.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSHobbieModel.h"
#import "ConstKeys.h"
#import "LSBaseModel.h"

@implementation LSHobbieModel

+ (void)hobbieWithlistToken:(NSString *)access_token
                    success:(void (^)(NSArray *array))success
                    failure:(void (^)(NSError *))failure {

    NSString *path = [NSString stringWithFormat:@"%@%@", kBaseUrl, kHobbiesPath];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;

    [LSBaseModel BPOST:path
        parameters:params
        success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
            LSHobbieModel *linkin = nil;
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in model.result) {
                linkin = [LSHobbieModel new];
                linkin.tag_id = dic[@"tag_id"];
                linkin.tag_name = dic[@"tag_name"];
                linkin.select_id = 0;
                [arr addObject:linkin];
            }

            !success ?: success(arr);

        }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
            !failure ?: failure(error);
        }];
}

@end

@implementation LSWorkModel

+ (void)workWithlistToken:(NSString *)access_token
                  success:(void (^)(NSArray *array))success
                  failure:(void (^)(NSError *))failure {

    NSString *path = [NSString stringWithFormat:@"%@%@", kBaseUrl, kWorkPath];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;

    [LSBaseModel BPOST:path
        parameters:params
        success:^(NSURLSessionDataTask *task, LSBaseModel *model) {

            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary *dic in model.result) {
                LSWorkModel *work = [LSWorkModel new];
                work.w_id = dic[@"id"];
                work.w_name = dic[@"name"];
                [arr addObject:work];
            }

            !success ?: success(arr);

        }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
            !failure ?: failure(error);
        }];
}

@end

@implementation LSAddSchoolModel

+ (void)addSchoolWithlistToken:(NSString *)access_token
                      andLevel:(NSInteger)level
                      edu_year:(NSInteger)edu_year
                     school_id:(NSInteger)school_id
                          note:(NSString *)note
                       success:(void (^)())success
                       failure:(void (^)(NSError *))failure {

    NSString *path = [NSString stringWithFormat:@"%@%@", kBaseUrl, kAddSchoolPath];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    params[@"level"] = @(level);
    params[@"edu_year"] = @(edu_year);
    params[@"school_id"] = @(school_id);
    params[@"note"] = note;

    [LSBaseModel BPOST:path
        parameters:params
        success:^(NSURLSessionDataTask *task, LSBaseModel *model) {

            !success ?: success();

        }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
            !failure ?: failure(error);
        }];
}

+(void)updateSchoolWithlistUser_id:(NSString *)user_id
                          edu_year:(NSInteger)edu_year
                         school_id:(NSInteger)school_id
                              note:(NSString *)note
                           success:(void (^)())success
                           failure:(void (^)(NSError *))failure {

    NSString *path = [NSString stringWithFormat:@"%@%@?us_id=%@", kBaseUrl, kUpdateSchoolPath,user_id];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    params[@"edu_year"] = @(edu_year);
    params[@"school_id"] = @(school_id);
    params[@"note"] = note;
    
    [LSBaseModel BPOST:path
            parameters:params
               success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
                   
                   !success ?: success();
                   
               }
               failure:^(NSURLSessionDataTask *task, NSError *error) {
                   !failure ?: failure(error);
               }];
}

@end

@implementation LSSchoolModels

+ (instancetype)modelWithDispalyName:(NSString *)name {
    LSSchoolModels *model = [LSSchoolModels new];
    model.displayName = name;
    return model;
}

+(void)searchSchoolWithlistToken:(NSString *)access_token
                             key:(NSString *)key
                           level:(int)level
                         success:(void (^)(NSArray *array))success
                         failure:(void (^)(NSError *))failure {
    
    //对搜索接口做处理
    NSString *strkey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *path = [NSString stringWithFormat:@"%@%@?key=%@&level=%d",kBaseUrl,kSearchSchooPath,strkey,level];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        NSMutableArray * arr = [NSMutableArray array];
        
        for (NSDictionary * schDic in model.result) {
            LSSchoolModels * smodel = [LSSchoolModels modelWithJSON:schDic];
            [arr addObject:smodel];
        }
        
        !success?:success(arr);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
    
}

@end
