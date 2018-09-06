//
//  ZHPlayer.m
//  ZHPlayer
//
//  Created by AdminZhiHua on 16/5/24.
//  Copyright © 2016年 AdminZhiHua. All rights reserved.
//

#import "ZHPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface ZHPlayer ()

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;

//防止缓冲时循环调用方法导致无法释放内存
@property (nonatomic,assign) BOOL stop;

@end

@implementation ZHPlayer

- (instancetype)init {
    if ([super init])
    {
        [self setView:[UIView new]];
    }
    return self;
}

- (void)initPlayerWith:(NSURL *)url {
    
    self.playerItem = [self playerItemWith:url];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.playerLayer];
}

- (AVPlayerItem *)playerItemWith:(NSURL *)playURL {
    
    if ([playURL.absoluteString rangeOfString:@"http"].location != NSNotFound)
    {//网络视频播放
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:playURL];
        return item;
    }
    else
    {//播放本地视频
        AVAsset *asset = [AVAsset assetWithURL:playURL];
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
        return item;
    }
    
}

#pragma mark - Operation
- (void)play {
    
    [self.player play];
    
    if (self.playbackState != MediaPlaybackStatePlaying)
    {
        self.playbackState = MediaPlaybackStatePlaying;
    }
}

- (void)pause {
    
    [self.player pause];
    
    if (self.playbackState != MediaPlaybackStatePaused)
    {
        self.playbackState = MediaPlaybackStatePaused;
    }
}

- (void)shutdown {
    
    [self pause];
    
    self.stop = YES;
    
    [self.view removeFromSuperview];
    
    self.playerItem = nil;
    self.player = nil;
    self.playerLayer = nil;
    self.view = nil;
}

- (void)seekToTime:(NSTimeInterval)position completionHandler:(void (^)(BOOL finish))handeler {
    
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay)
    {
        
        CMTime time = CMTimeMake(position, 1);
        
        [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            
            if (handeler)
            {
                handeler(finished);
            }
            
            [self play];
            
            self.playbackState = MediaPlaybackStateSeeking;
        }];
        
    }
    
}

- (void)registerObserves {
    
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self moviePlayDidEnd:x];
    }];
    
    [RACObserve(self.playerItem, status) subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (self.playerItem.status == AVPlayerItemStatusReadyToPlay)
        {
            [self playerItemStatusReadyToPlay];
        }
        else if (self.playerItem.status == AVPlayerItemStatusFailed)
        {//视频加载失败
            [self postNotification:MediaPlaybackStatusFailedNotification];
        }
    }];
    [RACObserve(self.playerItem, loadedTimeRanges) subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        self.playableDuration = [self availableDuration];
    }];
    [RACObserve(self.playerItem, playbackBufferEmpty) subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (self.playerItem.playbackBufferEmpty)
        {
            self.loadState = MediaLoadStateStalled;
            [self bufferingSomeSecond];
        }
    }];
    [RACObserve(self.playerItem, playbackLikelyToKeepUp) subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (self.playerItem.playbackLikelyToKeepUp && self.loadState == MediaLoadStateStalled)
        {
            self.loadState = MediaLoadStatePlaythroughOK;
        }
        [self play];
    }];
    
    [RACObserve(self.view, frame) subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        self.playerLayer.frame = self.view.bounds;
    }];

}

- (void)playerItemStatusReadyToPlay {
    
    if (self.playbackState == MediaPlaybackStateSeeking) return;
    
    self.playbackState = MediaPlaybackStateReadyToPlay;
    
    if (self.shouldAutoplay)
    {
        if (self.seekTime > 0)
        {
            [self seekToTime:self.seekTime completionHandler:nil];
            return;
        }
        
        [self play];
        
        self.playbackState = MediaPlaybackStatePlaying;

    }
}

- (void)bufferingSomeSecond {
    
    [self pause];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self play];
        
        if (!self.playerItem.isPlaybackLikelyToKeepUp && !self.stop)
        {
            [self bufferingSomeSecond];
        }
        
    });
    
}

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (void)postNotification:(NSString *)noti {
    [[NSNotificationCenter defaultCenter] postNotificationName:noti object:self];
}

#pragma mark - NSNotification
- (void)moviePlayDidEnd:(NSNotification *)noti {
    [self postNotification:MediaPlayerPlaybackDidFinishNotification];
    if (!self.shouldPlayLoop) return;
    [self.player seekToTime:CMTimeMake(0, 1)];
    [self.player play];
}

#pragma mark - Getter&Setter
- (void)setView:(UIView *)view {
    _view = view;
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    if (_playerItem == playerItem) {return;}
    
    _playerItem = playerItem;
    
    if (playerItem) {
        [self registerObserves];
    }
}

- (void)setPlayableDuration:(NSTimeInterval)playableDuration {
    _playableDuration = playableDuration;
}

- (NSTimeInterval)duration {
    CMTime durationTime =  self.playerItem.duration;
    return CMTimeGetSeconds(durationTime);
}

- (NSTimeInterval)currentTime {
    CMTime positionTime = self.playerItem.currentTime;
    return CMTimeGetSeconds(positionTime);
}

- (void)setLoadState:(MediaLoadState)loadState {
    _loadState = loadState;
    [self postNotification:MediaPlayerLoadStateDidChangeNotification];
}

- (void)setPlaybackState:(MediaPlaybackState)playbackState {
    _playbackState = playbackState;
    //发送通知，播放状态发生改变
    [self postNotification:MediaPlayerPlaybackStatusDidChangeNotification];
}


@end

NSString *const MediaPlaybackStatusFailedNotification = @"MediaPlaybackStatusFailedNotification";
NSString *const MediaPlayerLoadStateDidChangeNotification = @"MediaPlayerLoadStateDidChangeNotification";
NSString *const MediaPlayerPlaybackDidFinishNotification = @"MediaPlayerPlaybackDidFinishNotification";
NSString *const MediaPlayerPlaybackStatusDidChangeNotification = @"MediaPlayerPlaybackStatusDidChangeNotification";
