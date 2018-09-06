//
//  LSQueryClass.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/6/1.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSQueryClass : NSObject

@property (nonatomic,copy) NSString *classid;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,assign) BOOL selected;

+ (void)queryClassWithSuccess:(void (^)(NSArray* list))success failure:(void (^)(NSError *error))failure;

@end
