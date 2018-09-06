//
//  LSLSLinkInModel.h
//  LittleSix
//
//  Created by GMAR on 2017/3/2.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSLSLinkInModel : NSObject<NSCoding>

@property (copy,nonatomic)NSString * us_id;
@property (copy,nonatomic)NSString * user_id;
@property (copy,nonatomic)NSString * school_id;
@property (copy,nonatomic)NSString * school_name;
@property (copy,nonatomic)NSString * level;
@property (copy,nonatomic)NSString * departments;
@property (copy,nonatomic)NSString * note;
@property (copy,nonatomic)NSString * edu_year;
@property (copy,nonatomic)NSString * add_time;

+(void)schoolWithlistToken:(NSString *)access_token
                   success:(void (^)(NSArray *array))success
                   failure:(void (^)(NSError *))failure;

+(void)deleteSchoolWithlistToken:(NSString *)access_token
                           us_id:(int)us_id
                   success:(void (^)())success
                   failure:(void (^)(NSError *))failure;

@end
