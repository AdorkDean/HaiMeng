//
//  LSForgotPwdViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSForgotPwdViewController.h"
#import "LSUserModel.h"
#import "UIView+HUD.h"

@interface LSForgotPwdViewController ()

@property (nonatomic,strong) UITextField *phoneTextField;
@property (nonatomic,strong) UITextField *codeTextField;
@property (nonatomic,strong) UIButton *confirmButton;

@end

@implementation LSForgotPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"验证手机号";

    [self _installSubViews];
    
    [self installNotifications];
}

- (void)_installSubViews {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *tipsLabel = [UILabel new];
    tipsLabel.font = SYSTEMFONT(16);
    tipsLabel.textColor = HEXRGB(0x888888);
    tipsLabel.text = @"请输入手机号码以获取验证码进行验证";
    
    [self.view addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-10);
        make.top.equalTo(self.mas_topLayoutGuide).offset(22);
    }];
    
    UILabel *phoneTagLabel = [UILabel new];
    phoneTagLabel.text = @"手机号";
    phoneTagLabel.font = SYSTEMFONT(16);
    phoneTagLabel.textColor = [UIColor blackColor];
    
    [self.view addSubview:phoneTagLabel];
    [phoneTagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsLabel.mas_bottom).offset(5);
        make.left.equalTo(self.view).offset(20);
        make.height.offset(44);
        make.width.offset(52);
    }];
    
    UITextField *phoneTextField = [UITextField new];
    phoneTextField.placeholder = @"请输入手机号";
    phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneTextField = phoneTextField;
    
    [self.view addSubview:phoneTextField];
    [phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(phoneTagLabel.mas_right).offset(45);
        make.top.bottom.equalTo(phoneTagLabel);
        make.right.equalTo(self.view).offset(20);
    }];
    
    UIView *lineView1 = [UIView new];
    lineView1.backgroundColor = HEXRGB(0xdddddd);
    
    [self.view addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(phoneTagLabel);
        make.right.equalTo(self.view);
        make.top.equalTo(phoneTagLabel.mas_bottom);
        make.height.offset(0.5);
    }];
    
    UILabel *vericodeTagLabel = [UILabel new];
    vericodeTagLabel.text = @"验证码";
    vericodeTagLabel.textColor = phoneTagLabel.textColor;
    vericodeTagLabel.font = phoneTagLabel.font;
    
    [self.view addSubview:vericodeTagLabel];
    [vericodeTagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.with.height.equalTo(phoneTagLabel);
        make.top.equalTo(lineView1.mas_bottom);
    }];
    
    UITextField *vericodeTextField = [UITextField new];
    vericodeTextField.placeholder = @"请填写验证码";
    vericodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.codeTextField = vericodeTextField;
    
    [self.view addSubview:vericodeTextField];
    [vericodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.height.equalTo(phoneTextField);
        make.top.equalTo(lineView1.mas_bottom);
    }];
    
    UIView *lineView2 = [UIView new];
    lineView2.backgroundColor = lineView1.backgroundColor;
    
    [self.view addSubview:lineView2];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(lineView1);
        make.top.equalTo(vericodeTextField.mas_bottom);
    }];
    
    UIButton *getCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [getCodeButton setTitleColor:kMainColor forState:UIControlStateNormal];
    getCodeButton.titleLabel.font = SYSTEMFONT(14);
    ViewBorderRadius(getCodeButton, 5, 1, kMainColor);
    [getCodeButton addTarget:self action:@selector(getCodeAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:getCodeButton];
    [getCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(90);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(lineView1.mas_bottom).offset(5);
        make.bottom.equalTo(lineView2.mas_bottom).offset(-5);
    }];
    
    [vericodeTextField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(getCodeButton.mas_left).offset(-8);
    }];
    
    UIButton *reSendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [reSendButton setTitle:@"重新发送" forState:UIControlStateNormal];
    [reSendButton setTitleColor:kMainColor forState:UIControlStateNormal];
    reSendButton.titleLabel.font = SYSTEMFONT(14);
    [reSendButton addTarget:self action:@selector(reSendAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:reSendButton];
    [reSendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineView2.mas_bottom).offset(20);
        make.right.equalTo(getCodeButton);
    }];
    
    UILabel *unReceiveTipsLabel = [UILabel new];
    unReceiveTipsLabel.text = @"未收到验证码?";
    unReceiveTipsLabel.textColor = HEXRGB(0x888888);
    unReceiveTipsLabel.font = SYSTEMFONT(14);
    
    [self.view addSubview:unReceiveTipsLabel];
    [unReceiveTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(reSendButton);
        make.right.equalTo(reSendButton.mas_left).offset(-2);
    }];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = kMainColor;
    
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(reSendButton);
        make.top.equalTo(reSendButton.mas_bottom).offset(-5);
        make.height.offset(0.5);
    }];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.confirmButton = confirmButton;
    [confirmButton setTitle:@"确认" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmButton.titleLabel.font = SYSTEMFONT(18);
    confirmButton.backgroundColor = kMainColor;
    ViewRadius(confirmButton, 5);
    [self updateRegistButton:NO];
    [confirmButton addTarget:self action:@selector(confirmButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:confirmButton];
    [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.height.offset(47);
        make.top.equalTo(reSendButton.mas_bottom).offset(25);
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

- (void)installNotifications {
    @weakify(self)
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UITextFieldTextDidChangeNotification object:nil] throttle:0.25] subscribeNext:^(id x) {
        @strongify(self)
        BOOL enable = (self.phoneTextField.text.length != 0 && self.codeTextField.text.length != 0);
        [self updateRegistButton:enable];
    }];
}
- (void)updateRegistButton:(BOOL)enable {
    if (enable) {
        self.confirmButton.alpha = 1;
        self.confirmButton.enabled = YES;
    }
    else {
        self.confirmButton.alpha = 0.3;
        self.confirmButton.enabled = NO;
    }
}

#pragma mark - Action 
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)confirmButtonAction {
    
    NSString *phone = [self.phoneTextField.text stringByTrim];
    NSString *code = [self.codeTextField.text stringByTrim];
    
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

        UIViewController *setPwdVC =[NSClassFromString(@"LSSetPwdViewController") new];
        [setPwdVC setValue:phone forKey:@"phone"];
        [setPwdVC setValue:code forKey:@"code"];
        [setPwdVC setValue:@(1) forKey:@"isFindpwd"];
        [self.navigationController pushViewController:setPwdVC animated:YES];
    
}

- (void)getCodeAction:(UIButton *)button{
    NSString *phone = [self.phoneTextField.text stringByTrim];
    
    if (!phone||phone.length==0) {
        [self.view showAlertWithTitle:@"提示" message:@"请输入手机号"];
        return;
    }
    
    if (![self isMobileNumber:phone]) {
        [self.view showAlertWithTitle:@"提示" message:@"输入号码不是有效的手机号"];
        return;
    }
    
    [self.view showLoading:@"正在发送"];
    
    [LSUserModel sendVerifyCode:phone type:2 success:^{
        [self.view hideHUDAnimated:YES];
        [self cutdownWithButton:button];
    } failure:^(NSError *error) {
        [self.view showErrorWithError:error];
    }];
    
}
- (void)reSendAction:(UIButton *)button{
    [self getCodeAction:button];
}

@end
