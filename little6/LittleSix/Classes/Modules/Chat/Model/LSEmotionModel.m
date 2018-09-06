//
//  LSEmotionModel.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSEmotionModel.h"
#import "NSString+Util.h"
#import "LSBaseModel.h"

@implementation LSEmotionCatory

+ (void)load {
    [self initialize];
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"group" : [LSEmotionPackage class]};
}

@end

@implementation LSEmotionPackage

- (NSString *)iconPath {
    
    NSString *filepath = [NSString stringWithFormat:@"%@/%@/%@",self.cate_id,self.group_id,self.group_icon];
    
    return [kEmotionFolder stringByAppendingPathComponent:filepath];
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"emo" : [LSEmotionModel class],@"emos" : [LSEmotionModel class]};
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"emo" : @[@"emos",@"emo"]};
}

+ (void)packageInfo:(NSString *)packageId success:(void (^)(LSEmotionPackage *))success failure:(void (^)(NSError *))failure {
    
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kViewPackagePath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"packid"] = packageId;
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        LSEmotionPackage *package = [LSEmotionPackage modelWithJSON:model.result];
        !success ? : success(package);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure ? : failure(error);
    }];
}

@end

@implementation LSEmotionModel

- (NSString *)filePath {
    
    NSString *fileName = [NSString stringWithFormat:@"%@.%@",self.emo_code,self.emo_format];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@/%@",self.emo_cate_id,self.emo_group_id,fileName];

    return [kEmotionFolder stringByAppendingPathComponent:filePath];
}

@end

@implementation LSEmotionShopModel

+ (void)emotionStoreInfo:(NSInteger)page size:(NSInteger)size success:(void (^)(LSEmotionShopModel *))success failure:(void (^)(NSError *))failure {
    
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kEmoStorePath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    params[@"page"] = @(page);
    params[@"size"] = @(size);
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        LSEmotionShopModel *emoShop = [LSEmotionShopModel modelWithDictionary:model.result];
        !success?:success(emoShop);

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"hot" : [LSHotEmotionModel class], @"groups" : [LSEmotionPackage class]};
}

@end

@implementation LSHotEmotionModel


@end

@implementation LSPackageSearchModel

- (void)setSdesc:(NSString *)sdesc {
    sdesc = [sdesc stringByReplacingOccurrencesOfString:@"<em>" withString:@""];
    sdesc = [sdesc stringByReplacingOccurrencesOfString:@"</em>" withString:@""];
    _sdesc = sdesc;
}

- (void)setSname:(NSString *)sname {
    sname = [sname stringByReplacingOccurrencesOfString:@"<em>" withString:@""];
    sname = [sname stringByReplacingOccurrencesOfString:@"</em>" withString:@""];
    _sname = sname;
}

+ (void)searchWithKeyword:(NSString *)keyword success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kPackageSearchPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = ShareAppManager.loginUser.access_token;
    params[@"key"] = keyword;
    params[@"page"] = @(0);
    params[@"size"] = @(1000);
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        NSArray *list = [NSArray modelArrayWithClass:[LSPackageSearchModel class] json:model.result];
        
        !success ? : success(list);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure ? : failure(error);
    }];
    
}

@end
