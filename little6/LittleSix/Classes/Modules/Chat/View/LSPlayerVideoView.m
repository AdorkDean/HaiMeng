//
//  LSPlayerVideoView.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/8.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSPlayerVideoView.h"
#import "ZHPlayer.h"
#import "HttpManager.h"
#import "ComfirmView.h"
#import "LSCircleView.h"
#import "UIView+HUD.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface LSPlayerVideoView ()

@property (nonatomic,strong) UIView *referenceView;

@property (weak, nonatomic) IBOutlet UIImageView *coverView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UIView *bottomPannel;
@property (weak, nonatomic) IBOutlet UIView *topPannel;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *sliderBar;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *playCenterButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@property (nonatomic,strong) NSURL *playURL;

@property (nonatomic,strong) ZHPlayer *player;

@property (nonatomic,assign) BOOL showMenusView;

@property (nonatomic,copy) NSString * fileViode;
@property (nonatomic,strong) LSCircleView * circleView;
@end

@implementation LSPlayerVideoView

+ (instancetype)showFromView:(UIView *)view withModel:(LSVideoMessageModel *)model {
    
    CGRect frame = [view convertRect:view.bounds toViewOrWindow:LSKeyWindow];
    
    LSPlayerVideoView *playerView = [LSPlayerVideoView playerVideoView];
    playerView.frame = frame;
    playerView.referenceView = view;
    playerView.model = model;
    [LSKeyWindow addSubview:playerView];
    
    [playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(LSKeyWindow);
    }];
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        playerView.frame = LSKeyWindow.bounds;
    } completion:^(BOOL finished) {
        [playerView layoutIfNeeded];
    }];
    
    return playerView;
}

+ (instancetype)showFromView:(UIView *)view withCoverImage:(UIImage *)coverImage playURL:(NSURL *)playURL {
    
    CGRect frame = [view convertRect:view.bounds toViewOrWindow:LSKeyWindow];
    
    LSPlayerVideoView *playerView = [LSPlayerVideoView playerVideoView];
    playerView.coverView.image = coverImage;
    playerView.frame = frame;
    playerView.referenceView = view;
    [LSKeyWindow addSubview:playerView];
    
    [playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(LSKeyWindow);
    }];
    
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        playerView.frame = LSKeyWindow.bounds;
    } completion:^(BOOL finished) {
        [playerView layoutIfNeeded];
        playerView.playURL = playURL;
    }];
    
    return playerView;
}

+ (instancetype)playerVideoView {
    return [[[NSBundle mainBundle] loadNibNamed:@"LSPlayerVideoView" owner:nil options:nil]lastObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.sliderBar setThumbImage:[UIImage imageNamed:@"video_white-circle"] forState:UIControlStateNormal];
    self.playCenterButton.hidden = YES;
    self.bottomPannel.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"video_mn_downmodel"].CGImage);
    self.topPannel.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"video_mn_upmodel"].CGImage);
    [self hideSubviews];
    [self registNotis];
    
    
    
    UILongPressGestureRecognizer * videoTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(videoClick:)];
    [self addGestureRecognizer:videoTap];
}

- (void)videoClick:(UILongPressGestureRecognizer *) gesture  {

    if (gesture.state == UIGestureRecognizerStateBegan){
    
        ModelComfirm *item1 = [ModelComfirm comfirmModelWith:@"保存视频" titleColor:HEXRGB(0x666666) fontSize:16];
        
        ModelComfirm *cancelItem = [ModelComfirm comfirmModelWith:@"取消" titleColor:[UIColor redColor] fontSize:16];
        
        //在窗口显示
        [ComfirmView
         showInView:[UIApplication sharedApplication].keyWindow
         cancelItemWith:cancelItem
         dataSource:@[ item1]
         actionBlock:^(ComfirmView *view, NSInteger index) {
             
             ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
             //先看有没有保存，有保存就不用保存了
             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
             NSString *localFilePath = [defaults objectForKey:[NSString stringWithFormat:@"%@isLocal",self.playURL.absoluteString]];
             
             if (!localFilePath){
             
                 [library writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:self.fileViode] completionBlock:^(NSURL *assetURL, NSError *error)
                  {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          
                          if (error) {
                              
                              [self showAlert:@"视频保存失败"];
                              
                          } else {
                              //保存到本地
                              NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                              [defaults setObject:self.playURL.absoluteString forKey:[NSString stringWithFormat:@"%@isLocal",self.playURL.absoluteString]];
                              [defaults synchronize];
                              [self showAlert:@"视频保存成功"];
                          }
                      });
                  }];
             }else{
                 [self showAlert:@"视频已存在"];
             }
         }];
    }
}

- (void)showAlert:(NSString *)title {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)hideSubviews {
    self.topPannel.hidden = YES;
    self.bottomPannel.hidden = YES;
    self.showMenusView = NO;
    
}

- (void)showSubviews {
    self.topPannel.hidden = NO;
    self.bottomPannel.hidden = NO;
    self.showMenusView = YES;
}

- (void)initPlayerWithURL:(NSURL *)url {
    
    if (self.player) {
        [self.player shutdown];
    }
    
    ZHPlayer *player = [ZHPlayer new];
    self.player = player;
    player.view.frame = self.bounds;
    player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    player.shouldAutoplay = YES;
    [player initPlayerWith:url];
    [self insertSubview:player.view aboveSubview:self.coverView];
}

- (void)registNotis {
    
    @weakify(self)
    //播放结束通知
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:MediaPlayerPlaybackDidFinishNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        self.playCenterButton.hidden = NO;
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:MediaPlayerPlaybackStatusDidChangeNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        self.playCenterButton.hidden = YES;
        if (self.player.playbackState != MediaPlaybackStateSeeking) {
            self.indicatorView.hidden = YES;
        }
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:MediaPlayerLoadStateDidChangeNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        BOOL isBuffComplete = self.player.loadState == MediaLoadStatePlaythroughOK;
        self.indicatorView.hidden = isBuffComplete;
    }];
    
}

//横屏播放
-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation{
    
    
    if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
        
    }else{
        self.transform = CGAffineTransformMakeRotation(-M_PI_2);
        
    }
    self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self.player.view.frame =  CGRectMake(0,0, kScreenHeight,kScreenWidth);
    [self.playCenterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.coverView);
    }];
}

//竖屏播放
- (void)toOrientationsPortrait:(UIInterfaceOrientation)orientation {
    
    self.transform = CGAffineTransformIdentity;
//    self.player.view.transform = CGAffineTransformIdentity;
    self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    self.player.view.frame =  CGRectMake(0,0, kScreenWidth,kScreenHeight);
    [self.playCenterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.coverView);
    }];
}

- (void)toOrientation:(UIInterfaceOrientation)orientation {
    // 获取到当前状态条的方向
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    // 判断如果当前方向和要旋转的方向一致,那么不做任何操作
    if (currentOrientation == orientation) { return; }
    
    // 也就是说在实现这个方法的时候-(BOOL)shouldAutorotate返回值要为NO
    [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:NO];
    
    // 获取旋转状态条需要的时间:
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    // 更改了状态条的方向,但是设备方向UIInterfaceOrientation还是正方向的,这就要设置给你播放视频的视图的方向设置旋转
    // 给你的播放视频的view视图设置旋转
    LSKeyWindow.transform = CGAffineTransformIdentity;
    LSKeyWindow.transform = [self getTransformRotationAngle];
    // 开始旋转
    [UIView commitAnimations];
    
}

- (CGAffineTransform)getTransformRotationAngle {
    // 状态条的方向已经设置过,所以这个就是你想要旋转的方向
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    // 根据要进行旋转的方向来计算旋转的角度
    if (orientation == UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    } else if (orientation == UIInterfaceOrientationLandscapeLeft){
        return CGAffineTransformMakeRotation(-M_PI_2);
    } else if(orientation == UIInterfaceOrientationLandscapeRight){
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}

#pragma mark - Action
- (IBAction)closeButtonAction:(id)sender {
    //取消刷新播放时间
    self.showMenusView = NO;
    !self.player?:[self.player shutdown];
    
    [self dismiss];
}

- (IBAction)playButtonAction:(id)sender {
    
    BOOL isPlaying = self.player.playbackState == MediaPlaybackStatePlaying;
    
    isPlaying ? [self.player pause] : [self.player play];
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

- (IBAction)playCenterButtonAction:(id)sender {
    self.playURL = self.playURL;
}

- (void)dismiss {
    
    CGRect frame = [self.referenceView convertRect:self.referenceView.bounds toViewOrWindow:LSKeyWindow];
    
    [self hideSubviews];
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.frame = frame;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
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
    self.playButton.selected = isPlaying;
    
    if (!self.showMenusView) return;
    
    [self performSelector:@selector(refreshMediaControl) withObject:nil afterDelay:0.5];
}

#pragma mark - Getter & Setter 
- (void)setModel:(LSVideoMessageModel *)model {
    _model = model;
    
    if (model.fromMe&&!model.isForward) {
        self.coverView.image = [model thumImage];
        //开始播放
        NSString *filePath = [model localVideoFilePath];
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        self.playURL = fileURL;
    }
    else {
        [self.coverView setImageWithURL:[NSURL URLWithString:model.remoteThumURL] placeholder:nil];
        self.playURL = [NSURL URLWithString:model.remoteVideoURL];
        
    }
}

- (void)setPlayURL:(NSURL *)playURL {
    _playURL = playURL;
    
    //先看本地有没有缓存，有就直接播放，没有就下载
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *firstPath = [defaults objectForKey:playURL.absoluteString];
    
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:firstPath];
    
    if (isFileExist) {
        self.fileViode = firstPath;
        [self initPlayerWithURL:[NSURL URLWithString:firstPath]];
    }
    else {
        [self downloadTheVideo:playURL];
    }
}

- (void)downloadTheVideo:(NSURL *)playUrl {

    [HttpManager downloadViode:playUrl downloadProgress:^(NSProgress *progress) {
        
        CGFloat ratio = (float)progress.completedUnitCount/progress.totalUnitCount;
        NSLog(@"progress  = %f",ratio);
        
    } completeHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSString* path = filePath.absoluteString;
        self.fileViode = path;
        [self initPlayerWithURL:filePath];
        //保存到沙盒
        kDISPATCH_GLOBAL_QUEUE_DEFAULT(^{
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:filePath.absoluteString forKey:playUrl.absoluteString];
            [defaults synchronize];
        })
    }];
}

@end
