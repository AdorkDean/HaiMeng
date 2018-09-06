//
//  LSUMengHelper.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/26.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSUMengHelper.h"
#import "LSOBaseModel.h"

@implementation LSUMengHelper

+ (void)pushNotificationWithUsers:(NSArray *)users message:(NSString *)message extension:(NSDictionary *)ext success:(void (^)(void))success failure:(void (^)(NSError *))failure {
    
    NSString *path = @"http://live.66boss.com/umeng/send";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *usersStr = [users componentsJoinedByString:@","];
    params[@"users"] = usersStr;
    params[@"msgtype"] = @"chat";
    params[@"message"] = message;
    params[@"ext"] = [self dictionaryToJson:ext];
    
    [LSOBaseModel BGETWithCache:path parameters:params success:^(BOOL fromCache, LSOBaseModel *model) {
        !success?:success();
    } failure:^(NSError *error) {
        !failure?:failure(error);
    }];
}

+ (NSString *)dictionaryToJson:(NSDictionary *)dic {
    
    if (!dic) return nil;
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}

@end
