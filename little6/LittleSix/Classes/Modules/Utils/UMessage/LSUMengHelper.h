//
//  LSUMengHelper.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/26.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSUMengHelper : NSObject

///发送推送通知，users
+ (void)pushNotificationWithUsers:(NSArray *)users message:(NSString *)message extension:(NSDictionary *)ext success:(void (^)(void))success failure:(void (^)(NSError *))failure;

@end
