//
//  LSLinkMessageModel.m
//  LittleSix
//
//  Created by GMAR on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSLinkMessageModel.h"
#import "LSBaseModel.h"
#import "ConstKeys.h"

@implementation LSLinkMessageModel


+(void)messageLinkWithlistToken:(NSString *)access_token
                           page:(int)page
                           size:(int)size
                        success:(void (^)(NSArray *array))success
                        failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@?page=%d&size=%d",kBaseUrl,kContactsmsgPath,page,size];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        NSMutableArray * arr = [NSMutableArray array];
        for (NSDictionary * dic in model.result) {
            LSLinkMessageModel * Message = [LSLinkMessageModel modelWithJSON:dic];
            
            [arr addObject:Message];
        }
        
        !success?:success(arr);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)cleanListMessageLinkWithlistToken:(NSString *)access_token
                                 success:(void (^)())success
                                 failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,kContactflushallPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success();
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)deleteOneMessageLinkWithlistToken:(NSString *)access_token
                                  msg_id:(int)msg_id
                                 success:(void (^)())success
                                 failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@?msg_id=%d",kBaseUrl,kContactdeletePath,msg_id];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success();
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

@end
