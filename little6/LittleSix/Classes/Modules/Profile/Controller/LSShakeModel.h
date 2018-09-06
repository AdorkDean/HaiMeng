//
//  LSShakeModel.h
//  LittleSix
//
//  Created by Jim huang on 17/3/18.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSShakeModel : NSObject
@property (nonatomic,copy) NSString * user_id;
@property (nonatomic,copy) NSString * user_name;
@property (nonatomic,copy) NSString * avatar;
@property (nonatomic,copy) NSString * distance;
@property (nonatomic,copy) NSString * sex;

+(void)shakeFriendSuccess:(void (^)(LSShakeModel * model))success failure:(void (^)(NSError *error))failure;

@end
