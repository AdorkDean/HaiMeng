//
//  ZHRecordUtil.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/4.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "ZHRecordUtil.h"
#import <AVFoundation/AVFoundation.h>

@interface ZHRecordUtil () <AVAudioRecorderDelegate>

@property (nonatomic,weak) id<ZHRecordUtilDelegate> delegate;

@property (nonatomic, strong) AVAudioSession *session;
@property (nonatomic, strong) AVAudioRecorder *recorder;

@property (nonatomic, copy) NSString *fileName;

@end

@implementation ZHRecordUtil

- (id)initWithDelegate:(id<ZHRecordUtilDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        _maxRecordDuration = 60;
    }
    return self;
}

- (void)startRecord {
    //配置
    [self configSession];
    [self configRecorder];
    //开始录音
    [self.recorder record];
    //更新音量
    [self startUpdateVolumeMeters];
}

- (void)stopRecord {
    //停止自动刷新音量
    [self stopUpdateVolumeMeters];
    //获取当前的录音时间
    self.currentRecordDuration = self.recorder.currentTime;
    //停止录音
    [self.recorder stop];
}

- (void)cancelRecord {
    [self.recorder stop];
    [self.recorder deleteRecording];
    [self stopUpdateVolumeMeters];
}

//获取当前音量
- (void)startUpdateVolumeMeters {
    //更新音量
    [self.recorder updateMeters];
    
    float lowPassResults = pow(10, (0.05 * [_recorder peakPowerForChannel:0]));
    
    if ([self.delegate respondsToSelector:@selector(updateVolumeMeters:)]) {
        [self.delegate updateVolumeMeters:lowPassResults];
    }
    //0.15秒刷新一次
    [self performSelector:@selector(startUpdateVolumeMeters) withObject:nil afterDelay:0.15];
}

- (void)stopUpdateVolumeMeters {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startUpdateVolumeMeters) object:nil];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    
    //停止音量的检测
    [self stopUpdateVolumeMeters];
    
    if (flag) {
        if (self.currentRecordDuration > 1) {
            if ([self.delegate respondsToSelector:@selector(completeRecordWithFileName:)]) {
                [self.delegate completeRecordWithFileName:self.fileName];
            }
        }else {
            //删除当前录音
            [self.recorder deleteRecording];
            if ([_delegate respondsToSelector:@selector(recordDurationTooShort)]) {
                [_delegate recordDurationTooShort];
            }
        }
        //取消激活session，其他音频可播放
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    }
}

#pragma mark - Getter & Setter
- (void)configRecorder {
    //录音的配置
    NSMutableDictionary *setting = [NSMutableDictionary dictionary];
    //音频编码格式
    setting[AVFormatIDKey] = @(kAudioFormatAppleIMA4);
    //音频采样率
    setting[AVSampleRateKey] = @(8000.0);
    //音频频道
    setting[AVNumberOfChannelsKey] = @(1);
    //音频线性音频的位深度
    setting[AVLinearPCMBitDepthKey] = @(8);
    
    //文件的路劲
    NSString *filePath = [self recordSavePath];
    
    NSError *error;
    AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:filePath] settings:setting error:&error];
    _recorder = recorder;
    //准备录音
    [recorder prepareToRecord];
    //最长录音时间
    [recorder recordForDuration:self.maxRecordDuration];
    recorder.delegate = self;
    //开启音量的检测
    recorder.meteringEnabled = YES;
}

//录音文件保存的路劲，以当前时间戳命名
- (NSString *)recordSavePath {
    
    //沙盒中没有目录则新创建
    if (![[NSFileManager defaultManager] fileExistsAtPath:kRecordFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:kRecordFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *fileName = [NSString stringWithFormat:@"record_%lf.caf",[[NSDate date] timeIntervalSince1970]];
    self.fileName = fileName;
    
    return [kRecordFolder stringByAppendingPathComponent:fileName];
}

- (void)configSession {
    _session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [_session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    if(_session == nil)
    {
        NSLog(@"Error creating session: %@", [sessionError description]);
    }
    else {
        [_session setActive:YES error:nil];
    }
}

@end
