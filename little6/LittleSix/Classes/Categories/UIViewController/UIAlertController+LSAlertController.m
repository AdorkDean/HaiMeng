//
//  UIAlertController+LSAlertController.m
//  LittleSix
//
//  Created by GMAR on 2017/4/12.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "UIAlertController+LSAlertController.h"

@implementation UIAlertController (LSAlertController)

+(UIAlertController *)alertTitle:(NSString *)title mesasge:(NSString *)message withOK:(NSString *)okTitle preferredStyle:(UIAlertControllerStyle)preferredStyle  confirmHandler:(void(^)(UIAlertAction * alertAction,UITextField * textField))confirmHandler cancleHandler:(void(^)(UIAlertAction *))cancleHandler viewController:(UIViewController *)vc
{
    
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:title message:message preferredStyle:preferredStyle];
    static UITextField * textFields;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textFields = textField;
        textField.returnKeyType = UIReturnKeySend ;
    }];
    
    UIAlertAction *confirmAction=[UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        confirmHandler(action,textFields);
    }];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:cancleHandler];
    
    [alertController addAction:confirmAction];
    [alertController addAction:cancleAction];
    
    
    
    [vc presentViewController:alertController animated:YES completion:nil];
    
    return alertController;
    
}


@end
