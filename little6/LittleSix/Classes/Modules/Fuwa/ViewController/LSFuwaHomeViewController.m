//
//  LSFuwaHomeViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaHomeViewController.h"
#import "LSFuwaPasswordView.h"
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#import "LSFuwaMessageViewController.h"
#import "LSFuwaBackpackViewController.h"
#import "LSFuwaExchangeViewController.h"
#import "LSFuwaShowViewController.h"
#import "LSFuwaUserCodeView.h"
#import "LSFuwaHomeOptionsView.h"
#import "LSQRCodeViewController.h"
#import "MMDrawerController.h"
#import "LSMessageManager.h"
#import "LSRecomendViewController.h"

@interface LSFuwaHomeViewController ()

@property (nonatomic,strong) UIView *optionsView;

@property (nonatomic,strong) UIView *notiView;

@end

@implementation LSFuwaHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //隐藏导航条
    self.fd_prefersNavigationBarHidden = YES;

    [[UINavigationBar appearance] setTranslucent:NO];
    
    [self initSubViews];
    
    [self registNotification];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    UIImage *bgImage = [UIImage imageWithColor:kMainColor];
    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];

    self.fd_interactivePopDisabled = NO;
    
    [self setNaviBarTintColor:[UIColor whiteColor]];
}

- (void)registNotification {
    
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kMessageUnReadCountDidChange object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        kDISPATCH_MAIN_THREAD(^{
            [self setMessageUnReadCount];
        })
    }];
}

- (void)initSubViews {

    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"fuwa_bg"].CGImage);

    UIImageView *headerImage = [UIImageView new];
    headerImage.image = [UIImage imageNamed:@"fuwa_heading"];
    [self.view addSubview:headerImage];

    [headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_centerY).offset(30);
    }];
    
    UIButton *applyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [applyButton setTitle:@"我要申请福娃>" forState:UIControlStateNormal];
    [applyButton setTitleColor:HEXRGB(0xd0976f) forState:UIControlStateNormal];
    applyButton.titleLabel.font = SYSTEMFONT(15);
    
    [self.view addSubview:applyButton];
    [applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-33);
    }];
    
    @weakify(self)
    [[applyButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        [self setNaviBarTintColor:HEXRGB(0xe7d09a)];
        UIViewController *vc = [[UIStoryboard storyboardWithName:@"Fuwa" bundle:nil] instantiateViewControllerWithIdentifier:@"LSFuwaApplyViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    UIButton *hiddenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hiddenButton.backgroundColor = HEXRGB(0xd3000f);
    hiddenButton.titleLabel.font = BOLDSYSTEMFONT(18);
    [hiddenButton setTitleColor:HEXRGB(0xe7d09a) forState:UIControlStateNormal];
    ViewBorderRadius(hiddenButton, 5, 1, HEXRGB(0xff0012));
    [hiddenButton setTitle:@"藏福娃" forState:UIControlStateNormal];
    [self.view addSubview:hiddenButton];
    [hiddenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(applyButton.mas_top).offset(-25);
        make.height.offset(45);
        make.width.offset(223);
    }];
    [[hiddenButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl *_Nullable x) {
        @strongify(self)
        [self setNaviBarTintColor:[UIColor whiteColor]];
        UIViewController *vc = [NSClassFromString(@"LSFuwaHiddenViewController") new];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    UIButton *findButton = [UIButton buttonWithType:UIButtonTypeCustom];
    findButton.backgroundColor = HEXRGB(0xd3000f);
    findButton.titleLabel.font = BOLDSYSTEMFONT(18);
    [findButton setTitleColor:HEXRGB(0xe7d09a) forState:UIControlStateNormal];
    ViewBorderRadius(findButton, 5, 1, HEXRGB(0xff0012));
    [findButton setTitle:@"找福娃" forState:UIControlStateNormal];
    [[findButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        UIViewController *vc = [NSClassFromString(@"LSRecomendViewController") new];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [self.view addSubview:findButton];
    [findButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.left.equalTo(hiddenButton);
        make.bottom.equalTo(hiddenButton.mas_top).offset(-25);
        make.width.mas_equalTo(106);
    }];
    
    UIButton *partnerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    partnerButton.backgroundColor = HEXRGB(0xd3000f);
    partnerButton.titleLabel.font = BOLDSYSTEMFONT(18);
    [partnerButton setTitleColor:HEXRGB(0xe7d09a) forState:UIControlStateNormal];
    ViewBorderRadius(partnerButton, 5, 1, HEXRGB(0xff0012));
    [partnerButton setTitle:@"找萌友" forState:UIControlStateNormal];
    [[partnerButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        LSRecomendViewController *vc = [NSClassFromString(@"LSRecomendViewController") new];
        vc.type = LSRecomendTypeMeng;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [self.view addSubview:partnerButton];
    [partnerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.right.equalTo(hiddenButton);
        make.bottom.equalTo(hiddenButton.mas_top).offset(-25);
        make.width.mas_equalTo(106);
    }];
    
    
    UIButton *packageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [packageButton setImage:[UIImage imageNamed:@"fuwa_package"] forState:UIControlStateNormal];
    [self.view addSubview:packageButton];
    [packageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(findButton.mas_top).offset(-22);
    }];
    [[packageButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        [self setNaviBarTintColor:HEXRGB(0xe7d09a)];
        LSFuwaBackpackViewController *vc = [LSFuwaBackpackViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }];

    CGFloat offset = 20;

    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [messageButton setImage:[UIImage imageNamed:@"fuwa_message"] forState:UIControlStateNormal];
    [self.view addSubview:messageButton];
    [messageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view).offset(-kScreenWidth * 0.25 - offset);
        make.bottom.equalTo(packageButton).offset(-10);
    }];
    [[messageButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        [self setNaviBarTintColor:[UIColor whiteColor]];
        LSFuwaMessageViewController *vc =[LSFuwaMessageViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }];

    UIButton *tradeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tradeButton setImage:[UIImage imageNamed:@"fuwa_trade"] forState:UIControlStateNormal];
    [self.view addSubview:tradeButton];
    [tradeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view).offset(kScreenWidth * 0.25 + offset);
        make.bottom.equalTo(packageButton).offset(-10);
    }];
    [[tradeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        [self setNaviBarTintColor:HEXRGB(0xe7d09a)];
        LSFuwaExchangeViewController *vc = [LSFuwaExchangeViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }];

    UIButton *rightItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightItemButton.titleLabel.font = SYSTEMFONT(15);
    [rightItemButton setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [rightItemButton setTitleColor:HEXRGB(0xe7d09a) forState:UIControlStateNormal];
    [self.view addSubview:rightItemButton];
    [rightItemButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.view).offset(25);
        make.height.mas_equalTo(50);
    }];
    
    LSFuwaHomeOptionsView * optionsView = [LSFuwaHomeOptionsView fuwaHomeOptionsView];
    optionsView.hidden = YES;
    self.optionsView = optionsView;
    [self.view addSubview:optionsView];
    
    [optionsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(rightItemButton.mas_bottom);
        make.right.equalTo(rightItemButton).offset(10);
        make.width.mas_equalTo(106);
        make.height.mas_equalTo(88);
    }];
    
    [optionsView setShowPasswordBlock:^{
        LSFuwaPasswordView * passWordView = [LSFuwaPasswordView showInView:LSKeyWindow];
        [passWordView setFuwaUserCodeBlock:^{
            [[LSFuwaUserCodeView fuwaUserCodeView]showCodeView];
        }];
    }];
    
    [optionsView setCheckFuwaBlock:^{
        @strongify(self)
        LSQRCodeViewController * vc = [LSQRCodeViewController new];
        vc.codeType = LSQRcodeTypeFuwa;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    [[rightItemButton rac_signalForControlEvents:UIControlEventTouchUpInside]
        subscribeNext:^(__kindof UIControl *_Nullable x) {
            optionsView.hidden = !optionsView.isHidden;

    }];
    
    //排行榜
    UIButton *rangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rangeButton setImage:[UIImage imageNamed:@"fuwa_charts"] forState:UIControlStateNormal];
    [self.view addSubview:rangeButton];
    [rangeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(rightItemButton);
        make.right.equalTo(rightItemButton.mas_left).offset(-20);
    }];
    
    [[rangeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        UIViewController *vc = [NSClassFromString(@"LSWebViewController") new];
        [vc setValue:kFuwaTopURL forKey:@"urlString"];
        [vc setValue:@"FuwaTop" forKey:@"type"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    //规则
    UIButton *ruleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [ruleButton setImage:[UIImage imageNamed:@"fuwa_game_rule"] forState:UIControlStateNormal];
    [self.view addSubview:ruleButton];
    [ruleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(rightItemButton);
        make.right.equalTo(rangeButton.mas_left).offset(-20);
    }];
    
    [[ruleButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        UIViewController *webVC = [NSClassFromString(@"LSWebViewController") new];
        [webVC setValue:@"gameRule" forKey:@"type"];
        [webVC setValue:kFuwaAnswerURL forKey:@"urlString"];
        [self.navigationController pushViewController:webVC animated:YES];
    }];
    
    //用户头像
    UIControl *userControl = [UIControl new];
    
    [[userControl rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        MMDrawerController *drawerController = (MMDrawerController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }];
    
    [self.view addSubview:userControl];
    [userControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(rightItemButton);
        make.left.offset(15);
        make.height.offset(37);
        make.width.offset(180);
    }];
    
    UIImageView *iconView = [UIImageView new];
    ViewRadius(iconView, 37*0.5);
    [iconView setImageURL:[NSURL URLWithString:ShareAppManager.loginUser.avatar]];
    [userControl addSubview:iconView];
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(userControl);
        make.width.equalTo(iconView.mas_height);
    }];
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.text = ShareAppManager.loginUser.user_name;
    nameLabel.font = BOLDSYSTEMFONT(15);
    nameLabel.textColor = [UIColor whiteColor];
    
    [userControl addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(userControl);
        make.left.equalTo(iconView.mas_right).offset(6);
        make.right.equalTo(userControl.mas_right);
    }];
    
    UIView *notiView = [UIView new];
    self.notiView = notiView;
    notiView.backgroundColor = HEXRGB(0xd42136);
    [userControl addSubview:notiView];
    [notiView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(10);
        make.top.equalTo(iconView).offset(-2);
        make.centerX.equalTo(iconView.mas_right).offset(-2);
    }];
    ViewBorderRadius(notiView, 5, 0.5, [UIColor whiteColor]);
    
    [self setMessageUnReadCount];
}

- (void)setMessageUnReadCount {
    //设置未读消息
    NSInteger unReadCount = [LSMessageManager totalUnReadCount];
    
    self.notiView.hidden = !(unReadCount>0);
}

- (void)setNaviBarTintColor:(UIColor *)color {
//
    NSDictionary *attribute = @{NSForegroundColorAttributeName : color};
    [self.navigationController.navigationBar setTitleTextAttributes:attribute];
    [self.navigationController.navigationBar setBarTintColor:color];
    [self.navigationController.navigationBar setTintColor:color];
    //设置UIBarbuttonItem的大小样式
    UIBarButtonItem *item = [UIBarButtonItem appearance];
    NSMutableDictionary *itemAttr = [NSMutableDictionary dictionary];
    itemAttr[NSForegroundColorAttributeName] = color;
    itemAttr[NSFontAttributeName] = SYSTEMFONT(16);
    [item setTitleTextAttributes:itemAttr forState:UIControlStateNormal];
    [item setTitleTextAttributes:itemAttr forState:UIControlStateHighlighted];
    [item setTitleTextAttributes:itemAttr forState:UIControlStateSelected];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.optionsView.hidden = YES;
}

@end
