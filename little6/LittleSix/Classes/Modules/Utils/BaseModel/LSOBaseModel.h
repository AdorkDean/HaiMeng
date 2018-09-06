//
//  LSOBaseModel.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/28.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConstKeys.h"

@interface LSOBaseModel : NSObject

@property (nonatomic,assign) NSInteger code;
@property (nonatomic,copy) NSString *message;
@property (nonatomic,strong) id data;

+ (void)BGET:(NSString *)urlString parameters:(id)params success:(void (^)(LSOBaseModel *model))success failure:(void (^)(NSError *error))failure;

+ (void)BGETWithCache:(NSString *)urlString parameters:(id)params success:(void (^)(BOOL fromCache, LSOBaseModel *model))success failure:(void (^)(NSError *error))failure;

+ (void)BPOST:(NSString *)urlString parameters:(id)params success:(void (^)(LSOBaseModel *model))success failure:(void (^)(NSError *error))failure;

+ (void)BPOSTWithCache:(NSString *)urlString parameters:(id)params success:(void (^)(BOOL fromCache, LSOBaseModel *model))success failure:(void (^)(NSError *error))failure;

//图片上传
+ (void)uploadImage:(UIImage *)image uploadProgress:(void(^)(NSProgress *progress))progress success:(void (^)(LSOBaseModel *model))success failure:(void (^)(NSError *error))failure;

//音频上传
+ (void)uploadAudio:(NSString *)filePath uploadProgress:(void(^)(NSProgress *progress))progress success:(void (^)(LSOBaseModel *model))success failure:(void (^)(NSError *error))failure;

//视频上传
+ (void)uploadVideo:(NSString *)filePath uploadProgress:(void(^)(NSProgress *progress))progress success:(void (^)(LSOBaseModel *model))success failure:(void (^)(NSError *error))failure;

//文件上传
+ (NSURLSessionDataTask *)uploadFiles:(NSString *)urlString parameters:(id)params files:(NSArray<NSData *> *)files keys:(NSArray<NSString *> *)keys fileNames:(NSArray<NSString *>*)names mimeType:(NSString *)mimeType uploadProgress:(void(^)(NSProgress *progress))progress success:(void (^)(LSOBaseModel *model))success failure:(void (^)(NSError *error))failure ;

//文件和图片混合上传
+ (NSURLSessionDataTask *)uploadFilesAndVideo:(NSString *)urlString parameters:(id)params files:(NSArray<NSData *> *)files keys:(NSArray<NSString *> *)keys fileNames:(NSArray<NSString *>*)names mimeTypes:(NSArray<NSString *>*)mimeType uploadProgress:(void(^)(NSProgress *progress))progress success:(void (^)(LSOBaseModel *model))success failure:(void (^)(NSError *error))failure ;

@end
