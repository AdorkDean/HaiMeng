//
//  LSTimeLineMsgModel.m
//  LittleSix
//
//  Created by Jim huang on 17/3/8.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSTimeLineMsgModel.h"
#import "LSAppManager.h"
#import "LSBaseModel.h"
@implementation LSTimeLineMsgModel

+ (void)getMsgListWithPage:(int)page Success:(void (^)(NSArray * modelArr))success failure:(void (^)(NSError *error))failure{
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kTimeLineMsgListPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString * getPath =[NSString stringWithFormat:@"%@?page=%d&size=%d",path,page,15];
    
    params[@"access_token"] =ShareAppManager.loginUser.access_token;
    
    [LSBaseModel BPOST:getPath parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        NSArray *listArr = [NSArray modelArrayWithClass:[LSTimeLineMsgModel class] json:model.result];
        !success?:success(listArr);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
    
}

+ (void)deleteAllMsgSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure{
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kTimeLineDeleteAllMsgPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] =ShareAppManager.loginUser.access_token;

    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
       success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+ (void)deleteMsgWithMessageId:(int)messageId Success:(void (^)(void))success failure:(void (^)(NSError *error))failure{
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kTimeLineDeleteOneMsgPath];
    NSString * getPath =[NSString stringWithFormat:@"%@?msg_id=%d",path,messageId];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] =ShareAppManager.loginUser.access_token;
    
    [LSBaseModel BPOST:getPath parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

@end
