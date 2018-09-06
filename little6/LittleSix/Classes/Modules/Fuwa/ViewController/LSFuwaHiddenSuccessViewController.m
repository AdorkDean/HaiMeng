//
//  LSFuwaHiddenSuccessViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/18.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaHiddenSuccessViewController.h"
#import "UIViewController+BackButtonHandler.h"

@interface LSFuwaHiddenSuccessViewController () <BackButtonHandlerProtocol>

@end

@implementation LSFuwaHiddenSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"藏福娃";

    [self installSubviews];
}

- (void)installSubviews {

    self.view.backgroundColor = [UIColor whiteColor];

    UIImageView *coverView = [UIImageView new];
    coverView.image = self.cluesImage;
    coverView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:coverView];
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    [self.view addSubview:effectView];
    [effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    UIView *contentView = [UIView new];
    ViewRadius(contentView, 3);
    contentView.layer.contentMode = UIViewContentModeCenter;
    contentView.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"fuwa_bg"].CGImage);
    contentView.layer.masksToBounds = YES;
    [self.view addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(25);
        make.right.equalTo(self.view).offset(-25);
        make.centerY.equalTo(self.view);
        make.height.offset(438);
    }];

    UIImageView *cluesView = [UIImageView new];
    cluesView.clipsToBounds = YES;
    cluesView.image = self.cluesImage;
    cluesView.contentMode = UIViewContentModeScaleAspectFill;
    cluesView.backgroundColor = [UIColor blueColor];
    [contentView addSubview:cluesView];
    [cluesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(contentView);
        make.top.equalTo(contentView).offset(40);
        make.width.height.offset(205);
    }];

    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [locationButton setImage:[UIImage imageNamed:@"fuwa_position_bz"] forState:UIControlStateNormal];
    [locationButton setTitle:self.position forState:UIControlStateNormal];
    [locationButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    [locationButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [locationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    locationButton.titleLabel.font = SYSTEMFONT(14);
    ViewBorderRadius(locationButton, 19, 1, HEXRGB(0xff0012));
    locationButton.backgroundColor = [UIColor colorWithRGB:0x000000 alpha:0.65];
    [contentView addSubview:locationButton];
    [locationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(cluesView.mas_bottom);
        make.centerX.equalTo(contentView);
        make.width.offset(183);
        make.height.offset(38);
    }];

    UILabel *tipsLabel1 = [UILabel new];
    tipsLabel1.text = @"福娃藏好了";
    tipsLabel1.font = SYSTEMFONT(18);
    tipsLabel1.textColor = [UIColor whiteColor];
    [self.view addSubview:tipsLabel1];
    [tipsLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(contentView);
        make.top.equalTo(locationButton.mas_bottom).offset(26);
    }];

    UILabel *tipsLabel2 = [UILabel new];
    tipsLabel2.text = @"到福娃所在的位置，按线索图扫描找福娃";
    tipsLabel2.textColor = HEXRGB(0xcccccc);
    tipsLabel2.font = SYSTEMFONT(14);
    [self.view addSubview:tipsLabel2];
    [tipsLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(tipsLabel1);
        make.top.equalTo(tipsLabel1.mas_bottom).offset(11);
    }];

    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.backgroundColor = HEXRGB(0xd3000f);
    [doneButton setTitle:@"完成" forState:UIControlStateNormal];
    [doneButton setTitleColor:HEXRGB(0xe7d09a) forState:UIControlStateNormal];
    doneButton.titleLabel.font = SYSTEMFONT(18);
    ViewBorderRadius(doneButton, 5, 1, HEXRGB(0xff0012));
    [self.view addSubview:doneButton];
    [doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView).offset(15);
        make.right.equalTo(contentView).offset(-15);
        make.height.offset(45);
        make.top.equalTo(tipsLabel2.mas_bottom).offset(31);
    }];

    @weakify(self)[[doneButton rac_signalForControlEvents:UIControlEventTouchUpInside]
        subscribeNext:^(__kindof UIControl *_Nullable x) {
            @strongify(self) UIViewController *popVC;
            for (UIViewController *vc in self.navigationController.childViewControllers) {
                if ([vc isKindOfClass:NSClassFromString(@"LSFuwaHomeViewController")]) {
                    popVC = vc;
                    break;
                }
            }
            [self.navigationController popToViewController:popVC animated:YES];
        }];
}

- (BOOL)navigationShouldPopOnBackButton {

    UIViewController *destVC;
    for (UIViewController *vc in self.navigationController.childViewControllers) {
        if ([vc isKindOfClass:NSClassFromString(@"LSFuwaHiddenViewController")]) {
            destVC = vc;
            break;
        }
    }

    [self.navigationController popToViewController:destVC animated:YES];

    return NO;
}

@end
