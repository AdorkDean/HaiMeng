//
//  UIView+HUD.h
//  TipDemo
//
//  Created by ZhiHua Shen on 2017/1/14.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LFUITips.h"

@interface UIView (HUD)

@property (nonatomic,strong) LFUITips *tipView;

- (void)showWithText:(NSString *)text;
- (void)showWithText:(NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showWithText:(NSString *)text detailText:(NSString *)detailText;
- (void)showWithText:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

- (void)showLoading;
- (void)showLoading:(NSString *)text;
- (void)showLoadingHideAfterDelay:(NSTimeInterval)delay;
- (void)showLoading:(NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showLoading:(NSString *)text detailText:(NSString *)detailText;
- (void)showLoading:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

- (void)showSucceed:(NSString *)text;
- (void)showSucceed:(NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showSucceed:(NSString *)text detailText:(NSString *)detailText;
- (void)showSucceed:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

- (void)showError:(NSString *)text;
- (void)showError:(NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showError:(NSString *)text detailText:(NSString *)detailText;
- (void)showError:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

- (void)showErrorWithError:(NSError *)error;

- (void)showInfo:(NSString *)text;
- (void)showInfo:(NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showInfo:(NSString *)text detailText:(NSString *)detailText;
- (void)showInfo:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

- (void)hideHUDAnimated:(BOOL)animated;
- (void)hideHUDAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay;


- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelAction:(void(^)(void))cancalBlock doneAction:(void(^)(void))doneBlock;


@end
