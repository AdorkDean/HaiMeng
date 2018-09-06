//
//  LSMyQRCodeViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSMyQRCodeViewController.h"
#import "LSPersonCodeView.h"

@interface LSMyQRCodeViewController ()

@end

@implementation LSMyQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的二维码";
    self.view.backgroundColor = [UIColor blackColor];

    [[LSPersonCodeView personCodeView] showInView:self.view andType:@"uid" andUser_id:ShareAppManager.loginUser.user_id withAvatar:ShareAppManager.loginUser.avatar withUser_name:ShareAppManager.loginUser.user_name withSex:ShareAppManager.loginUser.sex withDistrict_str:ShareAppManager.loginUser.district_str enter:0];

}

@end
