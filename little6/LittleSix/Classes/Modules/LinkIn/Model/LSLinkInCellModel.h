//
//  LSLinkInCellModel.h
//  LittleSix
//
//  Created by GMAR on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LSLinkInCellLikeItemModel,LSLinkInCellCommentItemModel,LSLinkInFileModel;
@interface LSLinkInCellModel : NSObject

@property (nonatomic, assign)int feed_id;
@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *user_name;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, assign)int feed_type;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *share_url;
@property (nonatomic, assign)int comment_count;
@property (nonatomic, assign)int praise_count;
@property (nonatomic, copy) NSString *add_time;
@property (nonatomic, strong) NSArray<LSLinkInFileModel *> *files;
@property (nonatomic, strong) NSMutableArray<LSLinkInCellCommentItemModel *> *comment_list;
@property (nonatomic, strong) NSArray<LSLinkInCellLikeItemModel *> *praise_list;
@property (nonatomic, assign)int is_praise;
@property (nonatomic, copy)NSString * count;
@property (nonatomic, copy)NSDictionary * frist_user;
////////
@property (nonatomic, assign) BOOL isOpening;
@property (nonatomic, assign, readonly) BOOL shouldShowMoreButton;


+(void)linkInWithlistToken:(NSString *)access_token
                       id_value:(int)id_value
                   id_value_ext:(int)id_value_ext
                           page:(int)page
                           size:(int)size
                        success:(void (^)(NSArray *array))success
                        failure:(void (^)(NSError *))failure;

+(void)linkInCenterWithlistToken:(NSString *)access_token
                  user_id:(NSString *)user_id
                     page:(int)page
                     size:(int)size
                   success:(void (^)(NSArray *array))success
                   failure:(void (^)(NSError *))failure;

+(void)linkInMessageDetails:(NSString *)feed_id
                    success:(void (^)(LSLinkInCellModel *model))success
                    failure:(void (^)(NSError *))failure;

+(void)linkInMessageCountSuccess:(void (^)(LSLinkInCellModel *model))success failure:(void (^)(NSError *))failure;

@end

@interface LSLinkInCellLikeItemModel : NSObject

@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *user_name;

@end

@interface LSLinkInCellCommentItemModel : NSObject

@property (nonatomic, assign) int comm_id;
@property (nonatomic, assign) int feed_id;
@property (nonatomic, copy) NSString * content;
@property (nonatomic, assign) int uid_from;
@property (nonatomic, copy) NSString * uid_from_name;
@property (nonatomic, assign) int uid_to;
@property (nonatomic, copy) NSString * uid_to_name;
@property (nonatomic, assign) int pid;

@end

@interface LSLinkInFileModel : NSObject

@property (nonatomic, copy) NSString * file_url;
@property (nonatomic, copy) NSString * file_thumb;

@end
