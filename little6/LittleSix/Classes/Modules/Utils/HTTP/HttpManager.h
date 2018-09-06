//
//  HttpManager.h
//  AFNetworking
//
//  Created by AdminZhiHua on 16/6/1.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "Reachability.h"

#define ShareHttpManager [HttpManager shareHttpManager]
#define kReachabilityStatusChange @"kReachabilityChangedNotification"

typedef void (^SuccessResponse)(NSURLSessionDataTask *task, id responseObject);

typedef void (^CacheSuccessResponse)(NSURLSessionDataTask *task, BOOL fromCache, id responseObject);

typedef void (^FailureResponse)(NSURLSessionDataTask *task, NSError *error);
typedef void (^RequestProgress)(NSProgress *progress);
typedef void (^DownloadHandler)(NSURLResponse *response, NSURL *filePath, NSError *error);

@interface HttpManager : AFHTTPSessionManager

+ (instancetype)shareHttpManager;

#pragma mark - Get请求
//没有缓存Get请求
+ (void)GET:(NSString *)urlString parameters:(id)params success:(SuccessResponse)success failure:(FailureResponse)failure;

+ (void)GET:(NSString *)urlString parameters:(id)params requestProgress:(RequestProgress)progress success:(SuccessResponse)success failure:(FailureResponse)failure;

//有缓存的请求
+ (void)GETWithCache:(NSString *)urlString parameters:(id)params success:(CacheSuccessResponse)success failure:(FailureResponse)failure;

+ (void)GETWithCache:(NSString *)urlString parameters:(id)params requestProgress:(RequestProgress)progress success:(CacheSuccessResponse)success failure:(FailureResponse)failure;

#pragma mark - Post请求
//没有缓存的Post请求
+ (void)POST:(NSString *)urlString parameters:(id)params success:(SuccessResponse)success failure:(FailureResponse)failure;

+ (void)POST:(NSString *)urlString parameters:(id)params requestProgress:(RequestProgress)progress success:(SuccessResponse)success failure:(FailureResponse)failure;

//没有缓存的Post请求
+ (void)POSTWithCache:(NSString *)urlString parameters:(id)params success:(CacheSuccessResponse)success failure:(FailureResponse)failure;

+ (void)POSTWithCache:(NSString *)urlString parameters:(id)params requestProgress:(RequestProgress)progress success:(CacheSuccessResponse)success failure:(FailureResponse)failure;

#pragma mark - 其他请求
// 文件下载
+ (NSURLSessionDownloadTask *)download:(NSString *)urlString downloadProgress:(RequestProgress)progress completeHandler:(DownloadHandler)handler;
// 视频下载
+ (NSURLSessionDownloadTask *)downloadViode:(NSURL *)url downloadProgress:(RequestProgress)progress completeHandler:(DownloadHandler)handler;
//图片上传
+ (NSURLSessionDataTask *)uploadImage:(NSString *)urlString parameters:(id)params images:(NSArray *)images keys:(NSArray *)keys uploadProgress:(RequestProgress)progress success:(SuccessResponse)success failure:(FailureResponse)failure;

//视频上传
+ (NSURLSessionDataTask *)uploadVideo:(NSString *)urlString parameters:(id)params video:(NSData *)video key:(NSString *)key uploadProgress:(RequestProgress)progress success:(SuccessResponse)success failure:(FailureResponse)failure;

//取消请求
+ (void)httpCancelAllRequest;

#pragma mark - 网络监听

///需要添加监听通知 kReachabilityChangedNotification
- (void)startNotifierReachability;

- (void)stopNotifierReachability;

@end
