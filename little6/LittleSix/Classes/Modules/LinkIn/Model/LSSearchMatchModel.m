//
//  LSSearchMatchModel.m
//  LittleSix
//
//  Created by GMAR on 2017/3/15.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSSearchMatchModel.h"
#import <YYKit/YYKit.h>
#import "LSBaseModel.h"
#import "ConstKeys.h"

@implementation LSSearchMatchModel

+(LSSearchMatchModel *)createLSSearchMatchModel:(NSDictionary *)dic{

    LSSearchMatchModel * model = [LSSearchMatchModel new];
    model.user_id = dic[@"user_id"];
    model.user_name = dic[@"user_name"];
    model.avatar = dic[@"avatar"];
    model.sex = dic[@"sex"];
    model.birthday = dic[@"birthday"];
    model.province = dic[@"province"];
    model.city = dic[@"city"];
    model.district = dic[@"district"];
    model.industry = dic[@"industry"];
    model.interest = dic[@"interest"];
    model.ht_province = dic[@"ht_province"];
    model.ht_city = dic[@"ht_city"];
    model.ht_district = dic[@"ht_district"];
    model.school = [LSSchModel createLSSchModel:dic[@"school"]];
    model.similar = dic[@"similar"];
    model.isSelect = NO;
    
    return model;
}

+(void)classmatesWithlistToken:(NSString *)access_token
                          home:(int)home
                          page:(int)page
                          size:(int)size
                       success:(void (^)(NSArray *array))success
                       failure:(void (^)(NSError *))failure {
    NSString * parameter = home == 0 ? kSameHomePath:home == 1 ?kSameSchoolPath:kRandPath;
    NSString *path = [NSString stringWithFormat:@"%@%@?page=%d&size=%d",kBaseUrl,parameter,page,size];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    
    [LSBaseModel BPOSTWithCache:path parameters:params success:^(NSURLSessionDataTask *task, BOOL fromCache, LSBaseModel *model) {
        
        NSMutableArray * arr = [NSMutableArray array];
        
        for (NSDictionary * dic in model.result) {
            
            LSSearchMatchModel * conModel = [LSSearchMatchModel createLSSearchMatchModel:dic];
            
            [arr addObject:conModel];
        }
        !success?:success(arr);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)searchWithlistToken:(NSString *)access_token
                      home:(int)home
                      page:(int)page
                      size:(int)size
                       key:(NSString *)key
                   success:(void (^)(NSArray *array))success
                   failure:(void (^)(NSError *))failure {

    //对搜索接口做处理
    NSString *strkey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *path = [NSString stringWithFormat:@"%@%@?page=%d&size=%d&key=%@",kBaseUrl,kSearchPath,page,size,strkey];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    
    [LSBaseModel BPOSTWithCache:path parameters:params success:^(NSURLSessionDataTask *task, BOOL fromCache, LSBaseModel *model) {
        
        NSMutableArray * arr = [NSMutableArray array];
        
        for (NSDictionary * dic in model.result) {
            
            LSSearchMatchModel * conModel = [LSSearchMatchModel createLSSearchMatchModel:dic];
            
            [arr addObject:conModel];
        }
        !success?:success(arr);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"school" : [LSSchModel class]};
}

//搜索人脉宗亲，好友
+(void)searchsWithlistToken:(NSString *)access_token
                      home:(int)home
                       key:(NSString *)key
                   success:(void (^)(NSArray *clanArray,NSArray *homeArray,NSArray *userArray,NSArray *schArray))success
                   failure:(void (^)(NSError *))failure {
    
    //对搜索接口做处理
    NSString *strkey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *path = [NSString stringWithFormat:@"%@%@?key=%@",kBaseUrl,kSearchgPath,strkey];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    
    [LSBaseModel BPOSTWithCache:path parameters:params success:^(NSURLSessionDataTask *task, BOOL fromCache, LSBaseModel *model) {
        
        NSArray *clanArr = [NSArray modelArrayWithClass:[LSSearchMatchModel class] json:model.result[@"clan"]];
        NSArray *homeArr = [NSArray modelArrayWithClass:[LSSearchMatchModel class] json:model.result[@"homes"]];
        
        NSArray * userArr = [NSArray modelArrayWithClass:[LSSearchMatchModel class] json:model.result[@"users"]];
        NSArray * schArr = [NSArray modelArrayWithClass:[LSSearchMatchModel class] json:model.result[@"schools"]];
    
        
        !success?:success(clanArr,homeArr,userArr,schArr);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

@end

@implementation LSSchModel

+(NSArray *)createLSSchModel:(NSArray *)list {

    NSMutableArray * arr = [NSMutableArray array];
    
    for (NSDictionary * dic in list) {
        
        LSSchModel * schModel = [LSSchModel new];
        schModel.name = dic[@"name"];
        schModel.user_id = dic[@"user_id"];
        schModel.school_id = dic[@"school_id"];
        schModel.level = dic[@"level"];
        schModel.departments = dic[@"departments"];
        schModel.edu_year = dic[@"edu_year"];
        
        [arr addObject:schModel];
        
    }
    
    return arr;
}

@end
