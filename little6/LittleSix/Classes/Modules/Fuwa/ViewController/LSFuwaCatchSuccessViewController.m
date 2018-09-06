
//
//  LSFuwaCatchSuccessViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/18.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaCatchSuccessViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "LSShareView.h"
#import "LSFuwaModel.h"
#import "LSFuwaSuccessFriendView.h"


@interface LSFuwaCatchSuccessViewController ()
@property(nonatomic,strong)LSFuwaSuccessFriendView *friendView;

@end

@implementation LSFuwaCatchSuccessViewController

- (void)viewDidLoad {
    [self.navigationController.navigationBar.backItem setTitle:@""];
    [self.navigationItem setHidesBackButton:YES];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    [super viewDidLoad];
    self.fd_interactivePopDisabled = YES;
    self.title = @"找福娃";
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
        make.height.offset(400);
    }];

    UIImageView *avatarView = [UIImageView new];
    [avatarView setImageURL:[NSURL URLWithString:ShareAppManager.loginUser.avatar]];
    ViewRadius(avatarView, 31);
    [self.view addSubview:avatarView];
    [avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(contentView);
        make.top.equalTo(contentView).offset(40);
        make.width.height.offset(62);
    }];

    UILabel *nameLabel = [UILabel new];
    nameLabel.text = ShareAppManager.loginUser.user_name;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.numberOfLines = 1;

    nameLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:nameLabel];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.left.equalTo(contentView).offset(10);
        make.right.equalTo(contentView).offset(-10);
        make.top.equalTo(avatarView.mas_bottom).offset(20);
    }];

    UILabel *tipsLabel = [UILabel new];
    tipsLabel.text = @"成功捕抓了";
    tipsLabel.textColor = HEXRGB(0xcccccc);
    tipsLabel.font = SYSTEMFONT(14);
    [self.view addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(nameLabel);
        make.top.equalTo(nameLabel.mas_bottom).offset(10);
    }];

    UILabel *numberLabel = [UILabel new];
    numberLabel.text = [NSString stringWithFormat:@"%@号福娃", self.model.id];
    numberLabel.font = SYSTEMFONT(30);
    numberLabel.textColor = HEXRGB(0xffffff);
    [self.view addSubview:numberLabel];
    [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(tipsLabel.mas_bottom).offset(20);
    }];

    UIView *redlineView = [UIView new];
    redlineView.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"fuwa_redline"].CGImage);
    [self.view addSubview:redlineView];
    [redlineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(contentView);
        make.top.equalTo(numberLabel.mas_bottom).offset(30);
        make.height.offset(2);
    }];

    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.backgroundColor = HEXRGB(0xd3000f);
    [shareButton setTitle:@"分享" forState:UIControlStateNormal];
    [shareButton setTitleColor:HEXRGB(0xe7d09a) forState:UIControlStateNormal];
    shareButton.titleLabel.font = SYSTEMFONT(18);
    ViewBorderRadius(shareButton, 5, 1, HEXRGB(0xff0012));
    [self.view addSubview:shareButton];
    
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView).offset(15);
        make.right.equalTo(contentView).offset(-15);
        make.height.offset(45);
        make.top.equalTo(redlineView.mas_bottom).offset(25);
    }];
    
    [[shareButton rac_signalForControlEvents:UIControlEventTouchUpInside]
        subscribeNext:^(__kindof UIControl *_Nullable x) {
            //分享的参数
            NSMutableDictionary *shareParam = [NSMutableDictionary dictionary];
            [shareParam SSDKSetupShareParamsByText:@"我在嗨萌成功捕抓了福娃，一起过来玩吧！" images:kAppIconImage url:[NSURL URLWithString:@"https://api.66boss.com/web/download"] title:@"嗨萌寻宝分享" type:SSDKContentTypeWebPage];

            [LSShareView showInView:LSKeyWindow withItems:[LSShareView shareItems] actionBlock:^(SSDKPlatformType type) {
                //分享出去
                [LSShareView shareTo:type withParams:shareParam onStateChanged:nil];
            }];
            
        }];

    UIView *view = [UIView new];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(contentView);
        make.top.equalTo(shareButton.mas_bottom);
    }];

    UIButton *continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    continueButton.titleLabel.font = SYSTEMFONT(18);
    [continueButton setTitle:@"继续捕抓" forState:UIControlStateNormal];
    [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [view addSubview:continueButton];
    [continueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(view);
    }];

    @weakify(self)[[continueButton rac_signalForControlEvents:UIControlEventTouchUpInside]
        subscribeNext:^(__kindof UIControl *_Nullable x) {
            @strongify(self)
                UIViewController *destVC;
            for (UIViewController *vc in self.navigationController.childViewControllers) {
                if ([vc isKindOfClass:NSClassFromString(@"LSFuwaShowViewController")]) {
                    destVC = vc;
                    break;
                }
            }
            [self.navigationController popToViewController:destVC animated:YES];
        }];
    
    
    LSFuwaSuccessFriendView * friendView = [LSFuwaSuccessFriendView SuccessFriendView];
    self.friendView = friendView;
    friendView.model = self.model;
    [self.view addSubview:friendView];
    
    [friendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    
    [friendView setPlayClick:^(NSString *urlStr, NSString *picUrl) {
        
        NSURL * playURL = [NSURL URLWithString:urlStr];
        UIImage *image = [[YYImageCache sharedCache] getImageForKey:@""];
        
        UIViewController * vc = [NSClassFromString(@"LSVideoPlayerViewController") new];
        [vc setValue:playURL forKey:@"playURL"];
        [vc setValue:image forKey:@"coverImage"];
        [self presentViewController:vc animated:YES completion:nil];
    }];
    
}

-(void)setModel:(LSFuwaModel *)model{
    _model = model;
    self.friendView.model = self.model;

}

@end
