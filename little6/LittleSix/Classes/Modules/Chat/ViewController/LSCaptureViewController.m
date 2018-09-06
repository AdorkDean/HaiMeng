//
//  LSCaptureViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSCaptureViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+HUD.h"
#import "IDCaptureSessionAssetWriterCoordinator.h"
#import "IDFileManager.h"
#import <Photos/Photos.h>
#import "ZHPlayer.h"
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>

@interface LSCaptureViewController () <IDCaptureSessionCoordinatorDelegate> {
    dispatch_queue_t _recoding_queue;
}

@property (nonatomic,strong) UIImageView *recordBgView;
@property (nonatomic,strong) UIButton *recordButton;
@property (nonatomic,strong) UIButton *closeButton;
@property (nonatomic,strong) UIButton *switchButton;

@property (nonatomic,strong) UIButton *cancelButton;
@property (nonatomic,strong) UIButton *doneButton;

@property (nonatomic,strong) LSFocusView *focusView;

@property (nonatomic,strong) CAShapeLayer *progressLayer;

@property (nonatomic,strong) IDCaptureSessionCoordinator *captureSessionCoordinator;

@property (nonatomic,strong) ZHPlayer *player;

@end

@implementation LSCaptureViewController

- (instancetype)init {
    if ([super init]) {
        self.maxCaptureDuration = 15;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSubViews];
    
    self.fd_prefersNavigationBarHidden = YES;
   
    [self hasAccessAuthority:^(BOOL granted) {
        if (granted) {
            //初始化硬件设备
            [self configureInterface];
        }
    }];
}

- (void)configureInterface {
    _captureSessionCoordinator = [IDCaptureSessionAssetWriterCoordinator new];
    [_captureSessionCoordinator setDelegate:self callbackQueue:dispatch_get_main_queue()];
    //添加预览图层
    AVCaptureVideoPreviewLayer *previewLayer = [_captureSessionCoordinator previewLayer];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    [self.view.layer insertSublayer:previewLayer atIndex:0];
    
    [_captureSessionCoordinator startRunning];
}

- (void)initSubViews {
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"capture_shoot_bg"].CGImage);
    
//    UIButton *switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.switchButton = switchButton;
//    [switchButton setImage:[UIImage imageNamed:@"capture_shoot_convert"] forState:UIControlStateNormal];
//    [switchButton addTarget:self action:@selector(swapCameraAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:switchButton];
//    [switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.view).offset(-25);
//        make.top.equalTo(self.view).offset(40);
//    }];
    
    UIImageView *recBgView = [UIImageView new];
    self.recordBgView = recBgView;
    recBgView.image = [UIImage imageNamed:@"capture_shoot_whitebtn"];
    [self.view addSubview:recBgView];
    [recBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view.mas_bottom).offset(-150);
        make.centerX.equalTo(self.view);
    }];
    
    UIButton *recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.recordButton = recordButton;
    [recordButton setImage:[UIImage imageNamed:@"capture_shoot_btnbg"] forState:UIControlStateNormal];
    [recordButton setAdjustsImageWhenHighlighted:NO];
    [recordButton addTarget:self action:@selector(recordButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [recordButton addTarget:self action:@selector(recordButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    [recordButton addTarget:self action:@selector(recordButtonTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    [self.view addSubview:recordButton];
    [recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(recBgView);
    }];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton = closeButton;
    [closeButton setImage:[UIImage imageNamed:@"capture_shoot_cancel"] forState:UIControlStateNormal];
    [closeButton setImage:[UIImage imageNamed:@"capture_shoot_cancel"] forState:UIControlStateHighlighted];
    [closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_left).offset((kScreenWidth*0.5-33.5)*0.5);
        make.centerY.equalTo(recBgView);
    }];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton = cancelButton;
    [cancelButton setImage:[UIImage imageNamed:@"capture_shoot_back"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(recordButton);
    }];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.doneButton = doneButton;
    [doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setImage:[UIImage imageNamed:@"capture_shoot_confirm"] forState:UIControlStateNormal];
    [self.view addSubview:doneButton];
    [doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(recordButton);
    }];
    
    cancelButton.hidden = YES;
    doneButton.hidden = YES;
    
    LSFocusView *focusView = [[LSFocusView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    focusView.center = self.view.center;
    self.focusView = focusView;
}

#pragma mark - Actin 
- (void)recordButtonTouchDown:(UIButton *)button {
    
    self.closeButton.hidden = YES;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.recordButton.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.5, 1.5);
        self.recordBgView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7);
    } completion:^(BOOL finished) {
        //开始计时
        if (finished) {
            [self startCutdown];
        }
        else {
            self.closeButton.hidden = NO;
        }
    }];
}

- (void)recordButtonTouchUp:(UIButton *)button {
    if (!_progressLayer) {
        [self.recordButton.layer removeAllAnimations];
        [self.recordBgView.layer removeAllAnimations];
        self.recordButton.transform = CGAffineTransformIdentity;
        self.recordBgView.transform = CGAffineTransformIdentity;
    }
    else {
        //停止计时
        [self stopCutdown];
        
        self.recordButton.hidden = YES;
        self.recordBgView.hidden = YES;
        self.closeButton.hidden = YES;
    }
}

- (void)recordButtonCancel:(UIButton *)button {
    
    [self stopCutdown];
    
    self.closeButton.hidden = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        button.transform = CGAffineTransformIdentity;
        self.recordBgView.transform = CGAffineTransformIdentity;
    }];
}

- (void)cancelButtonAction:(UIButton *)button {
    
    if (self.player) {//移除正在播放的预览视频
        [self.player shutdown];
        [self.player.view removeFromSuperview];
        self.player = nil;
    }
    
    self.cancelButton.hidden = YES;
    self.doneButton.hidden = YES;
    
    self.cancelButton.transform = CGAffineTransformIdentity;
    self.doneButton.transform = CGAffineTransformIdentity;
    
    self.closeButton.hidden = NO;
    self.recordButton.hidden = NO;
    self.recordBgView.hidden = NO;
    
    IDFileManager *fm = [IDFileManager new];
    [fm removeFile:self.localFileURL];
}

- (void)doneButtonAction:(UIButton *)button {
    
    if (self.player) {//移除正在播放的预览视频
        [self.player shutdown];
        [self.player.view removeFromSuperview];
        self.player = nil;
    }
    
    LSCaptureModel *model = [LSCaptureModel captureModelWithName:[self.localFileURL.absoluteString lastPathComponent]];
    
    [self dismissViewControllerAnimated:YES completion:^{
        !self.capCompleteBlock?:self.capCompleteBlock(model);
    }];
}

- (void)closeButtonAction:(UIButton *)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    if ([self.closeButton pointInside:point withEvent:event]) return;
    if (point.y > self.recordButton.top) return;
//    if ((point.x > self.switchButton.x-20)&&(point.y < CGRectGetMaxY(self.switchButton.frame)+20)) return;
    
    [self focusInPointAtVideoView:point];
}

- (void)swapCameraAction:(UIButton *)button {
    
    button.selected = !button.selected;
    
    AVCaptureDevice *captureDevice;
    //前置摄像头
    if (button.selected) {
        captureDevice = [self captureDeviceWithPosition:AVCaptureDevicePositionFront];
    }//后置摄像头
    else {
        captureDevice = [self captureDeviceWithPosition:AVCaptureDevicePositionBack];
    }
    
//    AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
//    [self.session beginConfiguration];
//    [self.session removeInput:self.videoInput];
//    [self.session addInput:newInput];
//    self.videoInput = newInput;
//    self.videoDevice = captureDevice;
//    [self.session commitConfiguration];
}

- (void)focusInPointAtVideoView:(CGPoint)point {
    
    self.focusView.center = point;
    [self.view addSubview:_focusView];
    
    AVCaptureDevice *device = self.captureSessionCoordinator.cameraDevice;
    
    NSError *error = nil;
    if ([device lockForConfiguration:&error]) {
        if ([device isFocusPointOfInterestSupported]) {
            device.focusPointOfInterest = point;
        }
        if ([device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            device.focusMode = AVCaptureFocusModeAutoFocus;
        }
        if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            device.exposureMode = AVCaptureExposureModeAutoExpose;
        }
        if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            device.whiteBalanceMode = AVCaptureWhiteBalanceModeAutoWhiteBalance;
        }
        [device unlockForConfiguration];
    }
    
    if (error) {
        NSLog(@"聚焦失败:%@",error);
    }
    else {
        [self.focusView showFocusAnimation];
    }
    
    kDISPATCH_AFTER_BLOCK(1.0, ^{
        [self.focusView removeFromSuperview];
    })
}

- (AVCaptureDevice *)captureDeviceWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}

- (void)startCapture {
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self.captureSessionCoordinator startRecording];
}

- (void)stopCapture {
    [self.captureSessionCoordinator stopRecording];
}

#pragma mark = IDCaptureSessionCoordinatorDelegate methods

- (void)coordinatorDidBeginRecording:(IDCaptureSessionCoordinator *)coordinator {
    NSLog(@"开始录制视频");
}

- (void)coordinator:(IDCaptureSessionCoordinator *)coordinator didFinishRecordingToOutputFileURL:(NSURL *)outputFileURL error:(NSError *)error {
    NSLog(@"结束录制视频");
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    self.localFileURL = outputFileURL;
    
    //添加视频预览视图
    ZHPlayer *player = [ZHPlayer new];
    self.player = player;
    player.view.frame = self.view.bounds;
    player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    player.shouldAutoplay = YES;
    player.shouldPlayLoop = YES;
    [player initPlayerWith:outputFileURL];
    [self.view insertSubview:player.view belowSubview:self.recordBgView];
    
    //选择确定或者重新录制
    self.recordButton.hidden = YES;
    self.recordBgView.hidden = YES;
    self.closeButton.hidden = YES;
    
    self.cancelButton.hidden = NO;
    self.doneButton.hidden = NO;
    CGFloat offset = kScreenWidth*0.5-80;
    [UIView animateWithDuration:0.25 animations:^{
        self.cancelButton.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, -offset, 0);
        self.doneButton.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, offset, 0);
    } completion:^(BOOL finished) {
        self.recordBgView.transform = CGAffineTransformIdentity;
        self.recordButton.transform = CGAffineTransformIdentity;
    }];

}

#pragma mark - 绘制进度
- (void)startCutdown {
    [self startCapture];
    [self configProgressLayer];
    [self setProgressRatio:@(0.0)];
}

- (void)setProgressRatio:(NSNumber *)ratio {
    
    CGFloat progress = [ratio floatValue];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.progressLayer.strokeEnd = progress;
    [CATransaction commit];
    
    CGFloat delta = 1 / (self.maxCaptureDuration/kRefreshDuration);
    
    NSNumber *newValue = @(delta + progress);
    
    if ([newValue floatValue]>=1) {
        [self stopCutdown];
    }
    else {
        [self performSelector:@selector(setProgressRatio:) withObject:newValue afterDelay:kRefreshDuration];
    }
}

- (void)stopCutdown {
    //结束录制
    [self stopCapture];
    //移除进度
    [self.progressLayer removeFromSuperlayer];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.progressLayer = nil;
}

- (void)configProgressLayer {
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    self.progressLayer = shapeLayer;
    
    CGSize size = self.recordButton.layer.frame.size;
    CGFloat layerX = (kScreenWidth-size.width)*0.5;
    CGFloat layerY = (kScreenHeight-size.height*0.5-150);
    shapeLayer.frame = CGRectMake(layerX, layerY, size.width, size.height);
    
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = 4.0f;
    shapeLayer.strokeColor = kMainColor.CGColor;
    
    //创建圆形贝塞尔曲线
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(shapeLayer.bounds, 2, 2) cornerRadius:(shapeLayer.bounds.size.width / 2)];
    shapeLayer.path = bezierPath.CGPath;
    [self.view.layer addSublayer:shapeLayer];
    
    shapeLayer.strokeStart = 0;
    shapeLayer.strokeEnd = 0;
}

#pragma mark - 权限判断
- (void)hasAccessAuthority:(void(^)(BOOL granted))block {
    
    //相机授权
    [self accessAuthorityWithType:AVMediaTypeVideo complete:^(AVAuthorizationStatus status) {
        
        if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied) {
            [self.view showAlertWithTitle:@"系统提示" message:@"您已关闭相机使用权限，请至手机“设置->隐私->相机”中打开"];
            !block?:block(NO);
        }
        else {
            //麦克风
            [self accessAuthorityWithType:AVMediaTypeAudio complete:^(AVAuthorizationStatus status) {
                
                if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied) {
                    [self.view showAlertWithTitle:@"系统提示" message:@"您已关闭相机使用权限，请至手机“设置->隐私->麦克风”中打开"];
                    !block?:block(NO);
                }
                else {
                    //完成权限判断
                    !block?:block(YES);
                }
                
            }];
        }
    }];
}

- (void)accessAuthorityWithType:(NSString *)mediaType complete:(void(^)(AVAuthorizationStatus status))complete {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            
            AVAuthorizationStatus status = granted?AVAuthorizationStatusAuthorized:AVAuthorizationStatusDenied;
            
            !complete?:complete(status);
            
        }];
    }
    else {
        !complete?:complete(authStatus);
    }
}

@end

@implementation LSFocusView

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)showFocusAnimation {
    
    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.4, 1.4);
    [UIView animateWithDuration:0.25 animations:^{
        self.transform = CGAffineTransformIdentity;
    }];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextSetLineWidth(context, 1.0);
    
    CGFloat len = 4;
    
    CGContextMoveToPoint(context, 0.0, 0.0);
    CGContextAddRect(context, self.bounds);
    
    CGContextMoveToPoint(context, 0, self.height/2);
    CGContextAddLineToPoint(context, len, self.height/2);
    
    CGContextMoveToPoint(context, self.width/2, self.height);
    CGContextAddLineToPoint(context, self.width/2, self.height - len);
    
    CGContextMoveToPoint(context, self.width, self.height/2);
    CGContextAddLineToPoint(context, self.width - len, self.height/2);
    
    CGContextMoveToPoint(context, self.width/2, 0);
    CGContextAddLineToPoint(context, self.width/2, len);
    
    CGContextDrawPath(context, kCGPathStroke);
}

@end

@implementation LSCaptureModel

+ (instancetype)captureModelWithName:(NSString *)videoName {
    
    LSCaptureModel *model = [LSCaptureModel new];
    model.videoName = videoName;
    
    NSString *fileName;
    if ([videoName containsString:@".mov" ]) {
        fileName = [videoName stringByReplacingOccurrencesOfString:@".mov" withString:@".jpg"];
    }
    else if ([videoName containsString:@".mp4"]) {
        fileName = [videoName stringByReplacingOccurrencesOfString:@".mp4" withString:@".jpg"];
    }
    
    model.thumName = fileName;
    
    return model;
}

- (void)setThumName:(NSString *)thumName {
    _thumName = thumName;
    //异步存储缩略图
    kDISPATCH_GLOBAL_QUEUE_DEFAULT(^{
        NSString *videoPath = [kCaptureFolder stringByAppendingPathComponent:self.videoName];
        NSString *thumPath = [kCaptureFolder stringByAppendingPathComponent:thumName];
        //保存缩略图
        [self saveThumbnailImageForVideo:[NSURL fileURLWithPath:videoPath] filePath:thumPath];
    })

    NSString *videoPath = [kCaptureFolder stringByAppendingPathComponent:self.videoName];
    NSString *thumPath = [kCaptureFolder stringByAppendingPathComponent:thumName];
    //保存缩略图
    [self saveThumbnailImageForVideo:[NSURL fileURLWithPath:videoPath] filePath:thumPath];

}

- (void)saveThumbnailImageForVideo:(NSURL *)videoURL filePath:(NSString *)filePath {
    
    UIImage *image = [self thumbnailImageForVideo:videoURL atTime:1];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    [imageData writeToFile:filePath atomically:YES];
}

//获取视频的第一帧截图
- (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    
    return thumbnailImage;
}

- (NSURL *)localVideoFileURL {
    return [NSURL fileURLWithPath:[kCaptureFolder stringByAppendingPathComponent:self.videoName]];
}

- (UIImage *)localThumImage {
    return [UIImage imageWithContentsOfFile:[kCaptureFolder stringByAppendingPathComponent:self.thumName]];
}

@end
