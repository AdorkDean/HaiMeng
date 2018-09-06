//
//  LSContactModel.m
//  LittleSix
//
//  Created by GMAR on 2017/3/9.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSContactModel.h"
#import "LSBaseModel.h"
#import "ConstKeys.h"


@interface LSContactModel()

@property (retain,nonatomic) NSMutableDictionary *params1;
@end

@implementation LSContactModel


+(void)friendsWithlistToken:(NSString *)access_token
                    success:(void (^)(NSArray *array))success
                    failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,kFriendsPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    
    [LSBaseModel BPOSTWithCache:path parameters:params success:^(NSURLSessionDataTask *task, BOOL fromCache, LSBaseModel *model) {
        
        NSMutableArray * arr = [NSMutableArray array];

        for (NSDictionary * dic in model.result) {
            
            LSContactModel * conModel = [LSContactModel modelWithDictionary:dic];
            
            [arr addObject:conModel];
            
        }
        !success?:success(arr);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}
+(void)findFriendsWithlistToken:(NSString *)access_token
                            key:(NSString *)key
                        success:(void (^)(NSArray *array))success
                        failure:(void (^)(NSError *))failure{

    NSString *strkey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *path = [NSString stringWithFormat:@"%@%@?key=%@",kBaseUrl,kFindmanPath,strkey];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        NSMutableArray * arr = [NSMutableArray array];
        
        
        for (NSDictionary *dic in model.result) {
            LSContactModel * conModel = [LSContactModel modelWithJSON:dic];
            if (conModel != nil) {
                
                [arr addObject:conModel];
            }
            
        }
        
        
        !success?:success(arr);

        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
    
}

+(void)deleteFriendsWithlistToken:(NSString *)access_token
                              fid:(NSString *)fid
                          success:(void (^)())success
                          failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,kDeleteFriendsPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    params[@"fid"] = fid;
    
    [LSBaseModel BPOSTWithCache:path parameters:params success:^(NSURLSessionDataTask *task, BOOL fromCache, LSBaseModel *model) {
        
       
        !success?:success();
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
    
}
+(void)sendFriendsWithlistToken:(NSString *)access_token
                         uid_to:(NSString *)uid_to
                    friend_note:(NSString *)friend_note
                        success:(void (^)(LSContactModel* cmodel))success
                        failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,kSendFriendsPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    params[@"uid_to"] = uid_to;
    params[@"friend_note"] = friend_note;
    
    [LSBaseModel BPOSTWithCache:path parameters:params success:^(NSURLSessionDataTask *task, BOOL fromCache, LSBaseModel *model) {

        LSContactModel* cmodel = [LSContactModel modelWithJSON:model.result];
        !success?:success(cmodel);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        !failure?:failure(error);
    }];
    
}
+(void)isFriendsWithlistToken:(NSString *)access_token
                       uid_to:(NSString *)uid_to
                      success:(void (^)(LSContactModel * model))success
                      failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,kIsFriendsPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    params[@"uid_to"] = uid_to;
    
    [LSBaseModel BPOSTWithCache:path parameters:params success:^(NSURLSessionDataTask *task, BOOL fromCache, LSBaseModel *model) {
        LSContactModel * cmodel = [LSContactModel modelWithJSON:model.result];
        !success?:success(cmodel);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)dealWithWithlistToken:(NSString *)access_token
                         uid:(NSString *)uid
               feedback_mark:(NSString *)feedback_mark
                     success:(void (^)(LSContactModel * model))success
                     failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,kDealFriendsPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    params[@"id"] = uid;
    params[@"feedback_mark"] = feedback_mark;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        LSContactModel * cmodel = [LSContactModel modelWithJSON:model.result];
        !success?:success(cmodel);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
    
    
}

+(void)friendslogCountSuccess:(void (^)(NSString * messageCount))success
                    failure:(void (^)(NSError *))failure {

    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,kFriendslogCountPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        LSContactModel * cmodel = [LSContactModel new];
        cmodel.unicount = model.result[@"count"];
        !success?:success(cmodel.unicount);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];

}

@end

@implementation LSNewFriendstModel

+(void)newFriendsWithlistToken:(NSString *)access_token
                       success:(void (^)(NSArray *array))success
                       failure:(void (^)(NSError *))failure{
    
    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,kNewfriendsPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    
    [LSBaseModel BPOSTWithCache:path parameters:params success:^(NSURLSessionDataTask *task, BOOL fromCache, LSBaseModel *model) {
        
        NSMutableArray * arr = [NSMutableArray array];
        
        for (NSDictionary * dic in model.result) {
            
            LSNewFriendstModel * conModel = [LSNewFriendstModel modelWithJSON:dic];
            
            [arr addObject:conModel];
        }
        !success?:success(arr);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

@end
