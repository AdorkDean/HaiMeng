//
//  LSMatchingModel.h
//  LittleSix
//
//  Created by GMAR on 2017/3/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSMatchingModel : NSObject

@property (assign,nonatomic)int user_id;
@property (retain,nonatomic)NSString * user_name;
@property (retain,nonatomic)NSString * avatar;
@property (retain,nonatomic)NSString * mobile_phone;
@property (assign,nonatomic)int is_friends;
@property (retain,nonatomic)NSString * real_name;

+(void)matchingFriendsWithlistToken:(NSString *)access_token
                             phones:(NSString *)phones
                    success:(void (^)(NSArray *array))success
                    failure:(void (^)(NSError *))failure;

@end
@interface LSAddressBook : NSObject

@property (retain,nonatomic)NSString * name;
@property (retain,nonatomic)NSString * phone;

@end
