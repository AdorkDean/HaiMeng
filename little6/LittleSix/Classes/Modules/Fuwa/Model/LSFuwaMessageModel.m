//
//  LSFuwaMessageModel.m
//  LittleSix
//
//  Created by Jim huang on 17/3/23.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaMessageModel.h"
#import "LSOBaseModel.h"

@implementation LSFuwaMessageModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"mid" : @"id"};
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self modelEncodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    return [self modelInitWithCoder:aDecoder];
}

- (id)copyWithZone:(NSZone *)zone {
    return [self modelCopy];
}

+(void)getFuwaMessageListSuccess:(void (^)(NSMutableArray * listArr))success failure:(void (^)(NSError *error))failure{

    NSString * path = [kBaseFuwa2URL stringByAppendingPathComponent:kFuwaMyMessagePath];
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[@"userid"] = ShareAppManager.loginUser.user_id;

    [LSOBaseModel BGET:path parameters:params success:^(LSOBaseModel *model) {
        
        NSArray *list = [NSArray modelArrayWithClass:[LSFuwaMessageModel class] json:model.data];
 
        YYCache *messageCache = [[YYCache alloc] initWithName:kCacheFolder];
        NSMutableArray *messages = (NSMutableArray *)[messageCache objectForKey:kMessageKey];
        if (!messages) {
            messages = [NSMutableArray array];
        }
        //将最新获取的消息插到最前
        [messages insertObjects:list atIndex:0];
        [messageCache setObject:messages forKey:kMessageKey];
        
        success(messages);
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

@end
