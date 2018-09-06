//
//  LSLoginViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSLoginViewController.h"
#import "LSUserModel.h"
#import "UIView+HUD.h"
#import <ShareSDKExtension/SSEThirdPartyLoginHelper.h>
#import <ShareSDKExtension/ShareSDK+Extension.h>

@interface LSLoginViewController ()

@property (nonatomic,strong) UITextField *phoneTextField;
@property (nonatomic,strong) UITextField *passwordTextField;
@property (nonatomic,strong) UIButton *loginButton;

@end

@implementation LSLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"登录";
    
    [self _installSubViews];
    [self installNotification];
}

- (void)_installSubViews {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *accTagLabel = [UILabel new];
    accTagLabel.text = @"账号";
    accTagLabel.font = SYSTEMFONT(16);
    accTagLabel.textColor = [UIColor blackColor];
    
    [self.view addSubview:accTagLabel];
    [accTagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide).offset(24);
        make.left.equalTo(self.view).offset(20);
        make.height.offset(44);
        make.width.offset(35);
    }];
    
    UITextField *accTextField = [UITextField new];
    accTextField.placeholder = @"请输入手机号";
    self.phoneTextField = accTextField;
    accTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    [self.view addSubview:accTextField];
    [accTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(accTagLabel.mas_right).offset(60);
        make.top.bottom.equalTo(accTagLabel);
        make.right.equalTo(self.view).offset(20);
    }];
    
    UIView *lineView1 = [UIView new];
    lineView1.backgroundColor = HEXRGB(0xdddddd);
    
    [self.view addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(accTagLabel);
        make.right.equalTo(self.view);
        make.top.equalTo(accTagLabel.mas_bottom);
        make.height.offset(0.5);
    }];
    
    UILabel *pwdTagLabel = [UILabel new];
    pwdTagLabel.text = @"密码";
    pwdTagLabel.textColor = accTagLabel.textColor;
    pwdTagLabel.font = accTagLabel.font;
    
    [self.view addSubview:pwdTagLabel];
    [pwdTagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.with.height.equalTo(accTagLabel);
        make.top.equalTo(lineView1.mas_bottom);
    }];
    
    UITextField *pwdTextField = [UITextField new];
    pwdTextField.placeholder = @"请填写密码";
    self.passwordTextField = pwdTextField;
    pwdTextField.secureTextEntry = YES;
    
    [self.view addSubview:pwdTextField];
    [pwdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.height.right.equalTo(accTextField);
        make.top.equalTo(lineView1.mas_bottom);
    }];
    
    UIView *lineView2 = [UIView new];
    lineView2.backgroundColor = lineView1.backgroundColor;
    
    [self.view addSubview:lineView2];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(lineView1);
        make.top.equalTo(pwdTextField.mas_bottom);
    }];

    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.backgroundColor = kMainColor;
    loginButton.titleLabel.font = SYSTEMFONT(18);
    loginButton.layer.cornerRadius = 5;
    loginButton.layer.masksToBounds = YES;
    self.loginButton = loginButton;
    [self updateLoginButton:NO];
    
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:loginButton];
    [loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(accTagLabel);
        make.right.equalTo(self.view).offset(-20);
        make.height.offset(47);
        make.top.equalTo(lineView2.mas_bottom).offset(30);
    }];
    

    UIButton *registButton = [UIButton buttonWithType:UIButtonTypeCustom];
    registButton.titleLabel.font = SYSTEMFONT(13);
    [registButton setTitle:@"注册" forState:UIControlStateNormal];
    [registButton setTitleColor:HEXRGB(0xd42136) forState:UIControlStateNormal];
    [registButton addTarget:self action:@selector(registButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:registButton];
    [registButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(loginButton);
        make.top.equalTo(loginButton.mas_bottom).offset(23);
    }];
    
    UIButton *forgetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [forgetButton setTitle:@"忘记密码？" forState:UIControlStateNormal];
    forgetButton.titleLabel.font = registButton.titleLabel.font;
    [forgetButton setTitleColor:HEXRGB(0xd42136) forState:UIControlStateNormal];
    [forgetButton addTarget:self action:@selector(forgotPwdAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:forgetButton];
    [forgetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(loginButton.mas_right);
        make.top.equalTo(registButton);
    }];
    
    UILabel *thirdPartLoginTag = [UILabel new];
    thirdPartLoginTag.text = @"第三方登录";
    thirdPartLoginTag.font = SYSTEMFONT(16);
    thirdPartLoginTag.textColor = HEXRGB(0x2e2e2e);
    
    [self.view addSubview:thirdPartLoginTag];
    [thirdPartLoginTag mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-118);
    }];
    
    UIView *lineView3 = [UIView new];
    lineView3.backgroundColor = HEXRGB(0x999999);
    
    [self.view addSubview:lineView3];
    [lineView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(loginButton);
        make.centerY.equalTo(thirdPartLoginTag);
        make.height.offset(0.5);
        make.right.equalTo(thirdPartLoginTag.mas_left).offset(-10);
    }];
    
    UIView *lineView4 = [UIView new];
    lineView4.backgroundColor = HEXRGB(0x999999);
    [self.view addSubview:lineView4];
    
    [lineView4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(thirdPartLoginTag.mas_right).offset(10);
        make.right.equalTo(loginButton);
        make.centerY.height.equalTo(lineView3);
    }];
    
    UIStackView *stackView = [UIStackView new];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.distribution = UIStackViewDistributionFillEqually;
    [self.view addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(loginButton);
        make.top.equalTo(thirdPartLoginTag.mas_bottom);
        make.bottom.equalTo(self.view);
    }];
    
    BOOL installQQ = [ShareSDK isClientInstalled:SSDKPlatformTypeQQ];
    BOOL installWechat = [ShareSDK isClientInstalled:SSDKPlatformTypeWechat];
    
    if (installQQ) {
        UIButton *qqButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [qqButton setImage:[UIImage imageNamed:@"Login_QQ"] forState:UIControlStateNormal];
        [stackView addArrangedSubview:qqButton];
        [qqButton addTarget:self action:@selector(QQLoginAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (installWechat) {
        UIButton *wechatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [wechatButton setImage:[UIImage imageNamed:@"Login_WX"] forState:UIControlStateNormal];
        [stackView addArrangedSubview:wechatButton];
        [wechatButton addTarget:self action:@selector(wechatLoginAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!installWechat && !installQQ) {
        thirdPartLoginTag.hidden = YES;
        lineView3.hidden = YES;
        lineView4.hidden = YES;
    }
    
}

- (void)installNotification {
    @weakify(self)
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UITextFieldTextDidChangeNotification object:nil] throttle:0.25] subscribeNext:^(id x) {
        @strongify(self)
        BOOL enable = (self.phoneTextField.text.length != 0 && self.passwordTextField.text.length != 0);
        [self updateLoginButton:enable];
    }];
}

- (void)updateLoginButton:(BOOL)enable {
    if (enable) {
        self.loginButton.alpha = 1;
        self.loginButton.enabled = YES;
    }
    else {
        self.loginButton.alpha = 0.3;
        self.loginButton.enabled = NO;
    }
}

#pragma mark - Action
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)registButtonAction {
    
    UIViewController *registVC = [NSClassFromString(@"LSRegistViewController") new];
    
    [self.navigationController pushViewController:registVC animated:YES];
}

- (void)forgotPwdAction {
    UIViewController *vc = [NSClassFromString(@"LSForgotPwdViewController") new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loginAction:(UIButton *)button {
    
    [self.view endEditing:YES];
    [self.view showLoading:@"正在登录"];

    NSString *phone = [self.phoneTextField.text stringByTrim];
    NSString *password = [self.passwordTextField.text stringByTrim];
    
    [LSUserModel loginWithPhone:phone password:password success:^(LSUserModel *user) {
        user.loginType = userLoginTypeSelf;

        [self.view hideHUDAnimated:YES];
        [LSAppManager loginSuccessWithUser:user];
        
    } failure:^(NSError *error) {
        if (error.code == -1009) {
            [self.view showError:@"网络异常" hideAfterDelay:1.5];
        }
        else {
            [self.view showError:@"账号或密码错误" hideAfterDelay:1.5];
        }
        NSLog(@"%@",error);
    }];
}

- (void)QQLoginAction:(UIButton *)button {
    
    [self.view endEditing:YES];
    [self.view showLoading:@"正在授权"];
    
    [SSEThirdPartyLoginHelper loginByPlatform:SSDKPlatformTypeQQ onUserSync:^(SSDKUser *user, SSEUserAssociateHandler associateHandler) {
        
        [LSUserModel QQAuthWithToken:user.credential.token nickName:user.nickname avartar:user.icon success:^(LSUserModel *user) {
            user.loginType = userLoginTypeQQ;
            [self.view hideHUDAnimated:YES];
            [LSAppManager loginSuccessWithUser:user];
            
        } failure:^(NSError *error) {
            if (error.code == -1009) {
                [self.view showError:@"网络异常" hideAfterDelay:1.5];
            }
            else {
                [self.view showError:@"登录失败" hideAfterDelay:1.5];
            }
        }];
        
    } onLoginResult:^(SSDKResponseState state, SSEBaseUser *user, NSError *error) {
        if (error) {
            [self.view showError:@"授权失败" hideAfterDelay:1.5];
        }
    }];
    
}

- (void)wechatLoginAction:(UIButton *)button {
    
    [self.view endEditing:YES];
    [self.view showLoading:@"正在授权"];
    
    [SSEThirdPartyLoginHelper loginByPlatform:SSDKPlatformTypeWechat onUserSync:^(SSDKUser *user, SSEUserAssociateHandler associateHandler) {
        
        [LSUserModel WechatAuthWithUnionid:user.credential.uid nickName:user.nickname avartar:user.icon success:^(LSUserModel *user) {
            user.loginType = userLoginTypeWeChat;

            [self.view hideHUDAnimated:YES];
            [LSAppManager loginSuccessWithUser:user];
            
        } failure:^(NSError *error) {
            if (error.code == -1009) {
                [self.view showError:@"网络异常" hideAfterDelay:1.5];
            }
            else {
                [self.view showError:@"登录失败" hideAfterDelay:1.5];
            }
        }];
        
    } onLoginResult:^(SSDKResponseState state, SSEBaseUser *user, NSError *error) {
        if (error) {
            [self.view showError:@"授权失败" hideAfterDelay:1.5];
        }
    }];
}

@end
