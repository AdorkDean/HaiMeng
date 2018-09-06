//
//  LSPostTimeLineModel.m
//  LittleSix
//
//  Created by Jim huang on 17/3/4.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSPostTimeLineModel.h"
#import "LSBaseModel.h"
#import "LSCaptureViewController.h"
#import "HttpManager.h"
#import <AVFoundation/AVFoundation.h>

#define ShareAppManager [LSAppManager sharedAppManager]

@implementation LSPostTimeLineModel

+ (void)postTimeLineWithContent:(NSString *)content files:(NSArray *)imageArray whoSeeType:(SelectContactViewType)type whoSeeExt:(NSString*)ext position:(NSString *)position remindUser:(NSString *)remindUser success:(void (^)(LSPostTimeLineModel * model))success failure:(void (^)(NSError *error))failure {
    
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kPostTimeLinePath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSMutableArray *keys =[NSMutableArray array];
    for (int index = 0 ; index<imageArray.count ;index++) {
        [keys addObject:@"files[]"];
    }
    params[@"access_token"] =ShareAppManager.loginUser.access_token;
    params[@"content"] = content;
    params[@"who_see"] =[NSNumber numberWithInt:type];
    params[@"who_see_ext"] = ext;
    params[@"remind_user"] = remindUser;
    
    if (imageArray.count>0 && keys.count>0) {
        [LSBaseModel uploadImages:path parameters:params images:imageArray keys:keys success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
            
            
            LSPostTimeLineModel *postModel = [LSPostTimeLineModel modelWithJSON:model.result];
            !success?:success(postModel);
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            !failure?:failure(error);
        }];
        
    }else{
    
        [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
            
            LSPostTimeLineModel *postModel = [LSPostTimeLineModel modelWithJSON:model.result];
            !success?:success(postModel);
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            !failure?:failure(error);
            
        }];
    
    }

}

+ (void)postVideoTimeLineWithContent:(NSString *)content videoModel:(LSCaptureModel *)videoModel whoSeeType:(SelectContactViewType)type whoSeeExt:(NSString*)ext position:(NSString *)position remindUser:(NSString *)remindUser Progress:(void (^)(NSProgress * Progress))Progress success:(void (^)(void))success failure:(void (^)(NSError *error))failure{
    
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kPostVideoTimeLinePath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSURL * videoUrl = [videoModel localVideoFileURL];
    NSData *videoData = [NSData dataWithContentsOfURL:videoUrl];
    params[@"access_token"] =ShareAppManager.loginUser.access_token;
    params[@"content"] = content;
    params[@"who_see"] =[NSNumber numberWithInt:type];
    params[@"who_see_ext"] = ext;
    params[@"remind_user"] = remindUser;
    
    NSString * fileStr =[videoUrl.absoluteString lastPathComponent];
    NSString * mimeType;
    NSString * formatStr;
    [fileStr stringByReplacingOccurrencesOfString:@".MOV" withString:@".mov"];
    if ([fileStr containsString:@".mov" ]||[fileStr containsString:@".MOV"]) {
        mimeType = @"video/quicktime";
        formatStr = @"files.mov";
    }
    else if ([fileStr containsString:@".mp4"]||[fileStr containsString:@".MP4"]) {
        mimeType = @"video/mp4";
        formatStr = @"files.mp4";
    }

    
    [self uploadFiles:path parameters:params files:@[videoData] keys:@[@"files"] fileNames:@[formatStr] mimeType:mimeType uploadProgress:^(NSProgress *progress) {
        
        Progress(progress);
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

@end
