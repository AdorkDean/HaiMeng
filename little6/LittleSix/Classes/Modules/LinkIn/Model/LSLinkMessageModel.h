//
//  LSLinkMessageModel.h
//  LittleSix
//
//  Created by GMAR on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSLinkMessageModel : NSObject

@property (assign,nonatomic)int msg_id;
@property (retain,nonatomic)NSString * msg_content;
@property (assign,nonatomic)int user_id;
@property (retain,nonatomic)NSString * user_name;
@property (retain,nonatomic)NSString * avatar;
@property (assign,nonatomic)int feed_id;
@property (retain,nonatomic)NSString * feed_file;
@property (retain,nonatomic)NSString * add_time;


+(void)messageLinkWithlistToken:(NSString *)access_token
                           page:(int)page
                           size:(int)size
                      success:(void (^)(NSArray *array))success
                      failure:(void (^)(NSError *))failure;

+(void)cleanListMessageLinkWithlistToken:(NSString *)access_token
                        success:(void (^)())success
                        failure:(void (^)(NSError *))failure;

+(void)deleteOneMessageLinkWithlistToken:(NSString *)access_token
                                  msg_id:(int)msg_id
                                 success:(void (^)())success
                                 failure:(void (^)(NSError *))failure;

@end
