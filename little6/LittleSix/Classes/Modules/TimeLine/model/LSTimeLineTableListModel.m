//
//  LSTimeLineTableModel.m
//  LittleSix
//
//  Created by Jim huang on 17/3/4.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSTimeLineTableListModel.h"
#import "LSBaseModel.h"

#define kCacheFolder @"kTLCache"
#define kTLCacheKey [NSString stringWithFormat:@"kTLCacheKey_%@",ShareAppManager.loginUser.user_id]

@implementation LSTimeLineTableListModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"praise_list" : [LSTimeLinePraiseModel class],
             @"comment_list" : [LSTimeLineCommentModel class],
             @"files" : [LSTimeLineImageModel class]};
}


+ (void)getTimeLineListWithPage:(int)page pageSize:(int)pageSize success:(void (^)(NSArray * modelArr))success failure:(void (^)(NSError *error))failure {
    
    
    
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kTimeLineListPath];
    NSString * getPath =[NSString stringWithFormat:@"%@?page=%d&size=%d",path,page,pageSize];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] =ShareAppManager.loginUser.access_token;

    [LSBaseModel BPOST:getPath parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        NSArray * modelArr = [NSArray modelArrayWithClass:[LSTimeLineTableListModel class] json:model.result];
        
        YYCache *messageCache = [[YYCache alloc] initWithName:kCacheFolder];
        NSMutableArray *messages = (NSMutableArray *)[messageCache objectForKey:kTLCacheKey];
        if (!messages) {
            messages = [NSMutableArray array];
        }
        [messages removeAllObjects];
        [messages addObjectsFromArray:modelArr];
        
        !success?:success(messages);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
    
}

+ (void)PriseToTimeLineWithfeed_id:(int)feed_id type:(timeLinePriseType)type success:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kPriseTimeLinePath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] =ShareAppManager.loginUser.access_token;
    
    params[@"feed_id"] = [NSNumber numberWithInt:feed_id];
    params[@"type"] = [NSNumber numberWithInt:type];
    
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        !success?:success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
    
}

+ (void)loadTimeLineDetailWithfeed_id:(int)feed_id success:(void (^)(LSTimeLineTableListModel * model))success failure:(void (^)(NSError *error))failure {
    
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kloadTimeLineDetailPath];
    
    NSString * getPath =[NSString stringWithFormat:@"%@?feed_id=%d",path,feed_id];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] =ShareAppManager.loginUser.access_token;
    
    [LSBaseModel BPOST:getPath parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        LSTimeLineTableListModel * timeLineModel = [LSTimeLineTableListModel modelWithJSON:model.result];
        !success?:success(timeLineModel);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);

    }];
    
}



+ (void)addTimeLineCommentWithfeed_id:(int)feed_id content:(NSString *)content pid:(int)pid uid_to:(int)uid_to success:(void (^)(NSString *string))success failure:(void (^)(NSError *error))failure {
    
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kaddComnentPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] =ShareAppManager.loginUser.access_token;
    params[@"feed_id"] = [NSNumber numberWithInt:feed_id];
    params[@"content"] = content;
    params[@"pid"] =[NSNumber numberWithInt:pid];
    params[@"uid_to"] = [NSNumber numberWithInt:uid_to];
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {

        
        !success?:success(model.result);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
       
        
        !failure?:failure(error);

    }];
    
}

+ (void)searchGalleryWithuserID:(int)userID page:(int)page success:(void (^)(NSArray *modelArr))success failure:(void (^)(NSError *error))failure {
    
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kgalleryListPath];
    NSString * getPath =[NSString stringWithFormat:@"%@?page=%d&size=%d&user_id=%d",path,page,15,userID];

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] =ShareAppManager.loginUser.access_token;
    
    [LSBaseModel BPOST:getPath parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        NSArray * modelArr = [NSArray modelArrayWithClass:[LSTimeLineTableListModel class] json:model.result];
        YYCache *messageCache = [[YYCache alloc] initWithName:kCacheFolder];
        NSMutableArray *messages = (NSMutableArray *)[messageCache objectForKey:kTLCacheKey];
        if (!messages) {
            messages = [NSMutableArray array];
        }
        [messages removeAllObjects];
        [messages addObjectsFromArray:modelArr];

        !success?:success(messages);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
        
        
    }];
    
}


+ (void)deleteTimeLineWithFeed_id:(int)feed_id success:(void (^)(void))success failure:(void (^)(NSError *error))failure {
    
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kdeleteTimeLinePath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString * getPath =[NSString stringWithFormat:@"%@?feed_id=%d",path,feed_id];

    params[@"access_token"] =ShareAppManager.loginUser.access_token;
    
    [LSBaseModel BPOST:getPath parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
    
}

+ (void)deleteTimeLineCommentWithcomm_id:(int)comm_id success:(void (^)(void))success failure:(void (^)(NSError *error))failure{
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kdeleteTimeLineCommentPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"comm_id"] =[NSString stringWithFormat:@"%i",comm_id];
    params[@"access_token"] =ShareAppManager.loginUser.access_token;
    
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
    
}

+(void)changeHeadBGImageWithImage:(UIImage *)image success:(void (^)(NSString * BGimageUrl))success failure:(void (^)(NSError *error))failure {
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kTimeLineChangeBGImagePath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] =ShareAppManager.loginUser.access_token;
    
    UIGraphicsBeginImageContext(CGSizeMake(640.0,640.0));
    [image drawInRect:CGRectMake(0, 0, 640.0, 640.0)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [LSBaseModel uploadImages:path parameters:params images:@[scaledImage] keys:@[@"cover_pic"] success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        NSString * imageUrl = model.result[@"cover_pic"];
        
        !success?:success(imageUrl);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
}

+(void)getFirstMsgSuccess:(void (^)(LSGetNewMsgModel * NewMsgModel))success failure:(void (^)(NSError *error))failure{
    NSString *path = [kBaseUrl stringByAppendingPathComponent:kTimeLineGetNewMsgPath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"access_token"] =ShareAppManager.loginUser.access_token;
    
        
    [LSBaseModel BPOST:path parameters:params success:^(NSURLSessionDataTask *task, LSBaseModel *model) {
        
        LSGetNewMsgModel * NewMsgModel = [LSGetNewMsgModel modelWithJSON:model.result];
        !success?:success(NewMsgModel);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        !failure?:failure(error);
    }];
    
}

@end


@implementation LSTimeLineImageModel

@end

@implementation LSTimeLineCommentModel

@end

@implementation LSTimeLinePraiseModel

@end

@implementation LSGetNewMsgModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"frist_user" : [LSGetNewMsgFirstModel class]};
}
@end

@implementation LSGetNewMsgFirstModel

@end
