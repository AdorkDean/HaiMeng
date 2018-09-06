//
//  LSSetPwdViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSSetPwdViewController : UIViewController

@property (nonatomic,copy) NSString *phone;
@property (nonatomic,copy) NSString *code;
//是否为  找回密码
@property (nonatomic, assign) BOOL isFindpwd;

@end
