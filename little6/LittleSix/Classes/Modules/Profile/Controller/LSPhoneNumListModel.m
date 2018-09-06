//
//  LSPhoneNumListModel.m
//  LittleSix
//
//  Created by Jim huang on 17/3/29.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSPhoneNumListModel.h"
#import "LSBaseModel.h"

@implementation LSPhoneNumListModel

+(void)searchFriendWithPhoneList:(NSString *)phoneList Success:(void (^)(NSArray * modelArr))success failure:(void (^)(NSError *error))failure{
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kSearhFriendWithPhoneListPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] =ShareAppManager.loginUser.access_token;
    params[@"phones"] =phoneList;

    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        NSArray * listArr = [NSArray modelArrayWithClass:[LSPhoneNumListModel class] json:model.result];
        !success?:success(listArr);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        !failure?:failure(error);
    }];
    
}

+(void)addFriendWithUserID:(NSString *)UserID  Success:(void (^)(void))success failure:(void (^)(NSError *error))failure{
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kSendFriendsPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] =ShareAppManager.loginUser.access_token;
    params[@"uid_to"] =UserID;
    params[@"friend_note"] =@"通过一下呗";

    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        !success?:success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

@end
