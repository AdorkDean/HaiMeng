//
//  LSChangePhoneNumViewController.m
//  LittleSix
//
//  Created by Jim huang on 17/3/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSChangePhoneNumViewController.h"
#import "LSUserModel.h"
#import "UIView+HUD.h"

@interface LSChangePhoneNumViewController ()
@property (weak, nonatomic) IBOutlet UITextField *phoneNumNewTextField;
@property (weak, nonatomic) IBOutlet UITextField *securityCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIView *firstMarginView;

@end

@implementation LSChangePhoneNumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"更换手机号";
    
    self.sureBtn.layer.cornerRadius = 6.0;

    
    UIButton *getCodeButton = [UIButton new];
    [getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [getCodeButton setTitleColor:kMainColor forState:UIControlStateNormal];
    getCodeButton.titleLabel.font = SYSTEMFONT(14);
    ViewBorderRadius(getCodeButton, 5, 1, kMainColor);
    [getCodeButton addTarget:self action:@selector(codeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:getCodeButton];

    [getCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.securityCodeTextField.mas_centerY);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.height.mas_equalTo(35);
        make.width.mas_equalTo(90);
    }];
    
    [self.sureBtn addTarget:self action:@selector(sureBtnClick) forControlEvents:UIControlEventTouchUpInside];
}



-(void)sureBtnClick{
    
    NSString *phone = [self.phoneNumNewTextField.text stringByTrim];
    NSString *code = [self.securityCodeTextField.text stringByTrim];
    
    if (!phone || phone.length==0) {
        [self.view showAlertWithTitle:@"提示" message:@"请输入手机号"];
        return;
    }
    if (![self isMobileNumber:phone]) {
        [self.view showAlertWithTitle:@"提示" message:@"输入号码不是有效的手机号"];
        return;
    }
    if (code.length != 6) {
        [self.view showAlertWithTitle:@"提示" message:@"验证码只能是6位"];
        return;
    }
    
    [self.view showLoading];
    [LSUserModel bindmobileWithPhoneNum:phone verifycode:code Success:^{
        [self.view showSucceed:@"修改成功"hideAfterDelay:1];
        ShareAppManager.loginUser.mobile_phone = phone;
        self.phoneNumBlock(phone);
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        
    }];
    
}

- (void)codeButtonAction:(UIButton *)button {
    
    NSString *phone = [self.phoneNumNewTextField.text stringByTrim];
    
    if (!phone||phone.length==0) {
        [self.view showAlertWithTitle:@"提示" message:@"请输入手机号"];
        return;
    }
    
    if (![self isMobileNumber:phone]) {
        [self.view showAlertWithTitle:@"提示" message:@"输入号码不是有效的手机号"];
        return;
    }
    
    [self.view showLoading:@"正在发送"];
    
    [LSUserModel sendVerifyCode:phone type:4 success:^{
        [self.view hideHUDAnimated:YES];
        [self cutdownWithButton:button];
    } failure:^(NSError *error) {
        [self.view showErrorWithError:error];
    }];
    
}

- (void)cutdownWithButton:(UIButton *)button {
    
    button.userInteractionEnabled = NO;
    
    __block int timeout=119; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [button setTitle:@"获取验证码" forState:UIControlStateNormal];
                button.userInteractionEnabled = YES;
            });
        }else{
            int seconds = timeout % 120;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [button setTitle:[NSString stringWithFormat:@"%@s重新发送",strTime] forState:UIControlStateNormal];
                button.userInteractionEnabled = NO;
            });
            timeout--;
        }
    });
    
    dispatch_resume(_timer);
}

- (BOOL)isMobileNumber:(NSString *)mobileNum {
    NSString *MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|8[0-9]|7[06-8])\\d{8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    return [regextestmobile evaluateWithObject:mobileNum];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
