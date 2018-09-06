//
//  LSQRCodeViewController.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/16.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSQRCodeViewController.h"
#import "LSContactDetailViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+HUD.h"
#import "LSGroupModel.h"
#import "ImagePickerManager.h"
#import "LSFuwaModel.h"
@interface LSQRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureMetadataOutput *dataOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureConnection *connection;

@property (nonatomic, strong) UIView *scanView;
@property (nonatomic, strong) UIView *scanLine;

@end

@implementation LSQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"二维码/条码";
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self installSubviews];
    
    if (![LSQRCodeViewController isCameraAuthorize]) {
        [self.view showAlertWithTitle:@"系统提示" message:@"您已关闭相机使用权限，请至手机“设置->隐私->相机”中打开"];
        return;
    }
    
    [self installNoti];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![self _initialize]) return;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self startScanAnimation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_previewLayer removeFromSuperlayer];
    [self.scanLine.layer removeAllAnimations];
}

- (void)installSubviews {
    
    UIView *scanView = [UIView new];
    self.scanView = scanView;
    scanView.clipsToBounds = YES;
    scanView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scanView];
    
    [scanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset((WIDTH(self.view)-120));
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-50);
    }];
    
    UIImageView *frameView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qrcode_scanBackground"]];
    [scanView addSubview:frameView];
    
    [frameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scanView);
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
    
    UILabel *tipsLabel = [UILabel new];
    [self.view addSubview:tipsLabel];
    tipsLabel.text = @"将二维码/条码放入框内，即可自动扫描";
    tipsLabel.font = SYSTEMFONT(13);
    tipsLabel.textColor = HEXRGB(0xafafaf);
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(scanView.mas_bottom).offset(12);
    }];
    
    UIButton *myCode = [UIButton buttonWithType:UIButtonTypeCustom];
    [myCode setTitle:@"我的二维码" forState:UIControlStateNormal];
    [self.view addSubview:myCode];
    [myCode setTitleColor:kMainColor forState:UIControlStateNormal];
    myCode.titleLabel.font = SYSTEMFONT(14);
    [myCode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(tipsLabel.mas_bottom).offset(15);
    }];
    
    @weakify(self)
    [[myCode rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UIButton *button) {
        @strongify(self)
        UIViewController *vc = [NSClassFromString(@"LSMyQRCodeViewController") new];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    [self.view layoutIfNeeded];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)installNoti {
    
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationWillEnterForegroundNotification object:nil] subscribeNext:^(id x) {
        @strongify(self)
        [self startScanAnimation];
    }];
    
}

- (BOOL)_initialize {
    
    _session = [AVCaptureSession new];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error;
    _deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        [self.view showAlertWithTitle:@"系统提示" message:@"无法添加输入设备"];
        return NO;
    }
    [_session addInput:_deviceInput];
    
    _dataOutput = [AVCaptureMetadataOutput new];
    [_session addOutput:_dataOutput];
    _dataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    [_dataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //添加预览图层
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = self.view.bounds;
    
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    
    [_session startRunning];
    
    //添加遮罩层
    UIView *maskView = [[UIView alloc]initWithFrame:self.view.bounds];
    [maskView setBackgroundColor:[UIColor blackColor]];
    [maskView setAlpha:102.0/255];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path appendPath:[UIBezierPath bezierPathWithRect:maskView.bounds]];
    //反方向绘制Path
    [path appendPath:[UIBezierPath bezierPathWithRect:self.scanView.frame].bezierPathByReversingPath];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    maskView.layer.mask = maskLayer;
    
    [self.view insertSubview:maskView belowSubview:self.scanView];
    
    return YES;
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

#pragma mark - Action 
- (void)rightItemAction {
    [[self class] photoLibraryAuthor:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) {
            [self.view showAlertWithTitle:@"系统提示" message:@"您已关闭相册使用权限，请至手机“设置->隐私->相册”中打开"];
        }
        else {
            @weakify(self)
            [[ImagePickerManager new] pickPhotoWithPresentedVC:self allocEditing:NO finishPicker:^(NSDictionary *info) {
                @strongify(self)
                [self identifyQRcode:info];
            }];
        }
    }];

}

- (void)identifyQRcode:(NSDictionary *)info {
    // 1.获取图片信息
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    
    if (!features.count) return;
    
    CIQRCodeFeature *feature = features.firstObject;
    
    [self playSound];
    
    [self stringValue:feature.messageString];
}

#pragma mark – AVCaptureMetadataOutputObjectsDelegate
//数据输出的代理
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    if ([metadataObjects count] == 0) return;
    
    AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
    NSString *stringValue = metadataObject.stringValue;
    
    [_session stopRunning];
    
    NSLog(@"%@",stringValue);
    
    [self playSound];
    
    [self stringValue:stringValue];
}

- (void)stringValue:(NSString *)stringValue {
    
    if (self.codeType == LSQRcodeTypeFriend) {
        NSArray *array = [stringValue componentsSeparatedByString:@"?"];
        
        if (array.count > 1) {
            NSArray * arr = [array[1] componentsSeparatedByString:@"="];
            
            if (arr.count > 1) {
                NSString * type = arr[0];
                NSString * t_id = arr[1];
                
                if ([type isEqualToString:@"gid"]) {
                    //加入群后原路返回
                    [self addGroupID:t_id];
                    
                }else if ([type isEqualToString:@"uid"]) {
                    //跳到个人中心
                    LSContactDetailViewController * lsvc = [[UIStoryboard storyboardWithName:@"Contact" bundle:nil] instantiateViewControllerWithIdentifier:@"ContactDetail"];
                    lsvc.user_id = t_id;
                    [self.navigationController pushViewController:lsvc animated:YES];
      

                }
            }
        }else{

            NSArray *array = [stringValue componentsSeparatedByString:@":"];

            if (array.count > 2) {
                NSString * type = array[1];

                if ([type isEqualToString:@"user"]) {
                    [self.view showAlertWithTitle:@"温馨提示" message:@"这个是接收福娃的二维码,请在赠送页面扫描" cancelAction:^{
                        [_session startRunning];

                    }doneAction:^{
                        [_session startRunning];

                    }];

                }else if([type isEqualToString:@"fuwa"]){
                    [self.view showAlertWithTitle:@"温馨提示" message:@"这个是福娃的二维码,请在兑换页面扫描" cancelAction:^{
                        [_session startRunning];

                    }doneAction:^{
                        [_session startRunning];

                    }];
                }

            }else{
                [self.view showAlertWithTitle:@"温馨提示" message:@"非法二维码不能识别" cancelAction:^{
                    [_session startRunning];

                }doneAction:^{
                    [_session startRunning];

                }];
            }

        }
    }else if(self.codeType == LSQRcodeTypeFuwaUser){
        NSArray *array = [stringValue componentsSeparatedByString:@":"];
        if (array.count>2) {
            NSString * type = array[1];

            NSString * userId = array[2];
            if ([type isEqualToString:@"user"]) {
                self.fuwaUserBlock(userId);

                
            }else if([type isEqualToString:@"fuwa"]){
                
                [self.view showAlertWithTitle:@"温馨提示" message:@"这个是福娃的二维码,请在兑换页面扫描" cancelAction:^{
                    [_session startRunning];

                }doneAction:^{
                    [_session startRunning];

                }];
                
            }else{
                [self.view showAlertWithTitle:@"温馨提示" message:@"非法二维码不能识别" cancelAction:^{
                    [_session startRunning];

                }doneAction:^{
                    [_session startRunning];

                }];
            }
            
        }else{
            [self fuwaCheckCodeTypeWithString:stringValue];
        }

        
        [self.navigationController popViewControllerAnimated:YES];
    }else if (self.codeType == LSQRcodeTypeFuwa){
        
        NSArray *array = [stringValue componentsSeparatedByString:@":"];
        
        if (array.count>2) {
            NSString * type = array[1];

            NSString * fuwaId = array[2];
            
            if ([type isEqualToString:@"fuwa"]) {
                [self checkFuwaWithGid:fuwaId];
                
            }else if([type isEqualToString:@"user"]){
                [self.view showAlertWithTitle:@"温馨提示" message:@"这个是接收福娃的二维码,请在赠送页面扫描" cancelAction:^{
                    [_session startRunning];

                }doneAction:^{
                    [_session startRunning];

                }];
            }else{
                [self.view showAlertWithTitle:@"温馨提示" message:@"非法二维码不能识别" cancelAction:^{
                    [_session startRunning];

                }doneAction:^{
                    [_session startRunning];

                }];
            }
        }else{
            
            [self fuwaCheckCodeTypeWithString:stringValue];
        }

        
    }else{
        [self.view showAlertWithTitle:@"温馨提示" message:@"非法二维码不能识别" cancelAction:^{
            [_session startRunning];

        }doneAction:^{
            [_session startRunning];
        }];
    }
    
    
}


- (void)addGroupID:(NSString *)gid {

    [LSGroupModel increaseMembersWithGroupid:gid members:ShareAppManager.loginUser.user_id success:^(NSString *message) {
        
        [self.view showAlertWithTitle:@"提示" message:@"成功加入该群" cancelAction:^{
            [_session startRunning];

        } doneAction:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
    } failure:^(NSError *error) {
        [self.view showError:@"加群失败" hideAfterDelay:0.5];
        [_session startRunning];

    }];
}


-(void)checkFuwaWithGid:(NSString *)gid{
    [LSFuwaModel awardFuwaWithGid:gid Success:^(NSString * message) {
        [self.view showSucceed:message hideAfterDelay:1];
        [self  performSelector:@selector(delayPop) withObject:nil afterDelay:1.5f];
        [_session startRunning];

    } failure:^(NSError *error) {
        NSDictionary * userInfo = error.userInfo;
        NSString * info = userInfo[@"NSLocalizedFailureReason"];
        [self.view showError:info hideAfterDelay:1];

        [self  performSelector:@selector(reStartRunning) withObject:nil afterDelay:1.5f];


    }];
    
}

-(void)reStartRunning{
    [_session startRunning];

}

-(void)fuwaCheckCodeTypeWithString:(NSString *)stringValue{
    NSArray *array = [stringValue componentsSeparatedByString:@"?"];
    
    if (array.count > 1) {
        NSArray * arr = [array[1] componentsSeparatedByString:@"="];
        NSString * type = arr[0];
        
        if ([type isEqualToString:@"gid"]) {
            
            [self.view showAlertWithTitle:@"温馨提示" message:@"这个是添加好友,请在聊天页面扫描" cancelAction:^{
                [_session startRunning];

            }doneAction:^{
                [_session startRunning];

            }];
            
        }else if ([type isEqualToString:@"uid"]) {
            [self.view showAlertWithTitle:@"温馨提示" message:@"这个是添加群,请在聊天页面扫描" cancelAction:^{
                [_session startRunning];

            }doneAction:^{
                [_session startRunning];

            }];
        }
    }else{
        [self.view showAlertWithTitle:@"温馨提示" message:@"非法二维码不能识别" cancelAction:^{
            [_session startRunning];

        }doneAction:^{
            [_session startRunning];

        }];
    }

    
}

-(void)delayPop{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)playSound {
    SystemSoundID soundID;
    NSString *strSoundFile = PATH(@"qrscan_notice", @"wav");
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
    AudioServicesPlaySystemSound(soundID);
}

+ (BOOL)isCameraAuthorize {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return (authStatus == AVAuthorizationStatusDenied) ? NO : YES;
}

+ (void)photoLibraryAuthor:(void(^)(PHAuthorizationStatus status))authorAtatus {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            !authorAtatus?:authorAtatus(status);
        }];
    }
    else {
        !authorAtatus?:authorAtatus(status);
    }
    
}

@end
