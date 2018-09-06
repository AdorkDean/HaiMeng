//
//  LSPersonsModel.h
//  LittleSix
//
//  Created by GMAR on 2017/3/16.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSPersonsModel : NSObject

@property (retain,nonatomic)NSString * user_id;
@property (retain,nonatomic)NSString * user_name;
@property (retain,nonatomic)NSString * avatar;
@property (retain,nonatomic)NSString * mobile_phone;
@property (retain,nonatomic)NSString * sex;
@property (retain,nonatomic)NSString * signature;
@property (retain,nonatomic)NSString * cover_pic;
@property (retain,nonatomic)NSString * province;
@property (retain,nonatomic)NSString * city;
@property (retain,nonatomic)NSString * district;
@property (retain,nonatomic)NSString * district_str;
@property (retain,nonatomic)NSString * ht_province;
@property (retain,nonatomic)NSString * ht_city;
@property (retain,nonatomic)NSString * ht_district;
@property (retain,nonatomic)NSString * ht_district_str;
@property (retain,nonatomic)NSString * industry;
@property (retain,nonatomic)NSString * interest;
@property (retain,nonatomic)NSString * school;
@property (retain,nonatomic)NSString * birthday;
@property (retain,nonatomic)NSArray * photos;
@property (retain,nonatomic)NSString * distance;

+(void)personerWithUser_id:(NSString *)u_id
                     success:(void (^)(LSPersonsModel * model))success
                     failure:(void (^)(NSError *))failure;

// 附近的人
+(void)peopleNearbyWithSex:(NSString *)sex
                   success:(void (^)(NSArray * list))success
                   failure:(void (^)(NSError *))failure;
//更新位置
+(void)positioningLongitude:(NSString *)longitude
                   latitude:(NSString *)latitude
                    success:(void (^)())success
                    failure:(void (^)(NSError *))failure;

@end
