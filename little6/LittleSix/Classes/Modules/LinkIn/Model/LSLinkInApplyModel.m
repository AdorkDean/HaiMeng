//
//  LSLinkInApplyModel.m
//  LittleSix
//
//  Created by GMAR on 2017/4/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSLinkInApplyModel.h"
#import "LSBaseModel.h"
#import "ConstKeys.h"

@implementation LSLinkInApplyModel

+(void)linkInApplyWithName:(NSString *)name
                  province:(NSString *)provinceId
                      city:(NSString *)cityId
                  district:(NSString *)districtId
                      type:(NSString *)type
                   success:(void (^)())success
                   failure:(void (^)(NSError *))failure {
    
    NSString * pathStr = [type isEqualToString:@"宗亲"] ? kClanCreatePath : [type isEqualToString:@"商会"] ? kCofcCreatePath : kStoretribeCreatePath;
    
    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,pathStr];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    params[@"name"] = name;
    params[@"province"] = provinceId;
    params[@"city"] = cityId;
    params[@"district"] = districtId;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success();
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)linkInApplyWithC_id:(NSString *)c_id
                      name:(NSString *)name
                      desc:(NSString *)desc
                   contact:(NSString *)contact
                  province:(NSString *)province
                      city:(NSString *)city
                  district:(NSString *)district
                   address:(NSString *)address
                      type:(int)type
                   success:(void (^)())success
                   failure:(void (^)(NSError *))failure{

    NSString * pathStr = type == 4 ? kClanUpdatePath : type == 5 ? kStoretribeUpdatePath : kCofcUpdatePath;
    
    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,pathStr];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    if (type == 3) {
        params[@"cofc_id"] = c_id;
    }else if (type == 4){
        params[@"clan_id"] = c_id;
    }else if (type == 5){
        
        params[@"stribe_id"] = c_id;
    }
    
    if (![name isEqualToString:@""]) {
        params[@"name"] = name;
    }
    if (![desc isEqualToString:@""]) {
        params[@"desc"] = desc;
    }
    if (![contact isEqualToString:@""]) {
        params[@"contact"] = contact;
    }
    if (![province isEqualToString:@""]) {
        params[@"province"] = province;
    }
    if (![city isEqualToString:@""]) {
        params[@"city"] = city;
    }
    if (![district isEqualToString:@""]) {
        params[@"district"] = district;
    }
    if (![address isEqualToString:@""]) {
        params[@"address"] = address;
    }
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success();
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)linkInApplyWithC_id:(NSString *)c_id
                      logo:(UIImage *)logo
                    banner:(UIImage *)banner
                      type:(int)type
                   success:(void (^)(NSDictionary *dic))success
                   failure:(void (^)(NSError *))failure {

    NSString * pathStr = type == 4 ? kClanUpdatePath : type == 5 ? kStoretribeUpdatePath : kCofcUpdatePath;
    
    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,pathStr];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    if (type == 3) {
        params[@"cofc_id"] = c_id;
    }else if (type == 4){
        params[@"clan_id"] = c_id;
    }else if (type == 5){
    
        params[@"stribe_id"] = c_id;
    }
    UIImage *scaledImage = timeLineBigPlaceholderName;
    NSString * scaledStr = @"";
    if (logo != nil) {
        params[@"logo"] = logo;
        scaledStr = @"logo";
        UIGraphicsBeginImageContext(CGSizeMake(640.0,640.0));
        [logo drawInRect:CGRectMake(0, 0, 640.0, 640.0)];
        scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    if (banner != nil) {
        params[@"banner"] = banner;
        scaledStr = @"banner";
        UIGraphicsBeginImageContext(CGSizeMake(640.0,640.0));
        [banner drawInRect:CGRectMake(0, 0, 640.0, 640.0)];
        scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    
    [LSBaseModel uploadImages:path parameters:params images:@[scaledImage] keys:@[scaledStr] success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success(model.result);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)linkInFocusWithC_id:(NSString *)c_id
                      type:(int)type
                   success:(void (^)())success
                   failure:(void (^)(NSError *))failure {

    NSString * pathStr = type == 4 ? kClanFoucePath : type == 5 ? kStoretribeFoucePath : kCofcFoucePath;
    NSString * parameter = type == 4 ? @"clan_id" : type == 5 ? @"stribe_id" : @"cofc_id";
    NSString *path = [NSString stringWithFormat:@"%@%@?%@=%@",kBaseUrl,pathStr,parameter,c_id];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success();
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)linkInCancelFocusWithC_id:(NSString *)c_id
                            type:(int)type
                         success:(void (^)())success
                         failure:(void (^)(NSError *))failure {

    NSString * pathStr = type == 4 ? kClanCancelFoucePath : type == 5 ? kStoretribeCancelFoucePath : kCofcCancelFoucePath;
    NSString * parameter = type == 4 ? @"clan_id" : type == 5 ? @"stribe_id" : @"cofc_id";
    NSString *path = [NSString stringWithFormat:@"%@%@?%@=%@",kBaseUrl,pathStr,parameter,c_id];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success();
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)linkInIsFocusWithC_id:(NSString *)c_id
                        type:(int)type
                     success:(void (^)(NSString * isfocus))success
                     failure:(void (^)(NSError *))failure {

    NSString * pathStr = type == 4 ? kClanIsFoucePath : type == 5 ? kStoretribeIsFoucePath : kCofcIsFoucePath;
    NSString * parameter = type == 4 ? @"clan_id" : type == 5 ? @"stribe_id" :@"cofc_id";
    NSString *path = [NSString stringWithFormat:@"%@%@?%@=%@",kBaseUrl,pathStr,parameter,c_id];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success([NSString stringWithFormat:@"%ld",model.code]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)linkInCelebrityWithC_id:(NSString *)c_id
                          logo:(UIImage *)photo
                          name:(NSString *)name
                          desc:(NSString *)desc
                          type:(int)type
                       success:(void (^)(NSDictionary *dic))success
                       failure:(void (^)(NSError *))failure {

    NSString * pathStr = type == 4 ? kClanAddPath : kCofcAddPath;
    
    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,pathStr];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    if (type == 3) {
        params[@"cofc_id"] = c_id;
    }else if (type == 4){
        params[@"clan_id"] = c_id;
    }
    
    params[@"name"] = name;
    params[@"desc"] = desc;
    
    UIImage *scaledImage = timeLineBigPlaceholderName;
    NSString * scaledStr = @"";
    if (photo != nil) {
        params[@"photo"] = photo;
        scaledStr = @"photo";
        UIGraphicsBeginImageContext(CGSizeMake(640.0,640.0));
        [photo drawInRect:CGRectMake(0, 0, 640.0, 640.0)];
        scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    [LSBaseModel uploadImages:path parameters:params images:@[scaledImage] keys:@[scaledStr] success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success(model.result);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

//删除宗亲，商会
+(void)linkInApplyDelectWithC_id:(NSString *)c_id
                            type:(int)type
                         success:(void (^)())success
                         failure:(void (^)(NSError *))failure {

    NSString * pathStr = type == 4 ? kClanDeletePath : type == 3 ? kCofcDeletePath : kStoretribeDeletePath;
    NSString * parameter = type == 4 ? @"clan_id" : type == 3 ?  @"cofc_id" : @"stribe_id";
    NSString *path = [NSString stringWithFormat:@"%@%@?%@=%@",kBaseUrl,pathStr,parameter,c_id];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success();
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

//编辑名人
+(void)linkInUpdateCelebrityWithC_id:(NSString *)c_id
                                logo:(UIImage *)photo
                                name:(NSString *)name
                                desc:(NSString *)desc
                                type:(int)type
                             success:(void (^)(NSDictionary *dic))success
                             failure:(void (^)(NSError *))failure {

    NSString * pathStr = type == 4 ? kClanUpdateCelebrityPath : kCofcUpdateCelebrityPath;
    
    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,pathStr];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    params[@"cele_id"] = c_id;
    params[@"name"] = name;
    params[@"desc"] = desc;
    
    UIImage *scaledImage = timeLineBigPlaceholderName;
    NSString * scaledStr = @"";
    if (photo != nil) {
        params[@"photo"] = photo;
        scaledStr = @"photo";
        UIGraphicsBeginImageContext(CGSizeMake(640.0,640.0));
        [photo drawInRect:CGRectMake(0, 0, 640.0, 640.0)];
        scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    [LSBaseModel uploadImages:path parameters:params images:@[scaledImage] keys:@[scaledStr] success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success(model.result);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)linkInCelebrityDeleteWithC_id:(NSString *)c_id
                                type:(int)type
                             success:(void (^)())success
                             failure:(void (^)(NSError *))failure {

    NSString * pathStr = type == 4 ? kClanCelebrityDeletePath : kCofcCelebrityDeletePath;
    NSString *path = [NSString stringWithFormat:@"%@%@?id=%@",kBaseUrl,pathStr,c_id];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success();
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

//宗亲，商会更多的列表
+(void)linkInApplyListWithPage:(int)page
                          type:(NSString *)type
                       success:(void (^)(NSArray * list))success
                       failure:(void (^)(NSError *))failure {

    NSString * pathStr = [type intValue] == 4 ? kClanHotSearchPath : kCofcHotSearchPath;
    NSString * size = @"10";
    NSString *path = [NSString stringWithFormat:@"%@%@?page=%d&size=%@",kBaseUrl,pathStr,page,size];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        NSArray * arr = [NSArray modelArrayWithClass:[LSLinkInApplyModel class] json:model.result];
        
        !success?:success(arr);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

@end

@implementation LSLinkInInformationModel

+(void)linkInInfoWithC_id:(NSString *)c_id
                     type:(int)type
                  success:(void (^)(LSLinkInInformationModel * model))success
                  failure:(void (^)(NSError *))failure {

    NSString * pathStr = type == 4 ? kClanGetInfoPath : type == 5 ? kStoretribeGetInfoPath : kCofcGetInfoPath ;
    NSString * parameter = type == 4 ? @"clan_id" : type == 5 ? @"stribe_id" : @"cofc_id";
    NSString *path = [NSString stringWithFormat:@"%@%@?%@=%@",kBaseUrl,pathStr,parameter,c_id];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        LSLinkInInformationModel * info = [LSLinkInInformationModel modelWithJSON:model.result];
        !success?:success(info);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

@end
