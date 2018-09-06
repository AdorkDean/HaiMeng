//
//  LSTimeLineMsgModel.h
//  LittleSix
//
//  Created by Jim huang on 17/3/8.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSTimeLineMsgModel : NSObject

@property (nonatomic,assign) int msg_id;
@property (nonatomic,copy) NSString *msg_content;
@property (nonatomic,assign) int user_id;
@property (nonatomic,copy) NSString *user_name;
@property (nonatomic,copy) NSString *avatar;
@property (nonatomic,assign) int feed_id;
@property (nonatomic,copy) NSString *feed_content;
@property (nonatomic,copy) NSString *feed_file;
@property (nonatomic,copy) NSString *add_time;


+ (void)getMsgListWithPage:(int)page Success:(void (^)(NSArray * modelArr))success failure:(void (^)(NSError *error))failure;

+ (void)deleteAllMsgSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure;

+ (void)deleteMsgWithMessageId:(int)messageId Success:(void (^)(void))success failure:(void (^)(NSError *error))failure;

@end
