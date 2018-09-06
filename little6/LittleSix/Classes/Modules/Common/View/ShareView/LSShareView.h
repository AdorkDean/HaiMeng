//
//  LSShareView.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/19.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "WXApi.h"
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <ShareSDKExtension/ShareSDK+Extension.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <UIKit/UIKit.h>

#define kAnimationDuration 0.25

@class LSShareItem;
@interface LSShareView : UIView

@property (nonatomic, strong) NSArray<LSShareItem *> *items;
@property (nonatomic, copy) void (^actionBlock)(SSDKPlatformType type);

+ (instancetype)showInView:(UIView *)view
                 withItems:(NSArray<LSShareItem *> *)items
               actionBlock:(void (^)(SSDKPlatformType type))block;

- (void)showAnimation;
- (void)dismissAnimation;

+ (NSArray<LSShareItem *> *)shareItems;

///判断是否安装QQ
+ (BOOL)isInstallQQPlatform;
+ (BOOL)isInstallWechatPlatform;

//分享内容
+ (void)shareTo:(SSDKPlatformType)platformType
        withParams:(NSMutableDictionary *)params
    onStateChanged:(SSDKShareStateChangedHandler)stateChangedHandler;

@end

@interface LSShareItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, assign) SSDKPlatformType type;

+ (instancetype)shareItemWith:(NSString *)title iconName:(NSString *)iconName platformType:(SSDKPlatformType)type;

@end
