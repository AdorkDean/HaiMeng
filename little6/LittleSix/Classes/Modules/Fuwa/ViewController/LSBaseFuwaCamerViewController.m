//
//  LSFuwaCatchViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/15.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSBaseFuwaCamerViewController.h"
#import "LSFuwaModel.h"
#import "LSQRCodeViewController.h"
#import "UIView+HUD.h"
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>

@interface LSBaseFuwaCamerViewController ()

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@end

@implementation LSBaseFuwaCamerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.fd_interactivePopDisabled = YES;
    
    if (!self.screenShots) {
        self.screenShots = [NSString stringWithFormat:@"0.5"];
    }
    
    [self.navigationController.navigationBar setTranslucent:YES];

    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_ transparent"]
                                                  forBarMetrics:UIBarMetricsDefault];
    
    [self initSubViews];

    if (![LSQRCodeViewController isCameraAuthorize]) {
        [self.view showAlertWithTitle:@"系统提示" message:@"您已关闭相机使用权限，请至手机“设置->隐私->相机”中打开" cancelAction:nil doneAction:^{
            //跳转到应用的设置界面
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if (![[UIApplication sharedApplication] canOpenURL:url]) return;
            [[UIApplication sharedApplication] openURL:url];
        }];
        return;
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (![self _initialize]) return;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.session stopRunning];
}

- (BOOL)_initialize {

    _session = [AVCaptureSession new];

    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];

    BOOL lock = [device lockForConfiguration:nil];
    //是否支持自动对焦
    if (lock && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        if ([device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
            device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
            device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        if ([device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
            device.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
        [device unlockForConfiguration];

        RACSignal *signal1 = RACObserve(device, adjustingFocus);
        RACSignal *signal2 = RACObserve(device, adjustingExposure);
        RACSignal *signal3 = RACObserve(device, adjustingWhiteBalance);

        @weakify(self)
        RACSignal *mergeSignal = [[[signal1 merge:signal2] merge:signal3] throttle:[self.screenShots floatValue]];
        [mergeSignal subscribeNext:^(id _Nullable x) {
            @strongify(self)
            if (device.adjustingExposure || device.adjustingFocus || device.adjustingWhiteBalance) return;
            !self.focusCompleteBlock ?: self.focusCompleteBlock();
        }];
    }

    NSError *error;
    _deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        [self.view showAlertWithTitle:@"系统提示" message:@"无法添加输入设备"];
        return NO;
    }
    [_session addInput:_deviceInput];

    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *stillImageOutputSettings =
        [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:stillImageOutputSettings];
    [self.session addOutput:self.stillImageOutput];

    //添加预览图层
    [_previewLayer removeFromSuperlayer];
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = self.view.bounds;

    [self.view.layer insertSublayer:self.previewLayer atIndex:0];

    [_session startRunning];

    //添加遮罩层
    [self.maskView removeFromSuperview];
    UIView *maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.maskView = maskView;
    [maskView setBackgroundColor:[UIColor blackColor]];
    [maskView setAlpha:0.6];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path appendPath:[UIBezierPath bezierPathWithRect:maskView.bounds]];

    CGFloat width = self.cycleView.width - 20;
    CGFloat x = (kScreenWidth - width) * 0.5;
    CGFloat y = (kScreenHeight - width) * 0.5;

    CGRect frame = CGRectMake(x, y, width, width);

    //反方向绘制Path
    [path appendPath:[UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:width * 0.5].bezierPathByReversingPath];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    maskView.layer.mask = maskLayer;

    [self.view insertSubview:maskView belowSubview:self.cycleView];

    return YES;
}

- (void)initSubViews {

    self.view.backgroundColor = [UIColor blackColor];

    UIImageView *cycleView = [UIImageView new];
    self.cycleView = cycleView;
    cycleView.image = [UIImage imageNamed:@"fuwa_shot_in"];
    [self.view addSubview:cycleView];
    [cycleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];

    UIImageView *rectView = [UIImageView new];
    self.rectView = rectView;
    rectView.image = [UIImage imageNamed:@"fuwa_shot_out"];
    [self.view addSubview:rectView];
    [rectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(cycleView);
    }];

    [self.view layoutIfNeeded];
}

- (void)captureComplete:(void (^)(UIImage *image, NSError *error))block {

    AVCaptureConnection *stillImageConnection = [self.stillImageOutput.connections objectAtIndex:0];

    if ([stillImageConnection isVideoOrientationSupported])
        [stillImageConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];

    [[self stillImageOutput]
        captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                    completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                        if (imageDataSampleBuffer != NULL) {
                                            NSData *imageData = [AVCaptureStillImageOutput
                                                jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                            UIImage *image = [[UIImage alloc] initWithData:imageData];

                                            !block ?: block(image, nil);
                                        } else {
                                            !block ?: block(nil, error);
                                        }
                                    }];
}

@end
