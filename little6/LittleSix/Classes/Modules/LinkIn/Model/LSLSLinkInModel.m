//
//  LSLSLinkInModel.m
//  LittleSix
//
//  Created by GMAR on 2017/3/2.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSLSLinkInModel.h"
#import "LSBaseModel.h"
#import "ConstKeys.h"

@implementation LSLSLinkInModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self modelEncodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    return [self modelInitWithCoder:aDecoder];
}

+(void)schoolWithlistToken:(NSString *)access_token success:(void (^)(NSArray *array))success failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@",kBaseUrl,kLinkInListPath];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        NSMutableArray * arr = [NSMutableArray array];
        for (NSDictionary * dic in model.result) {
            LSLSLinkInModel * lmodel = [LSLSLinkInModel new];
            lmodel.us_id = [NSString stringWithFormat:@"%@",dic[@"us_id"]];
            lmodel.user_id = [NSString stringWithFormat:@"%@",dic[@"user_id"]];
            lmodel.school_id = [NSString stringWithFormat:@"%@",dic[@"school_id"]];
            lmodel.school_name = dic[@"school_name"];
            lmodel.level = [NSString stringWithFormat:@"%@",dic[@"level"]];
            lmodel.departments = dic[@"departments"];
            lmodel.note = dic[@"note"];
            lmodel.edu_year = dic[@"edu_year"];
            lmodel.add_time = [NSString stringWithFormat:@"%@",dic[@"add_time"]];
            
            [arr addObject:lmodel];
        }
        !success?:success(arr);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}
+(void)deleteSchoolWithlistToken:(NSString *)access_token
                           us_id:(int)us_id
                         success:(void (^)())success
                         failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@?us_id=%d",kBaseUrl,kLinkIndeletePath,us_id];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] = access_token;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success();
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

@end
