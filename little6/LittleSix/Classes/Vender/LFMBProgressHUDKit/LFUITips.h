//
//  LFUITips.h
//  LFMBProgressHUDKit
//
//  Created by 汪潇翔 on 07/01/2017.
//  Copyright © 2017 Youku. All rights reserved.
//

#import <LFMBProgressHUDKit/LFMBProgressHUDKit.h>


@interface LFUITips : LFMBProgressHUD

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

- (void)showInfo:(NSString *)text;
- (void)showInfo:(NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showInfo:(NSString *)text detailText:(NSString *)detailText;
- (void)showInfo:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;


+ (LFUITips *)showWithText:(NSString *)text inView:(UIView *)view;
+ (LFUITips *)showWithText:(NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (LFUITips *)showWithText:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view;
+ (LFUITips *)showWithText:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

+ (LFUITips *)showLoadingInView:(UIView *)view;
+ (LFUITips *)showLoading:(NSString *)text inView:(UIView *)view;
+ (LFUITips *)showLoadingInView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (LFUITips *)showLoading:(NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (LFUITips *)showLoading:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view;
+ (LFUITips *)showLoading:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

+ (LFUITips *)showSucceed:(NSString *)text inView:(UIView *)view;
+ (LFUITips *)showSucceed:(NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (LFUITips *)showSucceed:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view;
+ (LFUITips *)showSucceed:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

+ (LFUITips *)showError:(NSString *)text inView:(UIView *)view;
+ (LFUITips *)showError:(NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (LFUITips *)showError:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view;
+ (LFUITips *)showError:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

+ (LFUITips *)showInfo:(NSString *)text inView:(UIView *)view;
+ (LFUITips *)showInfo:(NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (LFUITips *)showInfo:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view;
+ (LFUITips *)showInfo:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

@end
