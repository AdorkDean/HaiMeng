//
//  AppDelegate.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/11.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMDrawerController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,strong) MMDrawerController *drawerController;
@property (nonatomic,strong) UIView *shadowView;

- (void)showRootViewController;

@end
