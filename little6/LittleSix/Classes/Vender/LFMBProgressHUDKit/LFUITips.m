//
//  LFUITips.m
//  LFMBProgressHUDKit
//
//  Created by 汪潇翔 on 07/01/2017.
//  Copyright © 2017 Youku. All rights reserved.
//

#import "LFUITips.h"


@implementation LFUITips


#pragma mark - Text
- (void)showWithText:(NSString *)text {
    [self showWithText:text detailText:nil hideAfterDelay:0];
}

- (void)showWithText:(NSString *)text hideAfterDelay:(NSTimeInterval)delay
{
    [self showWithText:text detailText:nil hideAfterDelay:delay];
}

- (void)showWithText:(NSString *)text detailText:(NSString *)detailText
{
    [self showWithText:text detailText:detailText hideAfterDelay:0];
}

- (void)showWithText:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay
{
#if DEBUG
    NSAssert(text.length > 0 , @"LFUITips 空文本, %@:%d %s, 非法的text：%@\n%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, __PRETTY_FUNCTION__, text, [NSThread callStackSymbols]);
#endif
    [self showWithText:text detailText:detailText mode:MBProgressHUDModeText hideAfterDelay:delay];
}

- (void)showWithText:(NSString *)text
          detailText:(NSString *)detailText
                mode:(LFMBProgressHUDMode)mode
      hideAfterDelay:(NSTimeInterval)delay
{
    self.mode = mode;
    self.label.text = text;
    if (detailText.length > 0) {
        self.detailsLabel.text = detailText;
    }
    [self showAnimated:YES];
    
    if (delay > 0) {
        [self hideAnimated:YES afterDelay:delay];
    }
}

#pragma mark - Loading
- (void)showLoading
{
    [self showLoading:nil detailText:nil hideAfterDelay:0.f];
}

- (void)showLoading:(NSString *)text
{
    [self showLoading:text detailText:nil hideAfterDelay:0.f];
}
- (void)showLoadingHideAfterDelay:(NSTimeInterval)delay
{
    [self showLoading:nil detailText:nil hideAfterDelay:delay];
}
- (void)showLoading:(NSString *)text hideAfterDelay:(NSTimeInterval)delay
{
    [self showLoading:text detailText:nil hideAfterDelay:delay];
}
- (void)showLoading:(NSString *)text detailText:(NSString *)detailText
{
    [self showLoading:text detailText:detailText hideAfterDelay:0.f];
}

- (void)showLoading:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay
{
    [self showWithText:text detailText:detailText mode:MBProgressHUDModeIndeterminate hideAfterDelay:delay];
}

#pragma mark - Succeed
- (void)showSucceed:(NSString *)text
{
    [self showSucceed:text detailText:nil hideAfterDelay:0.f];
}
- (void)showSucceed:(NSString *)text hideAfterDelay:(NSTimeInterval)delay
{
    [self showSucceed:text detailText:nil hideAfterDelay:delay];
}

- (void)showSucceed:(NSString *)text detailText:(NSString *)detailText
{
    [self showSucceed:text detailText:detailText hideAfterDelay:0.f];
}

- (void)showSucceed:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay
{
    UIImage *image = [[UIImage imageNamed:@"LFUIToast.bundle/tips_done"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.customView = [[UIImageView alloc] initWithImage:image];
    [self showWithText:text detailText:detailText mode:MBProgressHUDModeCustomView hideAfterDelay:delay];
}

#pragma mark - Error
- (void)showError:(NSString *)text
{
    [self showError:text detailText:nil hideAfterDelay:0.f];
}

- (void)showError:(NSString *)text hideAfterDelay:(NSTimeInterval)delay
{
    [self showError:text detailText:nil hideAfterDelay:delay];
}

- (void)showError:(NSString *)text detailText:(NSString *)detailText
{
    [self showError:text detailText:detailText hideAfterDelay:0.f];
}

- (void)showError:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay
{
    UIImage *image = [[UIImage imageNamed:@"LFUIToast.bundle/tips_error"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.customView = [[UIImageView alloc] initWithImage:image];
    [self showWithText:text detailText:detailText mode:MBProgressHUDModeCustomView hideAfterDelay:delay];
}
#pragma mark - Info
- (void)showInfo:(NSString *)text
{
    [self showInfo:text detailText:nil hideAfterDelay:0.f];
}
- (void)showInfo:(NSString *)text hideAfterDelay:(NSTimeInterval)delay
{
    [self showInfo:text detailText:nil hideAfterDelay:0.f];
}
- (void)showInfo:(NSString *)text detailText:(NSString *)detailText
{
    [self showInfo:text detailText:nil hideAfterDelay:0.f];
}
- (void)showInfo:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay
{
    UIImage *image = [[UIImage imageNamed:@"LFUIToast.bundle/tips_info"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.customView = [[UIImageView alloc] initWithImage:image];
    [self showWithText:text detailText:detailText mode:MBProgressHUDModeCustomView hideAfterDelay:delay];
}


#pragma mark - Text
+ (LFUITips *)showWithText:(NSString *)text inView:(UIView *)view
{
    return [self showWithText:text detailText:nil inView:view hideAfterDelay:0.f];
}

+ (LFUITips *)showWithText:(NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay
{
    return [self showWithText:text detailText:nil inView:view hideAfterDelay:delay];
}
+ (LFUITips *)showWithText:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view
{
    return [self showWithText:text detailText:detailText inView:view hideAfterDelay:0.f];
}

+ (LFUITips *)showWithText:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay
{
    LFUITips *tips = [[LFUITips alloc] initWithView:view];
    [tips showWithText:text detailText:detailText hideAfterDelay:delay];
    return tips;
}

#pragma mark - Loading

+ (LFUITips *)showLoadingInView:(UIView *)view
{
    return [self showLoading:nil detailText:nil inView:view hideAfterDelay:0.f];
}

+ (LFUITips *)showLoading:(NSString *)text inView:(UIView *)view
{
    return [self showLoading:text detailText:nil inView:view hideAfterDelay:0.f];
}

+ (LFUITips *)showLoadingInView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay
{
    return [self showLoading:nil detailText:nil inView:view hideAfterDelay:delay];
}

+ (LFUITips *)showLoading:(NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay
{
    return [self showLoading:text detailText:nil inView:view hideAfterDelay:delay];
}

+ (LFUITips *)showLoading:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view
{
    return [self showLoading:text detailText:detailText inView:view hideAfterDelay:0.f];
}

+ (LFUITips *)showLoading:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay
{
    LFUITips *tips = [[LFUITips alloc] initWithView:view];
    [tips showLoading:text detailText:detailText hideAfterDelay:delay];
    return tips;
}

#pragma mark - Succeed
+ (LFUITips *)showSucceed:(NSString *)text inView:(UIView *)view
{
    return [self showSucceed:text detailText:nil inView:view hideAfterDelay:0.f];
}

+ (LFUITips *)showSucceed:(NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay
{
    return [self showSucceed:text detailText:nil inView:view hideAfterDelay:delay];
}

+ (LFUITips *)showSucceed:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view
{
    return [self showSucceed:text detailText:detailText inView:view hideAfterDelay:0.f];
}

+ (LFUITips *)showSucceed:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay
{
    LFUITips *tips = [[LFUITips alloc] initWithView:view];
    [tips showSucceed:text detailText:detailText hideAfterDelay:delay];
    return tips;
}

#pragma mark - Error
+ (LFUITips *)showError:(NSString *)text inView:(UIView *)view
{
    return [self showError:text detailText:nil inView:view hideAfterDelay:0.f];
}

+ (LFUITips *)showError:(NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay
{
    return [self showError:text detailText:nil inView:view hideAfterDelay:delay];
}
+ (LFUITips *)showError:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view
{
    return [self showError:text detailText:detailText inView:view hideAfterDelay:0.f];
}

+ (LFUITips *)showError:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay
{
    LFUITips *tips = [[LFUITips alloc] initWithView:view];
    [tips showError:text detailText:detailText hideAfterDelay:delay];
    return tips;
}

+ (LFUITips *)showInfo:(NSString *)text inView:(UIView *)view
{
    return [self showInfo:text detailText:nil inView:view hideAfterDelay:0.f];
}

+ (LFUITips *)showInfo:(NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay
{
    return [self showInfo:text detailText:nil inView:view hideAfterDelay:delay];
}

+ (LFUITips *)showInfo:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view
{
    return [self showInfo:text detailText:detailText inView:view hideAfterDelay:0.f];
}

+ (LFUITips *)showInfo:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay
{
    LFUITips *tips = [[LFUITips alloc] initWithView:view];
    [tips showInfo:text detailText:detailText hideAfterDelay:delay];
    return tips;
}

@end
