//
//  LSFriendLabelManager.h
//  LittleSix
//
//  Created by Jim huang on 17/3/9.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LSFriendListLabelModel;
@class LSFriendModel;
@interface LSFriendLabelManager : NSObject

+ (void)initialManagerWithId:(NSString *)user_id ;
+(BOOL)DBInsertLabelList:(LSFriendListLabelModel *)listLabel;
+(NSArray *)DBGetAllListLabel;

+(void)DBInsertFriendArr:(NSArray *)FriendArr;
+(BOOL)DBUpdateFriendWithFriendModel:(LSFriendModel *)model;
+(NSArray *)DBGetAllFriendList;
+(NSArray *)DBGetFriendsWithStr:(NSString *)str;

@end
