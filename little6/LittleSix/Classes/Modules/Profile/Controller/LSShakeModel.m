//
//  LSShakeModel.m
//  LittleSix
//
//  Created by Jim huang on 17/3/18.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSShakeModel.h"
#import "LSBaseModel.h"
@implementation LSShakeModel


+(void)shakeFriendSuccess:(void (^)(LSShakeModel * model))success failure:(void (^)(NSError *error))failure{
        NSString *path = [kBaseUrl stringByAppendingPathComponent:kShakePath];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"access_token"] =ShareAppManager.loginUser.access_token;
        
        
        [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
            
            LSShakeModel * shakeModel = [LSShakeModel modelWithJSON:model.result];
            !success?:success(shakeModel);

        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            !failure?:failure(error);
            
            
        }];
    
    
}

@end
