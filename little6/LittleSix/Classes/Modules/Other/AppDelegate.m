//
//  AppDelegate.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/11.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "AppDelegate.h"
#import "HttpManager.h"
#import "UIViewController+Util.h"
// ShareSDK
#import "WXApi.h"
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <ShareSDKExtension/ShareSDK+Extension.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

#import "LSMessageManager.h"

//高德地图
#import <AMapFoundationKit/AMapFoundationKit.h>

//bugly崩溃统计
#import <Bugly/Bugly.h>
//友盟推送
#import "UMessage.h"
#import <UserNotifications/UserNotifications.h>
//友盟统计
#import <UMMobClick/MobClick.h>

#import <AlipaySDK/AlipaySDK.h>

#import "LSMenusViewController.h"

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    
    //状态栏高亮
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    [self showRootViewController];

    //开启网络状态变化监听
    [ShareHttpManager startNotifierReachability];

    //注册第三方组件
    [self registVenders:launchOptions];
    [Bugly startWithAppId:@"bd6a2db96e"];
    [Bugly setUserIdentifier:[NSString stringWithFormat:@"%@ %@",ShareAppManager.loginUser.user_id,ShareAppManager.loginUser.user_name]];
    
    return YES;
}

- (void)showRootViewController {

    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    if (ShareAppManager.loginUser) {
        window.rootViewController = self.drawerController;
    } else {
        UIViewController *loginVC = [NSClassFromString(@"LSLoginViewController") new];
        UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:loginVC];
        window.rootViewController = naviVC;
        //释放对象
        self.drawerController = nil;
    }

    self.window = window;
    [self.window makeKeyAndVisible];
}

- (void)registVenders:(NSDictionary *)launchOptions {
    NSArray *platforms = @[ @(SSDKPlatformTypeWechat), @(SSDKPlatformTypeQQ) ];
    [ShareSDK registerApp:@"1b69be7709de8"
        activePlatforms:platforms
        onImport:^(SSDKPlatformType platformType) {
            switch (platformType) {
                case SSDKPlatformTypeWechat:
                    [ShareSDKConnector connectWeChat:[WXApi class]];
                    break;
                case SSDKPlatformTypeQQ:
                    [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                    break;
                default:
                    break;
            }
        }
        onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
            switch (platformType) {
                case SSDKPlatformTypeWechat:
                    [appInfo SSDKSetupWeChatByAppId:@"wx27d18779177daad5"
                                          appSecret:@"c91c8699c372b340cf4c892c4a4e7368"];
                    break;
                case SSDKPlatformTypeQQ:
                    [appInfo SSDKSetupQQByAppId:@"1105992206" appKey:@"Tvbnguewl6Em2QL8" authType:SSDKAuthTypeBoth];
                    break;
                default:
                    break;
            }
        }];
    
    //高德地图
    [AMapServices sharedServices].apiKey = @"fc63102dca4596b4696f76f27a1ee684";
    [[AMapServices sharedServices] setEnableHTTPS:YES];
    
    //友盟推送
    [UMessage startWithAppkey:@"58d62a2f677baa6534000f2f" launchOptions:launchOptions httpsEnable:YES];
    
    [UMessage registerForRemoteNotifications];
    [UMessage setLogEnabled:YES];
    [UMessage setAutoAlert:NO];

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    UNAuthorizationOptions options = UNAuthorizationOptionBadge|  UNAuthorizationOptionAlert|UNAuthorizationOptionSound;
    [center requestAuthorizationWithOptions:options     completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            //点击允许
            //这里可以添加一些自己的逻辑

        } else {
            //点击不允许
            //这里可以添加一些自己的逻辑
        }
    }];
    
    //友盟统计
    UMConfigInstance.appKey = @"58d62a2f677baa6534000f2f";
    UMConfigInstance.channelId = @"App Store";
    [MobClick startWithConfigure:UMConfigInstance];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [UMessage didReceiveRemoteNotification:userInfo];
    [self loadDetailUserInfo:userInfo];
}

//iOS 10前台接收通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于前台时的远程推送接受
        [UMessage didReceiveRemoteNotification:userInfo];
        [self sendPushNotification];
    }
    else {
        //应用处于前台时的本地推送接受
    }
    
    //当应用处于前台时提示设置，需要哪个可以设置哪一个
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}

//iOS 10后台接收通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接受
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        [self loadDetailUserInfo:userInfo];
    }
    else {
        //应用处于后台时的本地推送接受
    }
}

//发送通知刷新
- (void)sendPushNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kContactInfoNoti object:nil];
}

- (void)sendAddContactPushNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddContactInfoNoti object:nil];
}

- (void) loadDetailUserInfo:(NSDictionary *)userInfo {
    
    MMDrawerController *drawerVC = (MMDrawerController*)self.window.rootViewController;
    
    LSMenusViewController *menusVC = (LSMenusViewController *)drawerVC.leftDrawerViewController;
    
    [self sendPushNotification];
    
    NSDictionary * dic= userInfo[@"ext"];
    
    if (dic) {
        if ([dic[@"contactTpye"] isEqualToString:kAddContactPath]) {
            
            LSMenusItem *contactItem = menusVC.items[1];
            if (![contactItem.title isEqualToString:@"通讯录"]) {
                contactItem = menusVC.items[2];
            }
            menusVC.selectItem = contactItem;
            [menusVC showCenterViewController:contactItem complete:^{
                UIViewController *newVC = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"LSNewFriends"];
                MMDrawerController *drawerController = (MMDrawerController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                UINavigationController *naviVC = (UINavigationController *)drawerController.centerViewController;

                [naviVC pushViewController:newVC animated:YES];
            }];

        }else if ([dic[@"contactTpye"] isEqualToString:kAcceptPath]){
            
            LSMenusItem *contactItem = menusVC.items[1];
            if (![contactItem.title isEqualToString:@"通讯录"]) {
                contactItem = menusVC.items[2];
            }
            menusVC.selectItem = contactItem;
            [menusVC showCenterViewController:contactItem complete:nil];
            
        }//跳转到消息
        else {
            LSMenusItem *messageItem = menusVC.items.firstObject;
            if (![messageItem.title isEqualToString:@"消息"]) {
                messageItem = menusVC.items[1];
            }
            menusVC.selectItem = messageItem;
            [menusVC showCenterViewController:messageItem complete:nil];
        }
    }
    else {
        LSMenusItem *messageItem = menusVC.items.firstObject;
        if (![messageItem.title isEqualToString:@"消息"]) {
            messageItem = menusVC.items[1];
        }
        menusVC.selectItem = messageItem;
        [menusVC showCenterViewController:messageItem complete:nil];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

    if (!ShareAppManager.loginUser) return;

    //点击后台APP 进入前台请求一次没有没新好友数
    [self sendAddContactPushNotification];
    //重新连接到聊天服务器
    [LSMessageManager connect:ShareAppManager.loginUser.user_id];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
        }];
    }
    
    return YES;
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSInteger statusCode = [resultDic[@"resultStatus"] integerValue];
            if (statusCode == 9000) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kPaySuccessNoti object:nil];
            }
        }];
    }
    return YES;
}

//接收到内存警告
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    YYImageCache *cache = [YYWebImageManager sharedManager].cache;
    [cache.memoryCache removeAllObjects];
}

#pragma mark - Getter & Setter 
- (MMDrawerController *)drawerController {
    if (!_drawerController) {
        
        LSMenusViewController *menuVC = [LSMenusViewController new];
        menuVC.view.backgroundColor = [UIColor whiteColor];
        
        LSMenusItem *firstItme = menuVC.items.firstObject;
        
        UIViewController *centerVC;
        if (firstItme.storyboard) {
            UIViewController *vc = [[UIStoryboard storyboardWithName:firstItme.storyboard bundle:nil] instantiateInitialViewController];
            centerVC = vc;
        }
        else {
            UIViewController *rootVC = [firstItme.cls new];
            UINavigationController *centerNaviVC = [[UINavigationController alloc] initWithRootViewController:rootVC];
            centerVC = centerNaviVC;
        }
        
        MMDrawerController *drawerController = [[MMDrawerController alloc] initWithCenterViewController:centerVC leftDrawerViewController:menuVC];
        drawerController.view.backgroundColor = [UIColor whiteColor];
        _drawerController = drawerController;
        
        [drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
        [drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
        
        drawerController.maximumLeftDrawerWidth = 240;
        
        //阴影view
        UIView *shadowView = [UIView new];
        shadowView.userInteractionEnabled = NO;
        shadowView.alpha = 0;
        shadowView.backgroundColor = [UIColor blackColor];
        self.shadowView = shadowView;
        
        [centerVC.view addSubview:shadowView];
        [shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(centerVC.view);
        }];
        
        [drawerController setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
            shadowView.alpha = 0.5 * percentVisible;
        }];
    }
    return _drawerController;
}

@end
