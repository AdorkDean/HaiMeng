//
//  LSVideoPlayerViewController.m
//  LittleSix
//
//  Created by GMAR on 2017/6/23.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSVideoPlayerViewController.h"
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "LSRecomendModel.h"
#import "UIView+HUD.h"
#import "HttpManager.h"
#import "ComfirmView.h"
#import "ZHPlayer.h"
#import "LSFuwaShowViewController.h"
#import "LSShareView.h"

#define kAnimationDuration 0.25

@interface LSVideoPlayerViewController ()

@property (nonatomic,strong) UIImageView *coverView;
@property (nonatomic,strong) UIButton *playOrPauseButton;
@property (nonatomic,strong) ZHPlayer *player;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (strong, nonatomic)  UISlider *sliderBar;
@property (strong, nonatomic)  UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIView *bottomPannel;
@property (weak, nonatomic) IBOutlet UIView *topPannel;
@property (nonatomic,assign) BOOL showMenusView;
@property (nonatomic,copy) NSString * fileViode;
@property (nonatomic,strong) UIButton *playPauseButton;
@property (nonatomic,strong) UIButton *backButton;
@property (nonatomic,copy) NSString * nowProgressStr;

@end

@implementation LSVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.fd_prefersNavigationBarHidden = YES;
    self.fileViode = @"";
    
    [self buildSubviews];
    [self hideSubviews];
    [self registNotis];
    
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
    
    
    self.bottomPannel.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"video_mn_downmodel"].CGImage);
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"video_close"] forState:UIControlStateNormal];
    self.backButton = backButton;
    @weakify(self)
    [[backButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        //取消刷新播放时间
        self.showMenusView = NO;
        !self.player?:[self.player shutdown];
        
        [self hideSubviews];
        [self dismissViewControllerAnimated:YES completion:nil];
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
    [self.indicatorView startAnimating];
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
    self.playOrPauseButton.hidden = YES;
    [self.view addSubview:playOrPauseButton];
    [playOrPauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    
    [[playOrPauseButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        
        
        [self initPlayerWithURL:self.playURL];
        
    }];
    
    UIView * bottomPannel = [UIView new];
    self.bottomPannel = bottomPannel;
    [self.view addSubview:bottomPannel];
    [bottomPannel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.height.mas_equalTo(50);
            
    }];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [doneButton setImage:[UIImage imageNamed:@"video_start"] forState:UIControlStateNormal];
    [doneButton setImage:[UIImage imageNamed:@"video_stop"] forState:UIControlStateSelected];
    
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.playPauseButton = doneButton;
    [bottomPannel addSubview:doneButton];
    [doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(bottomPannel);
        make.left.equalTo(bottomPannel);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(50);
    }];
    
    [[doneButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        //暂停播放
        BOOL isPlaying = self.player.playbackState == MediaPlaybackStatePlaying;
        self.playPauseButton.selected = isPlaying;
        isPlaying ? [self.player pause] : [self.player play];
            
        [self.indicatorView stopAnimating];
        self.indicatorView.hidden = YES;
            
    }];
    
    UILabel * timeLabel = [UILabel new];
    
    timeLabel.font = [UIFont boldSystemFontOfSize:13];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    [bottomPannel addSubview:timeLabel];
    self.timeLabel = timeLabel;
    timeLabel.text = @"--:--:--";
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(bottomPannel);
        make.right.equalTo(bottomPannel);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(80);
    }];
    
    // 滑动条slider
    UISlider *slider = [UISlider new];
    slider.minimumValue = 0;// 设置最小值
    slider.maximumValue = 1;// 设置最大值
    slider.value = 0;
    slider.continuous = YES;// 设置可连续变化
    self.sliderBar = slider;
    slider.minimumTrackTintColor = [UIColor orangeColor];
    [self.sliderBar setThumbImage:[UIImage imageNamed:@"video_white-circle"] forState:UIControlStateNormal];
    [bottomPannel addSubview:slider];
    
    [slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(bottomPannel);
        make.left.equalTo(doneButton.mas_right);
        make.right.equalTo(timeLabel.mas_left);
        make.height.mas_equalTo(50);
    }];
    
    UILongPressGestureRecognizer * videoTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(videoClick:)];
    [self.view addGestureRecognizer:videoTap];
}

- (void)videoClick:(UILongPressGestureRecognizer *) gesture  {
    
    if (gesture.state == UIGestureRecognizerStateBegan){
        
        ModelComfirm *item1 = [ModelComfirm comfirmModelWith:@"保存视频" titleColor:HEXRGB(0x666666) fontSize:16];
        ModelComfirm *item2 = [ModelComfirm comfirmModelWith:@"分享视频" titleColor:HEXRGB(0x666666) fontSize:16];
        
        ModelComfirm *cancelItem = [ModelComfirm comfirmModelWith:@"取消" titleColor:[UIColor redColor] fontSize:16];
        
        //在窗口显示
        [ComfirmView
         showInView:[UIApplication sharedApplication].keyWindow
         cancelItemWith:cancelItem
         dataSource:@[item1,item2]
         actionBlock:^(ComfirmView *view, NSInteger index) {
             
             if (index == 1) {
                 NSLog(@"分享视频");
                 [self shareAction];
                 
             }else {
                 
                 [self downloadTheVideo:self.playURL];
             }
             
         }];
    }
}

- (void)shareAction {
    
    NSURL *shareURL = self.playURL;
    
    if (!shareURL) return;
    
    NSString *shareTitle;
    if (!self.title || self.title.length == 0) {
        shareTitle = [NSString stringWithFormat:@"来自%@的分享-嗨萌视频",ShareAppManager.loginUser.user_name];
    }
    else {
        shareTitle = self.title;
    }
    
    NSMutableDictionary *shareParam = [NSMutableDictionary dictionary];
    
    NSString * logoImage = ShareAppManager.loginUser.avatar;
    [shareParam SSDKSetupShareParamsByText:@"这里有你喜爱的AR寻宝和海量嗨萌视频，你意想不带的事情正在发生，赶快来玩吧~~" images:@[logoImage] url:shareURL title:shareTitle type:SSDKContentTypeWebPage];
    
    [LSShareView showInView:LSKeyWindow withItems:[LSShareView shareItems] actionBlock:^(SSDKPlatformType type) {
        //分享出去
        [LSShareView shareTo:type withParams:shareParam onStateChanged:nil];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        if (!self.showMenusView) {
            [self showSubviews];
            [self refreshMediaControl];
        }
        else {
            [self hideSubviews];
        }
        
    }];
}

- (void)hideSubviews {
    self.topPannel.hidden = YES;
    self.bottomPannel.hidden = YES;
    self.showMenusView = NO;
    self.backButton.hidden = YES;
}

- (void)showSubviews {
    self.topPannel.hidden = NO;
    self.bottomPannel.hidden = NO;
    self.showMenusView = YES;
    self.backButton.hidden = NO;
}

- (void)refreshMediaControl {
    //     duration
    NSTimeInterval intDuration = self.player.duration + 0.5;
    
    // position
    NSTimeInterval intPosition = self.player.currentTime + 0.5;
    
    if (intDuration > 0) {
        self.sliderBar.maximumValue = intDuration;
        NSInteger delta = intDuration-intPosition;
        self.timeLabel.text = [NSString stringWithFormat:@"-%02d:%02d:%02d", (int)(delta / 3600), (int)(delta / 60), (int)(delta % 60)];
    } else {
        self.timeLabel.text = @"--:--:--";
        self.sliderBar.maximumValue = 1.0f;
    }
    
    if (intDuration > 0) {
        self.sliderBar.value = intPosition;
    } else {
        self.sliderBar.value = 0.0f;
    }
    
    BOOL isPlaying = self.player.playbackState == MediaPlaybackStatePlaying;
    self.playPauseButton.selected = isPlaying;
    
    if (!self.showMenusView) return;
    
    [self performSelector:@selector(refreshMediaControl) withObject:nil afterDelay:0.5];
}

- (void)initPlayerWithURL:(NSURL *)url {
    
    if (self.player) {
        [self.player.view removeFromSuperview];
        [self.player shutdown];
    }
    
    ZHPlayer *player = [ZHPlayer new];
    self.player = player;
    player.view.frame = LSKeyWindow.bounds;
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
        [self toOrientationsPortrait:UIInterfaceOrientationPortrait];
        self.playOrPauseButton.hidden = NO;
        self.indicatorView.hidden = YES;
        
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
                
                [self toFullScreenWithInterfaceOrientation:interfaceOrientation];
            }
                break;
            case UIInterfaceOrientationLandscapeRight:{
                NSLog(@"电池栏在右");
                
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
    
    [self setNeedsStatusBarAppearanceUpdate];
    
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
    
    self.view.transform = CGAffineTransformIdentity;
    self.player.view.transform = CGAffineTransformIdentity;
    self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self.player.view.frame =  CGRectMake(0,0, kScreenWidth,kScreenHeight);
}

- (void)setCoverImage:(UIImage *)coverImage {
    
    _coverImage = coverImage;
    
    self.coverView.image = self.coverImage;
}

- (void)setPlayURL:(NSURL *)playURL {
    _playURL = playURL;
    
    
    [self initPlayerWithURL:playURL];
    
}

- (void)downloadTheVideo:(NSURL *)playUrl {
    
    //先看有没有保存，有保存就不用保存了
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *localFilePath = [defaults objectForKey:[NSString stringWithFormat:@"%@isLocal",self.playURL.absoluteString]];
    if (localFilePath){
        [LSKeyWindow showError:@"视频已存在" hideAfterDelay:1.5];
        return;
    }
    
    self.nowProgressStr =[NSString stringWithFormat:@"%.2f%%",0.00];
    LFUITips *tips = [LFUITips showLoading:@"正在下载...." inView:LSKeyWindow];
    [LSKeyWindow addSubview:tips];
    [HttpManager downloadViode:playUrl downloadProgress:^(NSProgress *progress) {
        
        self.nowProgressStr = [NSString stringWithFormat:@"%.2f%%",(CGFloat)progress.completedUnitCount/progress.totalUnitCount*100.00];
        NSLog(@"%@",self.nowProgressStr);
        kDISPATCH_MAIN_THREAD(^{
            tips.detailsLabel.text = self.nowProgressStr;
        });
        
    } completeHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSString* path = filePath.absoluteString;
        self.fileViode = path;
        [tips showSucceed:@"下载完成" hideAfterDelay:1];
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        if ([self.fileViode isEqualToString:@""]) {
            
            [LSKeyWindow showError:@"视频还没缓存完成" hideAfterDelay:1.5];
            return;
        }
        
        [library writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:self.fileViode] completionBlock:^(NSURL *assetURL, NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 if (error) {
                     [LSKeyWindow showError:@"视频保存失败" hideAfterDelay:2.0];
                     
                 } else {
                     //保存到本地
                     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                     [defaults setObject:self.playURL.absoluteString forKey:[NSString stringWithFormat:@"%@isLocal",self.playURL.absoluteString]];
                     [defaults synchronize];
                     [LSKeyWindow showSucceed:@"视频保存成功" hideAfterDelay:2.0];
                 }
             });
         }];
    }];
}

@end

