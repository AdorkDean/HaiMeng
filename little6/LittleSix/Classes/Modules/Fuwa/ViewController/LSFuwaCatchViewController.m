//
//  LSFuwaCatchViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/15.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaCatchViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "LSFuwaModel.h"
#import "UIView+HUD.h"
#import "LSFuwaSimilarity.h"
#import "LSFuwaImageCompare.h"

@interface LSFuwaCatchViewController ()

@property (nonatomic, assign, getter=isRequesting) BOOL requesting;
@property (nonatomic, strong) UIImageView * tipsImageView;

@property (nonatomic, assign) NSInteger captureCount;
@property (nonatomic, assign) NSInteger cutCount;

@property (nonatomic, assign) BOOL isCancel;
@property (nonatomic, strong) UIView *scanLine;
@property (nonatomic, strong) UIView *scanView;

@property (nonatomic, strong) UILabel *remindLabel;

@end

@implementation LSFuwaCatchViewController

- (void)installNoti {
    
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationWillEnterForegroundNotification object:nil] subscribeNext:^(id x) {
        @strongify(self)
        [self startScanAnimation];
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"抓福娃";
    self.fd_interactivePopDisabled = YES;
    [self configSubviews];
    [self configFocusBlock];
    [self startScanAnimation];
    [self installNoti];
}

- (void)startScanAnimation {
    
    [self.scanLine.layer removeAllAnimations];
    
    [self.scanLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.scanView.mas_top).offset(-10);
    }];
    [self.scanView layoutIfNeeded];
    
    CGFloat offset = HEIGHT(self.scanView) + 20;
    
    [UIView animateWithDuration:1.5 animations:^{
        
        [UIView setAnimationRepeatCount:CGFLOAT_MAX];
        
        [self.scanLine mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.scanView.mas_top).offset(offset);
        }];
        
        [self.scanView layoutIfNeeded];
    }];
}


- (void)configSubviews {
    
    UIView *scanView = [UIView new];
    self.scanView = scanView;
    scanView.clipsToBounds = YES;
    scanView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scanView];
    
    [scanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.cycleView);
    }];
    
    
    UIImageView *scanLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qrcode_scanLine"]];
    self.scanLine = scanLine;
    scanLine.contentMode = UIViewContentModeScaleToFill;
    [scanView addSubview:scanLine];
    [scanLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(scanView).offset(8);
        make.right.equalTo(scanView).offset(-8);
        make.height.offset(8);
        make.bottom.equalTo(scanView.mas_top).offset(-10);
    }];
    
    
    self.view.backgroundColor = [UIColor blackColor];
    self.isCancel = YES;
    UILabel *tipsLabel = [UILabel new];
    tipsLabel.text = @"按住看线索";
    tipsLabel.font = SYSTEMFONT(14);
    tipsLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-20);
    }];
    
    UIButton *touchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [touchButton setImage:[UIImage imageNamed:@"fuwa_clue"] forState:UIControlStateNormal];
    [self.view addSubview:touchButton];
    [touchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(tipsLabel.mas_top).offset(-23);
    }];
    
    UIView *tipsView = [UIView new];
    tipsView.hidden = YES;
    ViewRadius(tipsView, 2);
    tipsView.backgroundColor = HEXRGB(0x333333);
    [self.view addSubview:tipsView];
    [tipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(touchButton.mas_top).offset(-4);
        make.width.offset(180);
        make.height.offset(250);
    }];
    
    UILabel *headLabel = [UILabel new];
    headLabel.text = @"福娃藏在这";
    headLabel.font = SYSTEMFONT(14);
    headLabel.textColor = [UIColor whiteColor];
    headLabel.textAlignment = NSTextAlignmentCenter;
    [tipsView addSubview:headLabel];
    [headLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(tipsView);
        make.height.offset(36);
    }];
    
    UIImageView *tipsImageView = [UIImageView new];
    tipsImageView.clipsToBounds = YES;
    tipsImageView.contentMode = UIViewContentModeScaleAspectFill;
    [tipsImageView setImageURL:[NSURL URLWithString:self.model.pic]];
    self.tipsImageView = tipsImageView;
    [tipsView addSubview:tipsImageView];
    [tipsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(tipsView).offset(5);
        make.right.equalTo(tipsView).offset(-5);
        make.top.equalTo(headLabel.mas_bottom);
        make.height.offset(170);
    }];
    
    UIImageView *coverView = [UIImageView new];
    coverView.image = [UIImage imageNamed:@"fuwa_thread"];
    [tipsView addSubview:coverView];
    [coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(tipsImageView);
    }];
    
    UIButton *placeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    placeButton.titleLabel.font = SYSTEMFONT(14);
    [placeButton setImage:[UIImage imageNamed:@"fuwa_position_bz"] forState:UIControlStateNormal];
    [placeButton setTitle:self.model.pos forState:UIControlStateNormal];
    [placeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    [placeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [tipsView addSubview:placeButton];
    [placeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(tipsView);
        make.top.equalTo(coverView.mas_bottom);
    }];
    
    [[touchButton rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(__kindof UIControl *_Nullable x) {
        tipsView.hidden = NO;
    }];
    [[touchButton rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(__kindof UIControl *_Nullable x) {
         tipsView.hidden = YES;
     }];
    [[touchButton rac_signalForControlEvents:UIControlEventTouchUpOutside]
     subscribeNext:^(__kindof UIControl *_Nullable x) {
         tipsView.hidden = YES;
     }];
    [[touchButton rac_signalForControlEvents:UIControlEventTouchCancel]
     subscribeNext:^(__kindof UIControl *_Nullable x) {
         tipsView.hidden = YES;
     }];
    
    [self.view layoutIfNeeded];
}

- (void)configFocusBlock {
    
    self.captureCount = 0;
    self.cutCount = 0;

    @weakify(self)[self setFocusCompleteBlock:^{
        @strongify(self) NSLog(@"对焦完成");
        [self startCapture];
    }];
}

//开始捕获福娃
- (void)startCapture {
    
    if (self.isRequesting) return;
    
    [self captureComplete:^(UIImage *image, NSError *error) {
        
        if (error) return;
        
        self.captureCount ++;
        self.cutCount ++;
        NSLog(@"%ld",self.captureCount);
        if (self.captureCount > 5) {
            
            [LSKeyWindow showError:@"亲，换个角度试试吧~" hideAfterDelay:1.0];
            self.captureCount = 0;
            self.requesting = NO;
            
        }else {
            
            
            BOOL flag= [LSFuwaImageCompare isImage:image likeImage:self.tipsImageView.image];
            
            if (flag) {
                
                self.isCancel = NO;
                
                [LSFuwaModel catchFuwaWithGid:self.model.gid success:^(LSFuwaModel *model) {
                    
                    if (model.code == 0) {
                        !self.catchSuccessBlock ?: self.catchSuccessBlock();
                        [self showSuccessAnimation:image];
                    }else {
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kFuwaCatchInfoNoti object:model.message];
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    
                } failure:^(NSError *error) {
                    
                    self.isCancel = YES;
                    self.requesting = NO;
                }];
            }else {
                
                self.requesting = NO;
            }
        }
        
    }];
    
    self.requesting = YES;
}

- (void)showSuccessAnimation:(UIImage *)cluesImage {
    
    
    NSMutableArray *paths = [NSMutableArray array];
    for (int i = 1; i < 8; i++) {
        NSString *fileName = [NSString stringWithFormat:@"fuwagif_%1d", i];
        NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@".png"];
        [paths addObject:path];
    }
    
    UIImage *image = [[YYFrameImage alloc] initWithImagePaths:paths oneFrameDuration:0.2 loopCount:1];
    YYAnimatedImageView *animationView = [[YYAnimatedImageView alloc] initWithImage:image];
    
    @weakify(self)
    [[[RACObserve(animationView, currentIsPlayingAnimation) skip:1] throttle:0.2] subscribeNext:^(NSNumber *x) {
        if (x.intValue) return;
        [animationView removeFromSuperview];
        @strongify(self)
        //动画完成跳转到分享页面
        UIViewController *vc = [NSClassFromString(@"LSFuwaCatchSuccessViewController") new];
        [vc setValue:cluesImage forKey:@"cluesImage"];
        [vc setValue:self.model forKey:@"model"];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    animationView.frame = LSKeyWindow.bounds;
    [self.navigationController.view addSubview:animationView];
}

/**
 * 协议中的方法，获取返回按钮的点击事件
 */
- (BOOL)navigationShouldPopOnBackButton{
    
    return self.isCancel;
}

@end

