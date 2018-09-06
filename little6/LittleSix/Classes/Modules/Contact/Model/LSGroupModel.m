//
//  LSGroupModel.m
//  LittleSix
//
//  Created by GMAR on 2017/3/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSGroupModel.h"
#import <YYKit/YYKit.h>
#import "LSBaseModel.h"
#import "LSOBaseModel.h"
#import "ConstKeys.h"

@implementation LSGroupModel

+(LSGroupModel *)createLSGroupModel:(NSDictionary *)dic {

    LSGroupModel * gModel = [LSGroupModel new];
    gModel.groupid = dic[@"groupid"];
    gModel.creator = dic[@"creator"];
    gModel.name = dic[@"name"];
    gModel.notice = dic[@"notice"];
    gModel.snap = dic[@"snap"];
    gModel.members = [LSMembersModel createLSGroupModel:dic[@"members"]];
    
    return gModel;
}

+(void)groupWithlistsUser_Id:(NSString *)user_id
                    success:(void (^)(NSArray *array))success
                     failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@",kOBaseUrl,kGroupPath];
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    dic[@"userid"] = user_id;
    
    [LSOBaseModel BGETWithCache:path parameters:dic success:^(BOOL fromCache, LSOBaseModel *model) {
        
        NSMutableArray * arr = [NSMutableArray array];
        for (NSDictionary * dic in model.data) {
            
            LSGroupModel * gmodel = [LSGroupModel modelWithJSON:dic];
            [arr addObject:gmodel];
        }
        !success?:success(arr);
        
    } failure:^(NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)groupWithlistUser_Id:(NSString *)user_id
                    success:(void (^)(NSArray *array))success
                    failure:(void (^)(NSError *))failure{

    NSString *path = [NSString stringWithFormat:@"%@%@?userid=%@",kOBaseUrl,kGroupPath,user_id];
    
    [LSBaseModel BPOSTGroup:path parameters:nil success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        NSMutableArray * arr = [NSMutableArray array];
        for (NSDictionary * dic in model.data) {
            
            LSGroupModel * gmodel = [LSGroupModel createLSGroupModel:dic];
            [arr addObject:gmodel];
        }
        !success?:success(arr);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];

}

+ (void)createGroupWithUser_Id:(NSString *)user_id
                      creator:(NSString *)creator
                         name:(NSString *)name
                      success:(void (^)(LSGroupModel *message))success
                       failure:(void (^)(NSError *))failure {
    
    //对接口做处理
    NSString * namestr = [name stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSString *path = [NSString stringWithFormat:@"%@%@?creator=%@&members=%@&name=%@",kOBaseUrl,kCreateGroupPath,user_id,creator,namestr];
    
    [LSBaseModel BPOSTGroup:path parameters:nil success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        LSGroupModel * gmodel = [LSGroupModel modelWithJSON:model.data];
        !success?:success(gmodel);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
    
}

+(void)modifyGroupWithGroupid:(NSString *)groupid
                       notice:(NSString *)notice
                         name:(NSString *)name
                      success:(void (^)(NSString *message))success
                      failure:(void (^)(NSError *))failure {

    //对接口做处理
    NSString * nameStr = [name stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString * noticeStr = [notice stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSString *path = [NSString stringWithFormat:@"%@%@?groupid=%@&notice=%@&name=%@",kOBaseUrl,kModifyGroupPath,groupid,noticeStr,nameStr];
    
    [LSBaseModel BPOSTGroup:path parameters:nil success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success(model.message);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)queryGroupWithGroupid:(NSString *)groupid
                     success:(void (^)(LSGroupModel * model))success
                     failure:(void (^)(NSError *))failure {
    
    NSString *path = [NSString stringWithFormat:@"%@%@?groupid=%@",kOBaseUrl,kQueryGroupPath,groupid];
    
    [LSBaseModel BPOSTGroup:path parameters:nil success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
         LSGroupModel * gmodel = [LSGroupModel createLSGroupModel:model.data];
        !success?:success(gmodel);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}
+(void)increaseMembersWithGroupid:(NSString *)groupid
                          members:(NSString *)members
                          success:(void (^)(NSString * message))success
                          failure:(void (^)(NSError *))failure {
    
    NSString *path = [NSString stringWithFormat:@"%@%@?groupid=%@&members=%@",kOBaseUrl,kAddMembersPath,groupid,members];
    
    [LSBaseModel BPOSTGroup:path parameters:nil success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success(model.message);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)removeMembersWithGroupid:(NSString *)groupid
                        members:(NSString *)members
                        success:(void (^)(NSString * message))success
                        failure:(void (^)(NSError *))failure {

    NSString *path = [NSString stringWithFormat:@"%@%@?groupid=%@&members=%@",kOBaseUrl,kDelmembersPath,groupid,members];
    
    [LSBaseModel BPOSTGroup:path parameters:nil success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success(model.message);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

@end

@implementation LSMembersModel

+(NSArray *)createLSGroupModel:(NSArray *)list {

    NSMutableArray * arr = [NSMutableArray array];
    
    for (NSDictionary * dic in list) {
        
        LSMembersModel * mModel = [LSMembersModel new];
        mModel.nickname = dic[@"nickname"];
        mModel.snap = dic[@"snap"];
        mModel.userid = dic[@"userid"];
        
        [arr addObject:mModel];
    }
    
    return arr;
}

@end
