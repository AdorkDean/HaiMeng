//
//  LSBaseModel.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSBaseModel.h"
#import "HttpManager.h"
#import "UIView+HUD.h"

@implementation LSBaseModel

+ (void)BGET:(NSString *)urlString parameters:(id)params success:(void (^)(NSURLSessionDataTask *, LSBaseModel *))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {

    [HttpManager GET:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {

        [self reduceResponseObject:responseObject sessionTask:task isFromCache:NO success:^(NSURLSessionDataTask *task, BOOL fromCache, LSBaseModel *model) {
            !success?:success(task,model);
        } failure:failure];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self failureReduce:task error:error complete:failure];
    }];
}

+ (void)BGETWithCache:(NSString *)urlString parameters:(id)params success:(void (^)(NSURLSessionDataTask *, BOOL, LSBaseModel *))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {

    [HttpManager GETWithCache:urlString parameters:params success:^(NSURLSessionDataTask *task, BOOL fromCache, id responseObject) {

        [self reduceResponseObject:responseObject sessionTask:task isFromCache:fromCache success:success failure:failure];

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self failureReduce:task error:error complete:failure];
    }];
}

+ (void)BPOST:(NSString *)urlString parameters:(id)params success:(void (^)(NSURLSessionDataTask *, LSBaseModel *))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {

    [HttpManager POST:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSLog(@"请求成功 === %@ == %@", task.response, responseObject);

        [self reduceResponseObject:responseObject sessionTask:task isFromCache:NO success:^(NSURLSessionDataTask *task, BOOL fromCache, LSBaseModel *model) {
            !success?:success(task,model);
        } failure:failure];

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"请求失败====%@", task.response);
        [self failureReduce:task error:error complete:failure];
    }];
}

+ (void)BPOSTWithCache:(NSString *)urlString parameters:(id)params success:(void (^)(NSURLSessionDataTask *, BOOL, LSBaseModel *))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    [HttpManager POSTWithCache:urlString parameters:params success:^(NSURLSessionDataTask *task, BOOL fromCache, id responseObject) {
        
        [self reduceResponseObject:responseObject sessionTask:task isFromCache:fromCache success:success failure:failure];

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self failureReduce:task error:error complete:failure];
    }];
    
}

+ (void)failureReduce:(NSURLSessionDataTask *)task error:(NSError *)error complete:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    
    NSHTTPURLResponse * responses = (NSHTTPURLResponse *)task.response;
    if (responses.statusCode == 401) {
        [LSKeyWindow showAlertWithTitle:@"提示" message:@"账号使用异常,请重新登录" cancelAction:^{
            [LSAppManager logout];
        } doneAction:^{
            [LSAppManager logout];
        }];
        return;
    }
    else {
        !failure?:failure(task,error);
    }
}

//返回数据的处理
+ (void)reduceResponseObject:(id)responseObject sessionTask:(NSURLSessionDataTask *)task isFromCache:(BOOL)fromCache success:(void (^)(NSURLSessionDataTask *task,BOOL fromCache, LSBaseModel *model))success failure:(void (^)(NSURLSessionDataTask *task,NSError *error))failure {
    
    LSBaseModel *model = [LSBaseModel modelWithJSON:responseObject];
    
    NSHTTPURLResponse * responses = (NSHTTPURLResponse *)task.response;
    
    if (responses.statusCode == 401) {
        [LSKeyWindow showAlertWithTitle:@"提示" message:@"账号使用异常,请重新登录" cancelAction:^{
            [LSAppManager logout];
        } doneAction:^{
            [LSAppManager logout];
        }];
        return;
    }

    if (model.code == 1) {
        if (success) {
            success(task, fromCache, model);
        }
    }
    else {
        NSError *error = [self errorFormatBaseModel:model];
        !failure?:failure(task,error);
    }
}

//格式化错误信息
+ (NSError *)errorFormatBaseModel:(LSBaseModel *)baseModel {
    NSString *msg = baseModel.message;

    NSInteger code = baseModel.code;

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];

    if (msg) {
        [userInfo setObject:msg forKey:NSLocalizedFailureReasonErrorKey];
    } else {
        [userInfo setObject:@"服务异常" forKey:NSLocalizedFailureReasonErrorKey];
    }

    //设置statusCode
    if ([baseModel.result isKindOfClass:[NSDictionary class]]) {
        NSString *statusCode = baseModel.result[@"statusCode"];
        if (statusCode) {
            code = [statusCode integerValue];
        }
    }

    NSError *formattedError = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:code userInfo:userInfo];

    return formattedError;
}

+ (void)uploadImages:(NSString *)urlString
          parameters:(id)params
              images:(NSArray *)images
                keys:(NSArray *)keys
             success:(void (^)(NSURLSessionDataTask *, LSBaseModel *))success
             failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {

    [HttpManager uploadImage:urlString
        parameters:params
        images:images
        keys:keys
        uploadProgress:nil
        success:^(NSURLSessionDataTask *task, id responseObject) {

            LSBaseModel *model = [LSBaseModel modelWithJSON:responseObject];
            NSLog(@"请求成功 === %@", responseObject);
            if (model.code == 1) {
                if (success) {
                    success(task, model);
                }
            } else {
                NSError *error = [self errorFormatBaseModel:model];
                !failure ?: failure(task, error);
            }

        }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
            !failure ?: failure(task, error);
        }];
}

+ (NSString *)errorMessageFromError:(NSError *)error {

    if (!error) return nil;

    if (error.code == -1009) {
        return @"网络异常";
    }

    id userInfo = [error userInfo];
    NSString *errorMsg;

    if ([userInfo objectForKey:NSLocalizedFailureReasonErrorKey]) {
        errorMsg = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    } else if ([userInfo objectForKey:NSLocalizedRecoverySuggestionErrorKey]) {
        errorMsg = [userInfo objectForKey:NSLocalizedRecoverySuggestionErrorKey];
    } else {
        errorMsg = [error localizedDescription];
    }

    return errorMsg;
}

+ (void)BPOSTGroup:(NSString *)urlString
        parameters:(id)params
           success:(void (^)(NSURLSessionDataTask *task, LSBaseModel *model))success
           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {

    [HttpManager POST:urlString
        parameters:params
        success:^(NSURLSessionDataTask *task, id responseObject) {

            LSBaseModel *model = [LSBaseModel modelWithJSON:responseObject];
            NSLog(@"请求成功==== %@ == %@", task.response, responseObject);
            if (!model) { //没有返回值的情况
                if (success) {
                    success(task, model);
                }
            } else {
                if (model.code == 0) {
                    if (success) {
                        success(task, model);
                    }
                } else {
                    NSError *error = [self errorFormatBaseModel:model];
                    !failure ?: failure(task, error);
                }
            }

        }
        failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"请求失败====%@", task.response);
            !failure ?: failure(task, error);
        }];
}

@end
