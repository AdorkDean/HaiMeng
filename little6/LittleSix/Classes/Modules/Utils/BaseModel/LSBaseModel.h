//
//  LSBaseModel.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSBaseModel : NSObject

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) id  result;
@property (nonatomic,strong) id data;

+ (void)BGET:(NSString *)urlString parameters:(id)params success:(void (^)(NSURLSessionDataTask *task,LSBaseModel *model))success failure:(void (^)(NSURLSessionDataTask *task,NSError *error))failure;

+ (void)BGETWithCache:(NSString *)urlString parameters:(id)params success:(void (^)(NSURLSessionDataTask *task,BOOL fromCache, LSBaseModel *model))success failure:(void (^)(NSURLSessionDataTask *task,NSError *error))failure;

+ (void)BPOST:(NSString *)urlString parameters:(id)params success:(void (^)(NSURLSessionDataTask *task,LSBaseModel *model))success failure:(void (^)(NSURLSessionDataTask *task,NSError *error))failure;

+ (void)BPOSTWithCache:(NSString *)urlString parameters:(id)params success:(void (^)(NSURLSessionDataTask *task,BOOL fromCache, LSBaseModel *model))success failure:(void (^)(NSURLSessionDataTask *task,NSError *error))failure;

+ (void)uploadImages:(NSString *)urlString parameters:(id)params images:(NSArray *)images keys:(NSArray *)keys success:(void (^)(NSURLSessionDataTask *task,LSBaseModel *model))success failure:(void (^)(NSURLSessionDataTask *task,NSError *error))failure;

+ (NSError *)errorFormatBaseModel:(LSBaseModel *)baseModel;

+ (NSString *)errorMessageFromError:(NSError *)error;

+ (void)BPOSTGroup:(NSString *)urlString parameters:(id)params success:(void (^)(NSURLSessionDataTask *task,LSBaseModel *model))success failure:(void (^)(NSURLSessionDataTask *task,NSError *error))failure;

@end
