//
//  LSContactModel.h
//  LittleSix
//
//  Created by GMAR on 2017/3/9.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSContactModel : NSObject

@property (retain,nonatomic)NSString * fid;
@property (retain,nonatomic)NSString * avatar;
@property (retain,nonatomic)NSString * user_name;
@property (assign,nonatomic)NSInteger friend_id;
@property (retain,nonatomic)NSString * first_letter;
@property (assign,nonatomic)NSInteger user_id;
@property (assign,nonatomic)NSInteger mobile_phone;
@property (assign,nonatomic)BOOL is_select;
@property (assign,nonatomic)NSInteger is_friend;
@property (retain,nonatomic)NSString * uid_to;

@property (retain,nonatomic)NSString * unicount;

+(void)friendsWithlistToken:(NSString *)access_token
                   success:(void (^)(NSArray *array))success
                   failure:(void (^)(NSError *))failure;



+(void)findFriendsWithlistToken:(NSString *)access_token
                            key:(NSString *)key
                    success:(void (^)(NSArray *array))success
                    failure:(void (^)(NSError *))failure;

+(void)deleteFriendsWithlistToken:(NSString *)access_token
                            fid:(NSString *)fid
                        success:(void (^)())success
                        failure:(void (^)(NSError *))failure;

+(void)sendFriendsWithlistToken:(NSString *)access_token
                         uid_to:(NSString *)uid_to
                    friend_note:(NSString *)friend_note
                          success:(void (^)(LSContactModel* cmodel))success
                          failure:(void (^)(NSError *))failure;



+(void)isFriendsWithlistToken:(NSString *)access_token
                         uid_to:(NSString *)uid_to
                        success:(void (^)(LSContactModel * model))success
                        failure:(void (^)(NSError *))failure;

+(void)dealWithWithlistToken:(NSString *)access_token
                         uid:(NSString *)uid
               feedback_mark:(NSString *)feedback_mark
                      success:(void (^)(LSContactModel * model))success
                      failure:(void (^)(NSError *))failure;


+(void)friendslogCountSuccess:(void (^)(NSString * messageCount))success
                      failure:(void (^)(NSError *))failure;

@end

@interface LSNewFriendstModel : NSObject

@property (retain,nonatomic)NSString * id;
@property (retain,nonatomic)NSString * user_id;
@property (retain,nonatomic)NSString * user_name;
@property (retain,nonatomic)NSString * avatar;
@property (retain,nonatomic)NSString * feedback_mark;
@property (retain,nonatomic)NSString * feedback_time;
@property (retain,nonatomic)NSString * feedback_status;
@property (retain,nonatomic)NSString * add_time;
@property (retain,nonatomic)NSString * friend_note;

+(void)newFriendsWithlistToken:(NSString *)access_token
                       success:(void (^)(NSArray *array))success
                       failure:(void (^)(NSError *))failure;

@end
