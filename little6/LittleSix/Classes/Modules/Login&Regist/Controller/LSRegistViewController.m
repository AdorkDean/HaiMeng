//
//  LSRegistViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSRegistViewController.h"
#import "UIView+HUD.h"
#import "LSUserModel.h"

@interface LSRegistViewController ()

@property (nonatomic,strong) UIButton *registButton;
@property (nonatomic,strong) UITextField *phoneTextField;
@property (nonatomic,strong) UITextField *codeTextField;

@end

@implementation LSRegistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"注册";
    
    [self _installSubViews];
    
    [self installNotifications];
}

- (void)_installSubViews {
    
    self.view.backgroundColor = [UIColor whiteColor];

    UILabel *phoneTagLabel = [UILabel new];
    phoneTagLabel.text = @"手机号";
    phoneTagLabel.font = SYSTEMFONT(16);
    phoneTagLabel.textColor = [UIColor blackColor];
    
    [self.view addSubview:phoneTagLabel];
    [phoneTagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_topLayoutGuide).offset(24);
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
    [getCodeButton addTarget:self action:@selector(codeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:getCodeButton];
    [getCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(100);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(lineView1.mas_bottom).offset(5);
        make.bottom.equalTo(lineView2.mas_bottom).offset(-5);
    }];
    
    [vericodeTextField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(getCodeButton.mas_left).offset(-8);
    }];
    
    UIButton *registButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.registButton = registButton;
    [registButton setTitle:@"注册" forState:UIControlStateNormal];
    [registButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    registButton.titleLabel.font = SYSTEMFONT(18);
    registButton.backgroundColor = kMainColor;
    ViewRadius(registButton, 5);
    [self updateRegistButton:NO];
    [registButton addTarget:self action:@selector(registButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:registButton];
    [registButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.height.offset(47);
        make.top.equalTo(lineView2.mas_bottom).offset(30);
    }];
    
    UILabel *tipsLabel = [UILabel new];
    tipsLabel.text = @"接收短信大约需要45秒";
    tipsLabel.textColor = HEXRGB(0x888888);
    tipsLabel.font = SYSTEMFONT(13);
    
    [self.view addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(registButton.mas_bottom).offset(23);
    }];
    
    UIButton *protocolButton = [UIButton buttonWithType:UIButtonTypeCustom];
    protocolButton.titleLabel.font = SYSTEMFONT(12);
    [protocolButton setTitleColor:HEXRGB(0x576b95) forState:UIControlStateNormal];
    [protocolButton setTitle:@"《软件许可及服务协议》" forState:UIControlStateNormal];
    
    [self.view addSubview:protocolButton];
    [protocolButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-16);
    }];
    @weakify(self)
    [[protocolButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        UIViewController *webVC = [NSClassFromString(@"LSWebViewController") new];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"service_agreement.html" ofType:nil];
        [webVC setValue:path forKey:@"localHtmlPath"];
        [self.navigationController pushViewController:webVC animated:YES];
    }];
    
    UILabel *agreeLabel = [UILabel new];
    agreeLabel.textColor = HEXRGB(0x525459);
    agreeLabel.font = SYSTEMFONT(12);
    agreeLabel.text = @"轻触上面的“注册”按钮，即表示你同意";
    
    [self.view addSubview:agreeLabel];
    [agreeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(protocolButton.mas_top);
    }];
    
}

- (void)updateRegistButton:(BOOL)enable {
    if (enable) {
        self.registButton.alpha = 1;
        self.registButton.enabled = YES;
    }
    else {
        self.registButton.alpha = 0.3;
        self.registButton.enabled = NO;
    }
}

- (void)installNotifications {
    @weakify(self)
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UITextFieldTextDidChangeNotification object:nil] throttle:0.25] subscribeNext:^(id x) {
        @strongify(self)
        BOOL enable = (self.phoneTextField.text.length != 0 && self.codeTextField.text.length != 0);
        [self updateRegistButton:enable];
    }];
}

#pragma mark - Action
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)registButtonAction {
    
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
    [self.navigationController pushViewController:setPwdVC animated:YES];
}

- (void)codeButtonAction:(UIButton *)button {
    
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
    
    [LSUserModel sendVerifyCode:phone type:1 success:^{
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

@end
