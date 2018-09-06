//
//  LSLinkInApplyModel.h
//  LittleSix
//
//  Created by GMAR on 2017/4/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSLinkInApplyModel : NSObject

@property (copy,nonatomic)NSString * id;
@property (copy,nonatomic)NSString * name;
@property (copy,nonatomic)NSString * desc;
@property (copy,nonatomic)NSString * logo;


//创建宗亲，商会
+(void)linkInApplyWithName:(NSString *)name
                  province:(NSString *)provinceId
                      city:(NSString *)cityId
                  district:(NSString *)districtId
                      type:(NSString *)type
                   success:(void (^)())success
                   failure:(void (^)(NSError *))failure;

//删除宗亲，商会
+(void)linkInApplyDelectWithC_id:(NSString *)c_id
                            type:(int)type
                         success:(void (^)())success
                         failure:(void (^)(NSError *))failure;

//修改资料
+(void)linkInApplyWithC_id:(NSString *)c_id
                      name:(NSString *)name
                      desc:(NSString *)desc
                   contact:(NSString *)contact
                  province:(NSString *)province
                      city:(NSString *)city
                  district:(NSString *)district
                   address:(NSString *)address
                      type:(int)type
                   success:(void (^)())success
                   failure:(void (^)(NSError *))failure;

+(void)linkInApplyWithC_id:(NSString *)c_id
                      logo:(UIImage *)logo
                    banner:(UIImage *)banner
                      type:(int)type
                   success:(void (^)(NSDictionary *dic))success
                   failure:(void (^)(NSError *))failure;

//添加名人
+(void)linkInCelebrityWithC_id:(NSString *)c_id
                          logo:(UIImage *)photo
                          name:(NSString *)name
                          desc:(NSString *)desc
                          type:(int)type
                       success:(void (^)(NSDictionary *dic))success
                       failure:(void (^)(NSError *))failure;

//编辑名人
+(void)linkInUpdateCelebrityWithC_id:(NSString *)c_id
                                logo:(UIImage *)photo
                                name:(NSString *)name
                                desc:(NSString *)desc
                                type:(int)type
                             success:(void (^)(NSDictionary *dic))success
                             failure:(void (^)(NSError *))failure;

//删除名人
+(void)linkInCelebrityDeleteWithC_id:(NSString *)c_id
                                type:(int)type
                             success:(void (^)())success
                             failure:(void (^)(NSError *))failure;



//关注商会宗亲
+(void)linkInFocusWithC_id:(NSString *)c_id
                      type:(int)type
                   success:(void (^)())success
                   failure:(void (^)(NSError *))failure;
//取消关注商会宗亲
+(void)linkInCancelFocusWithC_id:(NSString *)c_id
                            type:(int)type
                         success:(void (^)())success
                         failure:(void (^)(NSError *))failure;

//是否已关注关注商会宗亲
+(void)linkInIsFocusWithC_id:(NSString *)c_id
                            type:(int)type
                         success:(void (^)(NSString * isfocus))success
                         failure:(void (^)(NSError *))failure;

//宗亲，商会更多的列表
+(void)linkInApplyListWithPage:(int)page
                          type:(NSString *)type
                       success:(void (^)(NSArray * list))success
                       failure:(void (^)(NSError *))failure;

@end

@interface LSLinkInInformationModel : NSObject

@property (copy,nonatomic)NSString * id;
@property (copy,nonatomic)NSString * name;
@property (copy,nonatomic)NSString * desc;
@property (copy,nonatomic)NSString * logo;
@property (copy,nonatomic)NSString * province;
@property (copy,nonatomic)NSString * city;
@property (copy,nonatomic)NSString * district;
@property (copy,nonatomic)NSString * address;
@property (copy,nonatomic)NSString * banner;
@property (copy,nonatomic)NSString * user_id;
@property (copy,nonatomic)NSString * add_time;
@property (copy,nonatomic)NSString * count;
@property (copy,nonatomic)NSString * contact;

+(void)linkInInfoWithC_id:(NSString *)c_id
                      type:(int)type
                   success:(void (^)(LSLinkInInformationModel * model))success
                   failure:(void (^)(NSError *))failure;

@end
