//
//  LSSearchMatchModel.h
//  LittleSix
//
//  Created by GMAR on 2017/3/15.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LSSchModel;
@interface LSSearchMatchModel : NSObject

@property (retain,nonatomic)NSString * user_id;
@property (retain,nonatomic)NSString * user_name;
@property (retain,nonatomic)NSString * avatar;
@property (retain,nonatomic)NSString * sex;
@property (retain,nonatomic)NSString * birthday;
@property (retain,nonatomic)NSString * province;
@property (retain,nonatomic)NSString * city;
@property (retain,nonatomic)NSString * district;
@property (retain,nonatomic)NSString * industry;
@property (retain,nonatomic)NSString * interest;
@property (retain,nonatomic)NSString * ht_province;
@property (retain,nonatomic)NSString * ht_city;
@property (retain,nonatomic)NSString * ht_district;
@property (retain,nonatomic)NSArray <LSSchModel *> * school;
@property (retain,nonatomic)NSString * similar;

@property (assign,nonatomic)BOOL isSelect;

//自定义人脉宗亲，好友
@property (copy,nonatomic)NSString * isFriend;

@property (copy,nonatomic)NSString * region;
@property (copy,nonatomic)NSString * name;
@property (copy,nonatomic)NSString * level;
@property (copy,nonatomic)NSString * id;
@property (copy,nonatomic)NSString * desc;
@property (copy,nonatomic)NSString * logo;


+(LSSearchMatchModel *)createLSSearchMatchModel:(NSDictionary *)dic;

+(void)classmatesWithlistToken:(NSString *)access_token
                          home:(int)home
                          page:(int)page
                          size:(int)size
                       success:(void (^)(NSArray *array))success
                       failure:(void (^)(NSError *))failure;


+(void)searchWithlistToken:(NSString *)access_token
                          home:(int)home
                          page:(int)page
                          size:(int)size
                           key:(NSString *)key
                       success:(void (^)(NSArray *array))success
                       failure:(void (^)(NSError *))failure;

//搜索人脉宗亲，好友
+(void)searchsWithlistToken:(NSString *)access_token
                       home:(int)home
                        key:(NSString *)key
                    success:(void (^)(NSArray *clanArray,NSArray *homeArray,NSArray *userArray,NSArray *schArray))success
                    failure:(void (^)(NSError *))failure;

@end

@interface LSSchModel : NSObject

@property (retain,nonatomic)NSString * name;
@property (retain,nonatomic)NSString * user_id;
@property (retain,nonatomic)NSString * school_id;
@property (retain,nonatomic)NSString * level;
@property (retain,nonatomic)NSString * departments;
@property (retain,nonatomic)NSString * edu_year;

+(NSArray *)createLSSchModel:(NSArray *)list;

@end
