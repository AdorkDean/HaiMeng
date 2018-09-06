//
//  LSIndexLinkInModel.m
//  LittleSix
//
//  Created by GMAR on 2017/3/4.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSIndexLinkInModel.h"
#import "LSBaseModel.h"
#import "ConstKeys.h"

@implementation LSIndexLinkInModel

+(void)indexLinkWithlistToken:(NSString *)access_token
                      success:(void (^)(NSArray *schoolArray,NSArray *regionArray,NSArray *clanArr,NSArray *cofcArr,NSArray *stribeArr))success
                      failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,kIndexLinkPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        NSArray *schArr = [NSArray modelArrayWithClass:[LSIndexLinkInModel class] json:model.result[@"school_list"]];
        NSArray *regionArr = [NSArray modelArrayWithClass:[LSIndexLinkInModel class] json:model.result[@"hometown_list"]];
        
        NSArray * clanArr = [NSArray modelArrayWithClass:[LSIndexLinkInModel class] json:model.result[@"clan_list"]];
        NSArray * cofcArr = [NSArray modelArrayWithClass:[LSIndexLinkInModel class] json:model.result[@"cofc_list"]];
        
        NSArray * stribeArr = [NSArray modelArrayWithClass:[LSIndexLinkInModel class] json:model.result[@"stribe_list"]];
        
        !success?:success(schArr,regionArr,clanArr,cofcArr,stribeArr);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}
+(void)indexLinkWithTribalCreateId:(NSString *)user_id
                           success:(void (^)(NSArray *list))success
                           failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@?user_id=%@",kBaseUrl,kStoretribePath,user_id];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        NSArray *arr = [NSArray modelArrayWithClass:[LSIndexLinkInModel class] json:model.result];
        
        !success?:success(arr);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}
@end
