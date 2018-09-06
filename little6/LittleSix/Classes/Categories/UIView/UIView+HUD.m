//
//  UIView+HUD.m
//  TipDemo
//
//  Created by ZhiHua Shen on 2017/1/14.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "UIView+HUD.h"
#import <objc/runtime.h>

static char *kTipView = "LFUITips";

@implementation UIView (HUD)

- (void)showWithText:(NSString *)text {
    [self.tipView showWithText:text];
}
- (void)showWithText:(NSString *)text hideAfterDelay:(NSTimeInterval)delay {
    [self.tipView showWithText:text hideAfterDelay:delay];
}
- (void)showWithText:(NSString *)text detailText:(NSString *)detailText {
    [self.tipView showWithText:text detailText:detailText];
}
- (void)showWithText:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay {
    [self.tipView showWithText:text detailText:detailText hideAfterDelay:delay];
}

- (void)showLoading {
    [self.tipView showLoading];
}
- (void)showLoading:(NSString *)text {
    [self.tipView showLoading:text];
}
- (void)showLoadingHideAfterDelay:(NSTimeInterval)delay {
    [self.tipView showLoadingHideAfterDelay:delay];
}
- (void)showLoading:(NSString *)text hideAfterDelay:(NSTimeInterval)delay {
    [self.tipView showLoading:text hideAfterDelay:delay];
}
- (void)showLoading:(NSString *)text detailText:(NSString *)detailText {
    [self.tipView showLoading:text detailText:detailText];
}
- (void)showLoading:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay {
    [self.tipView showLoading:text detailText:detailText hideAfterDelay:delay];
}

- (void)showSucceed:(NSString *)text {
    [self.tipView showSucceed:text];
}
- (void)showSucceed:(NSString *)text hideAfterDelay:(NSTimeInterval)delay {
    [self.tipView showSucceed:text hideAfterDelay:delay];
}
- (void)showSucceed:(NSString *)text detailText:(NSString *)detailText {
    [self.tipView showSucceed:text detailText:detailText];
}
- (void)showSucceed:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay {
    [self.tipView showSucceed:text detailText:detailText hideAfterDelay:delay];
}

- (void)showError:(NSString *)text {
    [self.tipView showError:text];
}
- (void)showError:(NSString *)text hideAfterDelay:(NSTimeInterval)delay {
    [self.tipView showError:text hideAfterDelay:delay];
}
- (void)showError:(NSString *)text detailText:(NSString *)detailText {
    [self.tipView showError:text detailText:detailText];
}
- (void)showError:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay {
    [self.tipView showError:text detailText:detailText hideAfterDelay:delay];
}

- (void)showErrorWithError:(NSError *)error {
    
    [self hideHUDAnimated:YES];
    
    if (!error) return;
    
    //已经有提示
    id userInfo = [error userInfo];
    NSString *errorMsg;
    
    if ([userInfo objectForKey:NSLocalizedFailureReasonErrorKey]) {
        errorMsg = [userInfo objectForKey:NSLocalizedFailureReasonErrorKey];
    } else if ([userInfo objectForKey:NSLocalizedRecoverySuggestionErrorKey]) {
        errorMsg = [userInfo objectForKey:NSLocalizedRecoverySuggestionErrorKey];
    } else {
        errorMsg = [error localizedDescription];
    }
    
    if (errorMsg) {
        if ([errorMsg isKindOfClass:[NSString class]]) {
            errorMsg = [errorMsg stringByReplacingOccurrencesOfString:@"Error:" withString:@""];
            [self showAlertWithTitle:@"提示" message:errorMsg cancelAction:nil doneAction:nil];
        }
    }
}

- (void)showInfo:(NSString *)text {
    [self.tipView showInfo:text];
}
- (void)showInfo:(NSString *)text hideAfterDelay:(NSTimeInterval)delay {
    [self.tipView showInfo:text hideAfterDelay:delay];
}
- (void)showInfo:(NSString *)text detailText:(NSString *)detailText {
    [self.tipView showInfo:text detailText:detailText];
}
- (void)showInfo:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay {
    [self.tipView showInfo:text detailText:detailText hideAfterDelay:delay];
}

- (void)hideHUDAnimated:(BOOL)animated {
    [self.tipView hideAnimated:animated];
}
- (void)hideHUDAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay {
    [self.tipView hideAnimated:animated afterDelay:delay];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    [self showAlertWithTitle:title message:message cancelAction:nil doneAction:nil];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelAction:(void(^)(void))cancalBlock doneAction:(void(^)(void))doneBlock {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        !cancalBlock?:cancalBlock();
    }];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        !doneBlock?:doneBlock();
    }];
    
    [alertVC addAction:cancelAction];
    [alertVC addAction:doneAction];
    
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVC presentViewController:alertVC animated:YES completion:nil];
}


#pragma mark - Getter & Setter
- (void)setTipView:(LFUITips *)tipView {
    objc_setAssociatedObject(self, kTipView, tipView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (LFUITips *)tipView {
    
    LFUITips *tipView = objc_getAssociatedObject(self, kTipView);
    if (tipView) return tipView;
    
    tipView = [[LFUITips alloc] initWithView:self];
    
    [self setTipView:tipView];
    [self addSubview:tipView];
    
    return tipView;
}


@end
