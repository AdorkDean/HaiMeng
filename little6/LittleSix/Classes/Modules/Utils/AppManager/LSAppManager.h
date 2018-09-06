//
//  LSAppManager.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSUserModel.h"

#define ShareAppManager [LSAppManager sharedAppManager]


@interface LSAppManager : NSObject

@property (nonatomic,strong) LSUserModel *loginUser;

+ (instancetype)sharedAppManager;

//用户登录时存储用户模型
+ (void)storeUser:(LSUserModel *)user;

//移除用户模型
+ (void)removeUser;

//登录成功的处理-跳转到主界面
+ (void)loginSuccessWithUser:(LSUserModel *)user;

//退出登录
+ (void)logout;

//选择主界面
+ (void)changeRootViewController;

//判断是否是审核状态,当返回YES，将会从加载接口返回值，并发送通知
+ (BOOL)isInReview;

@end
