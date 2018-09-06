//
//  UIViewController+Util.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/16.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "UIViewController+Util.h"

@implementation UIViewController (Util)

+ (instancetype)controllerFromStroyboard:(NSString *)storyboard identify:(NSString *)identify {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:storyboard bundle:nil];
    
    return [sb instantiateViewControllerWithIdentifier:identify];
}

+ (instancetype)initialControllerFromStroyboard:(NSString *)storyboard {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:storyboard bundle:nil];

    return [sb instantiateInitialViewController];
}

@end
