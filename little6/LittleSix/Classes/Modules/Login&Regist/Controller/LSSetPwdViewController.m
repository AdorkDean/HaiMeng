//
//  LSSetPwdViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSSetPwdViewController.h"
#import "LSUserModel.h"
#import "UIView+HUD.h"

@interface LSSetPwdViewController ()

@property (nonatomic, strong) UITextField *pwdTextField;
@property (nonatomic, strong) UITextField *confirmTextField;

@end

@implementation LSSetPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置密码";

    [self _installSubViews];
}

- (void)_installSubViews {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *pwdTagLabel = [UILabel new];
    pwdTagLabel.text = @"设置密码";
    pwdTagLabel.font = SYSTEMFONT(16);
    pwdTagLabel.textColor = [UIColor blackColor];
    
    [self.view addSubview:pwdTagLabel];
    [pwdTagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide).offset(24);
        make.left.equalTo(self.view).offset(20);
        make.height.offset(44);
        make.width.offset(67);
    }];
    
    UITextField *pwdTextField = [UITextField new];
    self.pwdTextField = pwdTextField;
    pwdTextField.secureTextEntry = YES;
    pwdTextField.placeholder = @"请设置密码";
    
    [self.view addSubview:pwdTextField];
    [pwdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(pwdTagLabel.mas_right).offset(30);
        make.top.bottom.equalTo(pwdTagLabel);
        make.right.equalTo(self.view).offset(20);
    }];
    
    UIView *lineView1 = [UIView new];
    lineView1.backgroundColor = HEXRGB(0xdddddd);
    
    [self.view addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(pwdTagLabel);
        make.right.equalTo(self.view);
        make.top.equalTo(pwdTagLabel.mas_bottom);
        make.height.offset(0.5);
    }];
    
    UILabel *confirmTagLabel = [UILabel new];
    confirmTagLabel.text = @"验证密码";
    confirmTagLabel.textColor = pwdTagLabel.textColor;
    confirmTagLabel.font = pwdTagLabel.font;
    
    [self.view addSubview:confirmTagLabel];
    [confirmTagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.with.height.equalTo(pwdTagLabel);
        make.top.equalTo(lineView1.mas_bottom);
    }];
    
    UITextField *confirmTextField = [UITextField new];
    self.confirmTextField = confirmTextField;
    confirmTextField.secureTextEntry = YES;
    confirmTextField.placeholder = @"请验证密码";
    
    [self.view addSubview:confirmTextField];
    [confirmTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.height.right.equalTo(pwdTextField);
        make.top.equalTo(lineView1.mas_bottom);
    }];
    
    UIView *lineView2 = [UIView new];
    lineView2.backgroundColor = lineView1.backgroundColor;
    
    [self.view addSubview:lineView2];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(lineView1);
        make.top.equalTo(confirmTextField.mas_bottom);
    }];
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    submitButton.backgroundColor = kMainColor;
    submitButton.titleLabel.font = SYSTEMFONT(18);
    ViewRadius(submitButton, 5);
    [submitButton setTitle:@"确认" forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(verifyBtn) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:submitButton];
    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.height.offset(47);
        make.top.equalTo(lineView2.mas_bottom).offset(30);
    }];
}

- (void)verifyBtn{
    
    if (![self.pwdTextField.text isEqualToString:self.confirmTextField.text]) {
        [self.view showAlertWithTitle:@"提示" message:@"验证密码不统一"];
    }else if (self.confirmTextField.text.length < 6 || self.confirmTextField.text.length > 18){
        [self.view showAlertWithTitle:@"提示" message:@"密码6-18位，字母或数字"];
    }else{
        
        if (self.isFindpwd) {
            [LSUserModel findPwdCode:self.phone WithNewPassword:self.confirmTextField.text verify:self.code success:^{
                [LSKeyWindow showSucceed:@"修改成功" hideAfterDelay:1.5];
                [self.navigationController popToRootViewControllerAnimated:YES];
            } failure:^(NSError *error) {
                [LSKeyWindow showAlertWithTitle:@"提示" message:@"修改失败"];
            }];
            return;
        }
        [LSUserModel registCode:self.phone WithPassword:self.pwdTextField.text verify:self.code success:^{
            [LSKeyWindow showSucceed:@"注册成功" hideAfterDelay:1.5];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            [self.view showAlertWithTitle:@"提示" message:@"注册失败"];
        }];
        
    }
}
@end
