//
//  LSPersonCodeView.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/18.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSPersonCodeView : UIView

+ (instancetype)personCodeView;

- (void)showInView:(UIView *)view andType:(NSString *)type andUser_id:(NSString *)user_id withAvatar:(NSString *)avatar withUser_name:(NSString *)user_name withSex:(NSString *)sex withDistrict_str:(NSString *)district_str enter:(int)enter;

@end
