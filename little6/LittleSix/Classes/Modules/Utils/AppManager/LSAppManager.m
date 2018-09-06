//
//  LSAppManager.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSAppManager.h"
#import "AppDelegate.h"
#import "UIViewController+Util.h"
#import "LSEmotionManager.h"
#import "LSMessageManager.h"
#import "LSFriendLabelManager.h"
#import "UMessage.h"
#import "LSOBaseModel.h"

#define kInReviewKey @"kInReviewKey"

static LSAppManager *_instance;

@interface LSAppManager ()

@property (nonatomic, copy) NSString *filePath;

@end

@implementation LSAppManager

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)sharedAppManager {
    if (!_instance) {
        _instance = [[LSAppManager alloc] init];
        //从本地获取用户模型
        LSUserModel *user = [NSKeyedUnarchiver unarchiveObjectWithFile:_instance.filePath];
        _instance.loginUser = user;
        if (user) {
            [LSEmotionManager initialManagerWithId:user.user_id];
            [LSMessageManager connect:user.user_id];
            [LSFriendLabelManager initialManagerWithId:user.user_id];
        }
    }
    return _instance;
}

+ (void)storeUser:(LSUserModel *)user {
    [NSKeyedArchiver archiveRootObject:user toFile:ShareAppManager.filePath];
    ShareAppManager.loginUser = user;
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserInfoChangeNoti object:nil];
}

+ (void)removeUser {
    ShareAppManager.loginUser = nil;
    //移除保存到本地的用户信息
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:ShareAppManager.filePath error:nil];
}

+ (void)loginSuccessWithUser:(LSUserModel *)user {
    //聊天WebSocket
    [LSAppManager storeUser:user];
    [LSMessageManager connect:user.user_id];
    [LSAppManager changeRootViewController];
    [LSEmotionManager initialManagerWithId:user.user_id];
    //设置推送别名
    [UMessage setAlias:user.user_id type:kUMessageAliasTypeQQ response:nil];
}

+ (void)changeRootViewController {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate showRootViewController];
}

+ (void)logout {
    //删除推送别名
    [UMessage removeAlias:ShareAppManager.loginUser.user_id type:kUMessageAliasTypeQQ response:nil];
    ShareAppManager.loginUser = nil;
    [LSAppManager removeUser];
    [self changeRootViewController];
}

#pragma mark - Getter & Setter
- (NSString *)filePath {
    
    if (!_filePath) {
        NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *filePath = [docPath stringByAppendingPathComponent:@"UserAccount.data"];
        _filePath = filePath;
    }
    return _filePath;
}

+ (BOOL)isInReview {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //注册默认设置
    NSDictionary *defaultValues = @{kInReviewKey:@(YES)};
    [userDefaults registerDefaults:defaultValues];
    [userDefaults synchronize];
    
    BOOL inRevew = [[NSUserDefaults standardUserDefaults] boolForKey:kInReviewKey];
    
    if (inRevew) {
        NSString *versionString = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
        [LSOBaseModel BGET:kInReviewPath parameters:@{@"version":versionString} success:^(LSOBaseModel *model) {
            
            BOOL inReview = [model.data boolValue];
            
            [[NSUserDefaults standardUserDefaults] setBool:inReview forKey:kInReviewKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //发送通知，更新界面
            if (!inReview) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kInReviewNoti object:nil];
            }
            
        } failure:nil];
    }
    
    return inRevew;
}

@end
