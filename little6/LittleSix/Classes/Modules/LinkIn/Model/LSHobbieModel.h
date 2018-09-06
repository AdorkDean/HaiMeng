//
//  LSHobbieModel.h
//  LittleSix
//
//  Created by GMAR on 2017/3/3.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSHobbieModel : NSObject

@property (copy,nonatomic) NSString * tag_id;
@property (copy,nonatomic) NSString * tag_name;
@property (assign,nonatomic) NSInteger select_id;

+(void)hobbieWithlistToken:(NSString *)access_token
                   success:(void (^)(NSArray *array))success
                   failure:(void (^)(NSError *))failure;




@end

@interface LSWorkModel : NSObject

@property (copy,nonatomic) NSString * w_id;
@property (copy,nonatomic) NSString * w_name;

+(void)workWithlistToken:(NSString *)access_token
                   success:(void (^)(NSArray *array))success
                   failure:(void (^)(NSError *))failure;

@end

@interface LSAddSchoolModel : NSObject

+(void)addSchoolWithlistToken:(NSString *)access_token
                     andLevel:(NSInteger)level
                     edu_year:(NSInteger)edu_year
                    school_id:(NSInteger)school_id
                         note:(NSString *)note
                 success:(void (^)())success
                 failure:(void (^)(NSError *))failure;

+(void)updateSchoolWithlistUser_id:(NSString *)user_id
                          edu_year:(NSInteger)edu_year
                         school_id:(NSInteger)school_id
                              note:(NSString *)note
                           success:(void (^)())success
                           failure:(void (^)(NSError *))failure;

@end

@interface LSSchoolModels : NSObject

@property (nonatomic,copy) NSString *displayName;


+ (instancetype)modelWithDispalyName:(NSString *)name;

@property (nonatomic,copy) NSString * id;
@property (nonatomic,copy) NSString * name;
@property (nonatomic,copy) NSString * level;
@property (nonatomic,copy) NSString * region;

+(void)searchSchoolWithlistToken:(NSString *)access_token
                             key:(NSString *)key
                           level:(int)level
                         success:(void (^)(NSArray *array))success
                         failure:(void (^)(NSError *))failure;

@end

