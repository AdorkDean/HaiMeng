//
//  LSPhoneNumListModel.h
//  LittleSix
//
//  Created by Jim huang on 17/3/29.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSPhoneNumListModel : NSObject

@property (nonatomic,copy) NSString * user_id;
@property (nonatomic,copy) NSString * user_name;
@property (nonatomic,copy) NSString * avatar;
@property (nonatomic,copy) NSString * mobile_phone;
@property (nonatomic,copy) NSString * is_friends;

+(void)searchFriendWithPhoneList:(NSString *)phoneList Success:(void (^)(NSArray * modelArr))success failure:(void (^)(NSError *error))failure;

+(void)addFriendWithUserID:(NSString *)UserID Success:(void (^)(void))success failure:(void (^)(NSError *error))failure;
@end
