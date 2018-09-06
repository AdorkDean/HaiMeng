//
//  LSVideoPlayViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/6/2.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSVideoPlayViewController.h"
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#import "LSRecomendModel.h"
#import "LSIndexLinkInModel.h"
#import "UIView+HUD.h"
#import "ZHPlayer.h"
#import "LSFuwaShowViewController.h"

@interface LSVideoPlayViewController ()

@property (nonatomic,strong) UIImageView *coverView;
@property (nonatomic,strong) UIButton *playOrPauseButton;
@property (nonatomic,strong) ZHPlayer *player;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property (nonatomic,strong) UILabel *titleLabel;

@end

@implementation LSVideoPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.fd_prefersNavigationBarHidden = YES;
    
    if (self.type == LSRecomendTypeMeng) {
        self.classId = @"i";
    }
    
    [self buildSubviews];
    
    [self registNotis];

    [self setVideoModel:self.videoModel];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.player shutdown];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    //隐藏=YES,显示=NO; Animation:动画效果
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

//退出时显示
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //隐藏=YES,显示=NO; Animation:动画效果
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)buildSubviews {
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"navbar_btn_back"] forState:UIControlStateNormal];
    
    @weakify(self)
    [[backButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [self.view addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(50);
        make.left.mas_equalTo(8);
        make.top.mas_equalTo(15);
    }];
    
    UILabel *titleLabel = [UILabel new];
    self.titleLabel = titleLabel;
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.mas_lessThanOrEqualTo(kScreenWidth-150);
        make.centerY.equalTo(backButton);
    }];
    
    UIImageView *coverView = [UIImageView new];
    self.coverView = coverView;
    coverView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view insertSubview:coverView atIndex:0];
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.indicatorView sizeToFit];
    self.indicatorView.hidesWhenStopped = YES;
    self.indicatorView.hidden = YES;
    
    //设置显示位置
    [self.view addSubview:self.indicatorView];
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(@(40));
        make.height.equalTo(@(40));
    }];
    
    UIButton *playOrPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playOrPauseButton = playOrPauseButton;
    [playOrPauseButton setImage:[UIImage imageNamed:@"recommend-play"] forState:UIControlStateNormal];
    [playOrPauseButton setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
    
    [self.view addSubview:playOrPauseButton];
    [playOrPauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    
    [[playOrPauseButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        [self initPlayerWithURL:[NSURL URLWithString:self.videoModel.video]];
    }];
    
    UIButton *tribalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    ViewBorderRadius(tribalButton, 4, 1, [UIColor whiteColor]);
    tribalButton.titleLabel.font = [UIFont systemFontOfSize:12];
    
    [tribalButton setTitle:@"查看部落" forState:UIControlStateNormal];
    [tribalButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    tribalButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    
    [self.view addSubview:tribalButton];
    [tribalButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-30);
        make.right.equalTo(self.view).offset(-15);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(75);
    }];
    
    [[tribalButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        
        [LSIndexLinkInModel indexLinkWithTribalCreateId:self.videoModel.userid success:^(NSArray *list) {
            if (list.count > 0) {
        
                LSIndexLinkInModel * model = list[0];
                UIViewController *vc = [NSClassFromString(@"LSClanCofcViewController") new];
                [vc setValue:@(model.stribe_id) forKey:@"sh_id"];
                [vc setValue:@(5) forKey:@"type"];
                [vc setValue:model.name forKey:@"titleStr"];
                [vc  setValue:@"isFuwa" forKey:@"isFuwa"];
                [self.navigationController pushViewController:vc animated:YES];
            }else {
                [self.view showAlertWithTitle:@"提示" message:@"该用户没有部落"];
            }
        } failure:^(NSError *error) {
            [LSKeyWindow showError:@"该用户没有部落" hideAfterDelay:1.5];
        }];
    }];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    ViewBorderRadius(doneButton, 4, 1, [UIColor whiteColor]);
    doneButton.titleLabel.font = [UIFont systemFontOfSize:12];
    NSString *title = (self.type == LSRecomendTypeFuwa) ? @"带我去寻宝" : @"查找萌友";
    [doneButton setTitle:title forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    doneButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    
    [self.view addSubview:doneButton];
    [doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.centerY.equalTo(tribalButton);
        make.right.equalTo(tribalButton.mas_left).offset(-10);
        make.width.mas_equalTo(75);
    }];
    
    [[doneButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        //暂停播放
        [self.player shutdown];
        self.playOrPauseButton.hidden = NO;
        [self.indicatorView stopAnimating];
        self.indicatorView.hidden = YES;
        
        LSFuwaShowViewController * vc = [LSFuwaShowViewController new];
        vc.type =(self.type == LSRecomendTypeFuwa) ?FuwaShowTypeBusiness:FuwaShowTypePartner;
        vc.isMerchant = YES;
        [self.navigationController pushViewController:vc animated:YES];
        vc.MerchantRadius = self.videoModel.distance;
        vc.MerchantID = self.videoModel.userid;
    }];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    ViewBorderRadius(nextButton, 4, 1, [UIColor whiteColor]);
    nextButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [nextButton setTitle:@"下一个" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    
    [self.view addSubview:nextButton];
    [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.centerY.equalTo(doneButton);
        make.right.equalTo(doneButton.mas_left).offset(-10);
        make.width.mas_equalTo(50);
    }];
    
    [[nextButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        
        [self.player.view removeFromSuperview];
        [self.player shutdown];
        
        self.playOrPauseButton.hidden = NO;
        
        if (self.dataSource.count==0) return;
        
        NSInteger idx = [self.dataSource indexOfObject:self.videoModel];
        idx = (idx == self.dataSource.count-1) ? 0 : ++idx;
        
        LSRecomendModel *nextModel = self.dataSource[idx];
        self.videoModel = nextModel;
    }];
    
}

- (void)initPlayerWithURL:(NSURL *)url {
    
    if (self.player) {
        [self.player.view removeFromSuperview];
        [self.player shutdown];
    }
    
    ZHPlayer *player = [ZHPlayer new];
    self.player = player;
    player.view.frame = self.view.bounds;
    player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    player.shouldAutoplay = YES;
    [player initPlayerWith:url];
    [self.view insertSubview:player.view aboveSubview:self.coverView];
}

- (void)registNotis {
    
    @weakify(self)
    //播放结束通知
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:MediaPlayerPlaybackDidFinishNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        self.playOrPauseButton.hidden = NO;
        self.indicatorView.hidden = YES;
        if (!self.videoModel) return;
        //增加播放次数
        [LSRecomendModel increasePlayCount:self.videoModel class:self.classId success:nil failure:nil];
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:MediaPlayerPlaybackStatusDidChangeNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)

        self.playOrPauseButton.hidden = YES;
        if (self.player.loadState == MediaLoadStatePlaythroughOK) {
            self.indicatorView.hidden = YES;
        }else{
            
            self.indicatorView.hidden = NO;
            [self.indicatorView startAnimating];
        }
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:MediaPlayerLoadStateDidChangeNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        BOOL isBuffComplete = self.player.loadState == MediaLoadStatePlaythroughOK;
        self.indicatorView.hidden = isBuffComplete;
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIDeviceOrientationDidChangeNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
        switch (interfaceOrientation) {
            case UIInterfaceOrientationPortraitUpsideDown:{
                NSLog(@"电池栏在下");
            }
                break;
            case UIInterfaceOrientationPortrait:{
                NSLog(@"电池栏在上");
                [self setNeedsStatusBarAppearanceUpdate];
                [self toOrientationsPortrait:interfaceOrientation];
            }
                break;
            case UIInterfaceOrientationLandscapeLeft:{
                NSLog(@"电池栏在左");
                 [self setNeedsStatusBarAppearanceUpdate];
                [self toFullScreenWithInterfaceOrientation:interfaceOrientation];
            }
                break;
            case UIInterfaceOrientationLandscapeRight:{
                NSLog(@"电池栏在右");
                 [self setNeedsStatusBarAppearanceUpdate];
                [self toFullScreenWithInterfaceOrientation:interfaceOrientation];
            }
                break;
            default:
                break;
        }
    }];
}

//横屏播放
-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation{
    
    if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {

        self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
        
    }else{
        
        self.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
        
    }
    self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self.player.view.frame =  CGRectMake(0,0, kScreenHeight,kScreenWidth);
    
    
}

//竖屏播放
- (void)toOrientationsPortrait:(UIInterfaceOrientation)orientation {
    
    self.player.view.transform = CGAffineTransformIdentity;
    self.view.transform = CGAffineTransformIdentity;
    
    self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self.player.view.frame =  CGRectMake(0,0, kScreenWidth,kScreenHeight);
    
}

- (void)setVideoModel:(LSRecomendModel *)videoModel {
    _videoModel = videoModel;
    
    [self.coverView setImageWithURL:[NSURL URLWithString:videoModel.coverImage] placeholder:nil];
    self.titleLabel.text = videoModel.name;
    
    [self initPlayerWithURL:[NSURL URLWithString:self.videoModel.video]];
}

@end
