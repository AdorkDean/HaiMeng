//
//  LSPostNewsModel.h
//  LittleSix
//
//  Created by GMAR on 2017/3/7.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LSCaptureModel;
@interface LSPostNewsModel : NSObject

@property (retain,nonatomic)NSString * id;
@property (retain,nonatomic)NSString *region_id;
@property (retain,nonatomic)NSString *name;
@property (retain,nonatomic)NSString *banner;
@property (retain,nonatomic)NSString *count;
@property (retain,nonatomic)NSString *level;
@property (retain,nonatomic)NSString *short_desc;
@property (retain,nonatomic)NSString *logo;

//封面请求
+(void)schoolWithHomeAndId:(NSString *)s_h_id
                      type:(int)type
                   success:(void (^)(LSPostNewsModel * model))success
                   failure:(void (^)(NSError *))failure;

+ (void)postVideoLinkInWithFiles:(LSCaptureModel *)videoModel
                         content:(NSString *)content
                        id_value:(int)id_value
                    id_value_ext:(int)id_value_ext
                       feed_type:(int)feed_type
                         success:(void (^)(void))success
                         failure:(void (^)(NSError *error))failure;

+(void)postNewsLinkWithlistToken:(NSString *)access_token
                           files:(NSArray *)files
                         content:(NSString *)content
                        id_value:(int)id_value
                    id_value_ext:(int)id_value_ext
                       feed_type:(int)feed_type
                        success:(void (^)())success
                        failure:(void (^)(NSError *))failure;

+(void)commentsLinkWithlistToken:(NSString *)access_token
                        feed_id:(int)feed_id
                         uid_to:(int)uid_to
                        content:(NSString *)content
                            pid:(int)pid
                         success:(void (^)())success
                         failure:(void (^)(NSError *))failure;

+(void)praiseLinkWithlistToken:(NSString *)access_token
                         feed_id:(int)feed_id
                          type:(int)type
                         success:(void (^)())success
                         failure:(void (^)(NSError *))failure;

+(void)delectLinkWithlistToken:(NSString *)access_token
                       feed_id:(int)feed_id
                       success:(void (^)())success
                       failure:(void (^)(NSError *))failure;

+(void)delectCommentsWithlistToken:(NSString *)access_token
                       comm_id:(int)comm_id
                       success:(void (^)())success
                       failure:(void (^)(NSError *))failure;


@end

@interface LSFriendsProfileModel : NSObject

@property (nonatomic, copy) NSString * access_token;
@property (nonatomic, copy) NSString * avatar;
@property (nonatomic, assign) NSInteger city;
@property (nonatomic, assign) NSInteger district;
@property (nonatomic, copy) NSString * district_str;
@property (nonatomic, copy) NSString * lastlogin_time;
@property (nonatomic, copy) NSString * mobile_phone;
@property (nonatomic, assign) NSInteger province;
@property (nonatomic, copy) NSString * sex;
@property (nonatomic, copy) NSString * signature;
@property (nonatomic, copy) NSString * user_id;
@property (nonatomic, copy) NSString * user_name;
@property (nonatomic, copy) NSString * school;

+(void)getFriendsProfileToken:(NSString *)access_token
                      user_id:(NSString *)user_id
                      success:(void (^)(LSFriendsProfileModel *))success
                      failure:(void (^)(NSError *))failure;

@end
