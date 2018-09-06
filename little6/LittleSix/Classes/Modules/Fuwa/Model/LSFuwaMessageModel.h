//
//  LSFuwaMessageModel.h
//  LittleSix
//
//  Created by Jim huang on 17/3/23.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kCacheFolder @"FuwaMessageCache"
#define kMessageKey [NSString stringWithFormat:@"kFuwaMessageKey_%@",ShareAppManager.loginUser.user_id]

@interface LSFuwaMessageModel : NSObject <NSCoding,NSCopying>

@property(nonatomic,copy)NSString * title;

@property(nonatomic,copy)NSString * url;

@property(nonatomic,copy)NSString * content;
@property(nonatomic,copy)NSString * nick;
@property(nonatomic,copy)NSString * snap;
@property(nonatomic,copy)NSString * type;
@property(nonatomic,copy)NSString * mid;

+ (void)getFuwaMessageListSuccess:(void (^)(NSMutableArray * listArr))success failure:(void (^)(NSError *error))failure;

@end
