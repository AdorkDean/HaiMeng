//
//  LSQueryClass.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/6/1.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSQueryClass.h"
#import "LSOBaseModel.h"

@implementation LSQueryClass

+ (void)queryClassWithSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    
    NSString *path = [kBaseFuwa2URL stringByAppendingPathComponent:kFuwaQureyClass];
    
    [LSOBaseModel BGET:path parameters:nil success:^(LSOBaseModel *model) {
        if (success) {
            NSArray *list = [NSArray modelArrayWithClass:[LSQueryClass class] json:model.data];
            success(list);
        }
    } failure:^(NSError *error) {
        !failure?:failure(error);
    }];
}

@end
