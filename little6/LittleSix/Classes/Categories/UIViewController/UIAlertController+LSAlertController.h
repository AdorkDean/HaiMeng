//
//  UIAlertController+LSAlertController.h
//  LittleSix
//
//  Created by GMAR on 2017/4/12.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (LSAlertController)

+(UIAlertController *)alertTitle:(NSString *)title mesasge:(NSString *)message withOK:(NSString *)okTitle preferredStyle:(UIAlertControllerStyle)preferredStyle  confirmHandler:(void(^)(UIAlertAction * alertAction,UITextField * textField))confirmHandler cancleHandler:(void(^)(UIAlertAction *))cancleHandler viewController:(UIViewController *)vc;

@end
