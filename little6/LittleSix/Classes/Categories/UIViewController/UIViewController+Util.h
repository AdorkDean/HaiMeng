//
//  UIViewController+Util.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/16.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Util)

+ (instancetype)controllerFromStroyboard:(NSString *)storyboard identify:(NSString *)identify;

+ (instancetype)initialControllerFromStroyboard:(NSString *)storyboard;

@end
