//
//  LSOBaseModel.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/28.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSOBaseModel.h"
#import "HttpManager.h"
#import "UIImage+LSCompression.h"

@implementation LSOBaseModel

+ (void)BGET:(NSString *)urlString parameters:(id)params success:(void (^)(LSOBaseModel *))success failure:(void (^)(NSError *))failure {
    
    [HttpManager GET:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        LSOBaseModel *model = [LSOBaseModel modelWithJSON:responseObject];
        NSLog(@"%@== %@",task.response,responseObject);
        if (model.code == 0 || model.code == 3) {
            if (success) {
                success(model);
            }
        } else {
            if (failure) {
                NSError *error = [self errorFormatBaseModel:model];
                failure(error);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
    }];
}

+ (void)BGETWithCache:(NSString *)urlString parameters:(id)params success:(void (^)(BOOL fromCache, LSOBaseModel *))success failure:(void (^)(NSError *))failure {
    
    [HttpManager GETWithCache:urlString parameters:params success:^(NSURLSessionDataTask *task, BOOL fromCache, id responseObject) {
        
        LSOBaseModel *model = [LSOBaseModel modelWithJSON:responseObject];
        
        if (model.code == 0) {
            if (success) {
                success(fromCache, model);
            }
        } else {
            if (failure) {
                NSError *error = [self errorFormatBaseModel:model];
                failure(error);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"===%@ == %@",task.response,error);
        if (failure) {
            failure(error);
        }
        
    }];
    
}

+ (void)BPOST:(NSString *)urlString parameters:(id)params success:(void (^)(LSOBaseModel *))success failure:(void (^)(NSError *))failure {
    
    [HttpManager POST:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        LSOBaseModel *model = [LSOBaseModel modelWithJSON:responseObject];
        
        if (!model) {//没有返回值的情况
            if (success) {
                success(model);
            }
        } else {
            if (model.code == 0) {
                if (success) {
                    success(model);
                }
            } else {
                if (failure) {
                    NSError *error = [self errorFormatBaseModel:model];
                    failure(error);
                }
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
    }];
    
}

+ (void)BPOSTWithCache:(NSString *)urlString parameters:(id)params success:(void (^)(BOOL fromCache, LSOBaseModel *))success failure:(void (^)(NSError *))failure {
    
    [HttpManager POSTWithCache:urlString parameters:params success:^(NSURLSessionDataTask *task, BOOL fromCache, id responseObject) {
        
        LSOBaseModel *model = [LSOBaseModel modelWithJSON:responseObject];
        
        if (model.code == 0) {
            if (success) {
                success(fromCache, model);
            }
        } else {
            if (failure) {
                NSError *error = [self errorFormatBaseModel:model];
                failure(error);
            }
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (failure) {
            failure(error);
        }
        
    }];
    
}


+ (void)uploadImage:(UIImage *)image uploadProgress:(void (^)(NSProgress *))progress success:(void (^)(LSOBaseModel *))success failure:(void (^)(NSError *))failure {
    
    NSString *path = [kWSUploadUrl stringByAppendingPathComponent:kUploadImagePath];
    
    NSData *data = [UIImage compressionImage:image];
    
    [self uploadFiles:path parameters:nil files:@[data] keys:@[@"file"] fileNames:@[@"file.jpg"] mimeType:@"image/jpeg" uploadProgress:progress success:^(LSOBaseModel *model) {
        !success?:success(model);
    } failure:^(NSError *error) {
        !failure?:failure(error);
    }];
}

+ (void)uploadAudio:(NSString *)filePath uploadProgress:(void (^)(NSProgress *))progress success:(void (^)(LSOBaseModel *))success failure:(void (^)(NSError *))failure {
    
    NSString *path = [kWSUploadUrl stringByAppendingPathComponent:kUploadAudioPath];
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    [self uploadFiles:path parameters:nil files:@[data] keys:@[@"file"] fileNames:@[@"file.caf"] mimeType:@"audio/mp3" uploadProgress:progress success:^(LSOBaseModel *model) {
        !success?:success(model);
    } failure:^(NSError *error) {
        !failure?:failure(error);
    }];
}

+ (void)uploadVideo:(NSString *)filePath uploadProgress:(void (^)(NSProgress *))progress success:(void (^)(LSOBaseModel *))success failure:(void (^)(NSError *))failure {
    
    NSString *path = [kWSUploadUrl stringByAppendingPathComponent:kUploadVideoPath];
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    [self uploadFiles:path parameters:nil files:@[data] keys:@[@"file"] fileNames:@[@"files.mov"] mimeType:@"video/quicktime" uploadProgress:progress success:^(LSOBaseModel *model) {
        !success?:success(model);
    } failure:^(NSError *error) {
        !failure?:failure(error);
    }];
    
}

+ (NSURLSessionDataTask *)uploadFiles:(NSString *)urlString parameters:(id)params files:(NSArray<NSData *> *)files keys:(NSArray<NSString *> *)keys fileNames:(NSArray<NSString *>*)names mimeType:(NSString *)mimeType uploadProgress:(void(^)(NSProgress *progress))progress success:(void (^)(LSOBaseModel *model))success failure:(void (^)(NSError *error))failure {
    
    NSURLSessionDataTask *uploadTask = [ShareHttpManager POST:urlString parameters:params constructingBodyWithBlock:^(id < AFMultipartFormData > formData) {
        
        for (int i = 0; i < files.count; i++) {
            [formData appendPartWithFileData:files[i] name:keys[i] fileName:names[i] mimeType:mimeType];
        }
        
    } progress:^(NSProgress *uploadProgress) {
        
        if (progress) {
            progress(uploadProgress);
        }
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        
        LSOBaseModel *model = [LSOBaseModel modelWithJSON:responseObject];
        
        if (model.code == 0) {
            !success?:success(model);
        } else {
            NSError *error = [self errorFormatBaseModel:model];
            !failure?:failure(error);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
    
    return uploadTask;
}


+ (NSURLSessionDataTask *)uploadFilesAndVideo:(NSString *)urlString parameters:(id)params files:(NSArray<NSData *> *)files keys:(NSArray<NSString *> *)keys fileNames:(NSArray<NSString *>*)names mimeTypes:(NSArray<NSString *>*)mimeType uploadProgress:(void(^)(NSProgress *progress))progress success:(void (^)(LSOBaseModel *model))success failure:(void (^)(NSError *error))failure {
    
    NSURLSessionDataTask *uploadTask = [ShareHttpManager POST:urlString parameters:params constructingBodyWithBlock:^(id < AFMultipartFormData > formData) {
        
        for (int i = 0; i < files.count; i++) {
            [formData appendPartWithFileData:files[i] name:keys[i] fileName:names[i] mimeType:mimeType[i]];
        }
        
    } progress:^(NSProgress *uploadProgress) {
        
        if (progress) {
            progress(uploadProgress);
        }
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        
        LSOBaseModel *model = [LSOBaseModel modelWithJSON:responseObject];
        
        if (model.code == 0) {
            !success?:success(model);
        } else {
            NSError *error = [self errorFormatBaseModel:model];
            !failure?:failure(error);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
    
    return uploadTask;
}





//格式化错误信息
+ (NSError *)errorFormatBaseModel:(LSOBaseModel *)baseModel {
    
    NSString *msg = baseModel.message;
    NSInteger code = baseModel.code;
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    
    if (msg) {
        [userInfo setObject:msg forKey:NSLocalizedFailureReasonErrorKey];
    } else {
        [userInfo setObject:@"服务异常" forKey:NSLocalizedFailureReasonErrorKey];
    }
    
    NSError *formattedError = [[NSError alloc] initWithDomain:NSOSStatusErrorDomain code:code userInfo:userInfo];
    return formattedError;
}


@end
