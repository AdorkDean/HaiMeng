//
//  LSPostNewsModel.m
//  LittleSix
//
//  Created by GMAR on 2017/3/7.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSPostNewsModel.h"
#import "LSCaptureViewController.h"
#import "LSBaseModel.h"
#import "ConstKeys.h"
#import "HttpManager.h"


@implementation LSPostNewsModel

+(void)schoolWithHomeAndId:(NSString *)s_h_id
                      type:(int)type
                   success:(void (^)(LSPostNewsModel * model))success
                   failure:(void (^)(NSError *))failure {

    NSString * kPath = type == 1 ? kSchoolPath : kHometownlPath;
    NSString *path = [NSString stringWithFormat:@"%@%@?id=%@",kBaseUrl,kPath,s_h_id];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        LSPostNewsModel * nmodel = [LSPostNewsModel modelWithJSON:model.result];
        
        !success?:success(nmodel);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+ (void)postVideoLinkInWithFiles:(LSCaptureModel *)videoModel
                         content:(NSString *)content
                        id_value:(int)id_value
                    id_value_ext:(int)id_value_ext
                       feed_type:(int)feed_type
                         success:(void (^)(void))success
                         failure:(void (^)(NSError *error))failure{

    NSString *path = [kBaseUrl stringByAppendingPathComponent:kCreatefeedPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSURL * videoUrl = [videoModel localVideoFileURL];
    NSData *videoData = [NSData dataWithContentsOfURL:videoUrl];
    params[@"access_token"] =ShareAppManager.loginUser.access_token;
    params[@"content"] = content;
    params[@"id_value"] = @(id_value);
    params[@"id_value_ext"] = @(id_value_ext);
    params[@"feed_type"] = @(feed_type);
    
    
    
    [self uploadFiles:path parameters:params files:@[videoData] keys:@[@"files"] fileNames:@[@"files.mov"] mimeType:@"video/quicktime" uploadProgress:^(NSProgress *progress) {
        
    } success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        success();
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        
        failure(error);
        
        
    }];
}

+ (NSURLSessionDataTask *)uploadFiles:(NSString *)urlString parameters:(id)params files:(NSArray<NSData *> *)files keys:(NSArray<NSString *> *)keys fileNames:(NSArray<NSString *>*)names mimeType:(NSString *)mimeType uploadProgress:(void(^)(NSProgress *progress))progress success:(void (^)(NSURLSessionDataTask *,LSBaseModel * model))success failure:(void (^)(NSURLSessionDataTask *,NSError *error))failure {
    
    NSURLSessionDataTask *uploadTask = [ShareHttpManager POST:urlString parameters:params constructingBodyWithBlock:^(id < AFMultipartFormData > formData) {
        
        for (int i = 0; i < files.count; i++) {
            [formData appendPartWithFileData:files[i] name:keys[i] fileName:names[i] mimeType:mimeType];
        }
        
    } progress:^(NSProgress *uploadProgress) {
        
        if (progress) {
            progress(uploadProgress);
            NSLog(@"%@",uploadProgress);
        }
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        
        LSBaseModel *model = [LSBaseModel modelWithJSON:responseObject];
        NSLog(@"请求成功 === %@",responseObject);
        if (model.code == 1) {
            if (success) {
                success(task,model);
            }
        } else {
            NSError *error = [LSBaseModel errorFormatBaseModel:model];
            !failure?:failure(task,error);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(task,error);
    }];
    
    return uploadTask;
}

+(void)postNewsLinkWithlistToken:(NSString *)access_token
                           files:(NSArray *)files
                         content:(NSString *)content
                        id_value:(int)id_value
                    id_value_ext:(int)id_value_ext
                       feed_type:(int)feed_type
                         success:(void (^)())success
                         failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,kCreatefeedPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    if (files.count == 1) {
        params[@"files[]"] = files[0];
    }else{
        params[@"files[]"] = files;
    }
    
    params[@"content"] = content;
    params[@"id_value"] = @(id_value);
    params[@"id_value_ext"] = @(id_value_ext);
    params[@"feed_type"] = @(feed_type);
    
    NSMutableArray * arr = [NSMutableArray array];
    for (int i = 0; i < files.count; i ++) {
        [arr addObject:@"files[]"];
    }
    
    [LSBaseModel uploadImages:path parameters:params images:files keys:arr success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success();
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)commentsLinkWithlistToken:(NSString *)access_token
                         feed_id:(int)feed_id
                          uid_to:(int)uid_to
                         content:(NSString *)content
                             pid:(int)pid
                         success:(void (^)())success
                         failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,kCommentfeedPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    params[@"feed_id"] = @(feed_id);
    params[@"uid_to"] = @(uid_to);
    params[@"content"] = content;
    params[@"pid"] = @(pid);
    
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success();
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}
+(void)praiseLinkWithlistToken:(NSString *)access_token
                       feed_id:(int)feed_id
                          type:(int)type
                       success:(void (^)())success
                       failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@?feed_id=%d&type=%d",kBaseUrl,kPraisefeedPath,feed_id,type];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;

    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success();
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)delectLinkWithlistToken:(NSString *)access_token
                       feed_id:(int)feed_id
                       success:(void (^)())success
                       failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@?feed_id=%d",kBaseUrl,kDeletefeedPath,feed_id];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success();
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)delectCommentsWithlistToken:(NSString *)access_token
                           comm_id:(int)comm_id
                           success:(void (^)())success
                           failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@?comm_id=%d",kBaseUrl,kCommentPath,comm_id];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success();
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

@end

@implementation LSFriendsProfileModel

+(void)getFriendsProfileToken:(NSString *)access_token
                      user_id:(int)user_id
                      success:(void (^)(LSFriendsProfileModel *))success
                      failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,kUserinfoPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    params[@"user_id"] = @(user_id);
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        LSFriendsProfileModel * fmodel = [LSFriendsProfileModel modelWithJSON:model.result];
        !success?:success(fmodel);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

@end
