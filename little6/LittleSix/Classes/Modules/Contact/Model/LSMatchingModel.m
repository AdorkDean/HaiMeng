//
//  LSMatchingModel.m
//  LittleSix
//
//  Created by GMAR on 2017/3/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSMatchingModel.h"
#import <YYKit/YYKit.h>
#import "LSBaseModel.h"
#import "ConstKeys.h"

@implementation LSMatchingModel

+(void)matchingFriendsWithlistToken:(NSString *)access_token
                             phones:(NSString *)phones
                            success:(void (^)(NSArray *array))success
                            failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,kMatchPhonePath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    params[@"phones"] = phones;
    
    [LSBaseModel BPOSTWithCache:path parameters:params success:^(NSURLSessionDataTask *task, BOOL fromCache, LSBaseModel *model) {
        
        NSMutableArray * arr = [NSMutableArray array];
        
        for (NSDictionary *dic in model.result) {
            
            LSMatchingModel * mchModel = [LSMatchingModel modelWithJSON:dic];
            [arr addObject:mchModel];
        }
        
        !success?:success(arr);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

@end
@implementation LSAddressBook



@end
