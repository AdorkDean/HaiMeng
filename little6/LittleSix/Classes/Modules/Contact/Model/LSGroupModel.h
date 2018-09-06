//
//  LSGroupModel.h
//  LittleSix
//
//  Created by GMAR on 2017/3/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LSMembersModel;
@interface LSGroupModel : NSObject

@property (retain,nonatomic)NSString * groupid;
@property (retain,nonatomic)NSString * creator;
@property (retain,nonatomic)NSString * name;
@property (retain,nonatomic)NSString * notice;
@property (retain,nonatomic)NSString * snap;
@property (retain,nonatomic)NSArray <LSMembersModel *>* members;

+(LSGroupModel *)createLSGroupModel:(NSDictionary *)dic;

//xin群聊列表
+(void)groupWithlistsUser_Id:(NSString *)user_id
                     success:(void (^)(NSArray *array))success
                     failure:(void (^)(NSError *))failure;

//群聊列表
+(void)groupWithlistUser_Id:(NSString *)user_id
                        success:(void (^)(NSArray *array))success
                        failure:(void (^)(NSError *))failure;

//创建群聊
+(void)createGroupWithUser_Id:(NSString *)user_id
                      creator:(NSString *)creator
                         name:(NSString *)name
                    success:(void (^)(LSGroupModel *message))success
                      failure:(void (^)(NSError *))failure;

//修改群资料
+(void)modifyGroupWithGroupid:(NSString *)groupid
                       notice:(NSString *)notice
                         name:(NSString *)name
                      success:(void (^)(NSString *message))success
                      failure:(void (^)(NSError *))failure;

//查询群资料
+(void)queryGroupWithGroupid:(NSString *)groupid
                      success:(void (^)(LSGroupModel * model))success
                      failure:(void (^)(NSError *))failure;

//增加群成员
+(void)increaseMembersWithGroupid:(NSString *)groupid
                          members:(NSString *)members
                     success:(void (^)(NSString * message))success
                     failure:(void (^)(NSError *))failure;

//移除群成员
+(void)removeMembersWithGroupid:(NSString *)groupid
                        members:(NSString *)members
                     success:(void (^)(NSString * message))success
                     failure:(void (^)(NSError *))failure;

@end

@interface LSMembersModel : NSObject

@property (retain,nonatomic)NSString * nickname;
@property (retain,nonatomic)NSString * snap;
@property (retain,nonatomic)NSString * userid;
@property (assign,nonatomic)BOOL is_select;
@property (retain,nonatomic)NSString * first_letter;

+(NSArray *)createLSGroupModel:(NSArray *)list;

@end
