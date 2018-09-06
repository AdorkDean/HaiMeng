//
//  LSMessageVoiceCell.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/3.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSMessageVoiceCell.h"
#import "ZHAudioPlayer.h"
#import "ConstKeys.h"
#import "LSMessageManager.h"

@interface LSMessageVoiceCell ()

@property (nonatomic,strong) NSArray<UIImage *> *sender_animate_images;
@property (nonatomic,strong) NSArray<UIImage *> *receiver_animate_images;

@property (nonatomic,strong) AVAudioPlayer *audioPlayer;

@end

@implementation LSMessageVoiceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.avatarView];
        [self.contentView addSubview:self.bubbleView];
        
        UIActivityIndicatorView *indicatorView = [UIActivityIndicatorView new];
        indicatorView.hidesWhenStopped = YES;
        self.indicatorView = indicatorView;
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.contentView addSubview:indicatorView];
        indicatorView.hidden = YES;
        
        UILabel *timeLabel = [UILabel new];
        self.timeLabel = timeLabel;
        timeLabel.textColor = HEXRGB(0x888888);
        timeLabel.font = SYSTEMFONT(12);
        [self.contentView addSubview:timeLabel];
        timeLabel.hidden = YES;
        timeLabel.textAlignment = NSTextAlignmentRight;
        
        UIImageView *voiceView = [UIImageView new];
        self.voiceView = voiceView;
        [self.contentView addSubview:voiceView];
        
        @weakify(self)
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kStopAudioPlayNoti object:nil] subscribeNext:^(NSNotification * _Nullable x) {
            @strongify(self)
            [self voiceAnimation:NO];
            if (self.audioPlayer) {
                [ZHAudioPlayer stopPlayer:self.audioPlayer];
            }
        }];
    }
    
    return self;
}

- (void)setModel:(LSMessageModel *)model {
    [super setModel:model];
    
    //暂停当前的播放器
    if (self.audioPlayer) {
        [ZHAudioPlayer stopPlayer:self.audioPlayer];
        self.audioPlayer = nil;
        [self voiceAnimation:NO];
    }
    
    LSAudioMessageModel *audioMessage = (LSAudioMessageModel *)model;
    
    NSString *imageName;
    if (audioMessage.fromMe) {
        //设置图片
        imageName = @"sender_voice_play";
        self.voiceView.animationImages = self.sender_animate_images;
        self.timeLabel.textAlignment = NSTextAlignmentRight;

        [self updateIndicatorHidden:audioMessage.uploadComplete];
        
    }
    else {
        imageName = @"receiver_voice_play";
        self.voiceView.animationImages = self.receiver_animate_images;
        self.timeLabel.textAlignment = NSTextAlignmentLeft;

        [self updateIndicatorHidden:audioMessage.downloadComplete];
        
        //下载音频
        if (!audioMessage.downloadComplete) {
            [LSMessageManager downloadAudio:audioMessage success:^{
                [self updateIndicatorHidden:YES];
            } failure:nil];
        }
    }
    
    self.voiceView.image = [UIImage imageNamed:imageName];
    
    [self setNeedsLayout];
}

- (void)downloadAudio {
    
}

- (void)uploadComplete {
    LSAudioMessageModel *audioMessage = (LSAudioMessageModel *)self.model;
    [self updateIndicatorHidden:YES];
    self.timeLabel.text = [NSString stringWithFormat:@"%1.0f''",audioMessage.duration];
    [self setNeedsLayout];
}

//隐藏菊花显示时间，或者显示时间隐藏菊花
- (void)updateIndicatorHidden:(BOOL)hidden {
    if (hidden) {
        [self.indicatorView stopAnimating];
        self.indicatorView.hidden = YES;
        self.timeLabel.hidden = NO;
        LSAudioMessageModel *audioMessage = (LSAudioMessageModel *)self.model;
        self.timeLabel.text = [NSString stringWithFormat:@"%1.0f''",audioMessage.duration];
    }
    else {
        self.indicatorView.hidden = NO;
        [self.indicatorView startAnimating];
        self.timeLabel.hidden = YES;
    }
}

//声音图片的动画效果
- (void)voiceAnimation:(BOOL)animate {
    if (animate) {
        self.voiceView.animationDuration = 1.0;
        self.voiceView.animationRepeatCount = CGFLOAT_MAX;
        [self.voiceView startAnimating];
    }
    else {
        [self.voiceView stopAnimating];
    }
}

- (void)bubbleViewDidTapAction {
    
    //发送停止播放音频通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kStopAudioPlayNoti object:nil];
    
    LSAudioMessageModel *audioMessage = (LSAudioMessageModel *)self.model;
    NSString *filePath = [audioMessage localFilePath];

    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    @weakify(self)
    self.audioPlayer = [ZHAudioPlayer playAudio:fileUrl withCompletionBlock:^(BOOL complete) {
        @strongify(self)
        [self voiceAnimation:NO];
        //释放资源
        self.audioPlayer = nil;
    }];
    
    //音频播放器初始化出错
    if (!self.audioPlayer) return;
    
    [self voiceAnimation:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    LSAudioMessageModel *audioMessage = (LSAudioMessageModel *)self.model;

    CGFloat bubbleViewW = 80+audioMessage.duration;
    CGFloat bubbleViewY;
    CGFloat bubbleViewX;
    CGFloat bubbleViewH = kBubbleMinHeight;
    
    CGFloat indicatorViewX;
    CGFloat timeLabelX;
    CGSize timeLabelSize = CGSizeMake(30, 20);
    CGFloat voiceViewX;
    
    if (audioMessage.fromMe) {
        bubbleViewX = (self.avatarView.left - kBubbleMarginLeft)-bubbleViewW;
        indicatorViewX = bubbleViewX-bubbleViewW;
        timeLabelX = bubbleViewX - timeLabelSize.width;
        
        voiceViewX = (bubbleViewX+bubbleViewW)-kVoiceImageMarginR;
        bubbleViewY = kBubbleMarginTop;
    }
    else {
        bubbleViewX = CGRectGetMaxX(self.avatarView.frame) + kBubbleMarginLeft;
        indicatorViewX = bubbleViewX+bubbleViewW;
        timeLabelX = indicatorViewX;
        
        voiceViewX = bubbleViewX + kVoiceImageMarginL;
        bubbleViewY = kBubbleMarginTop + kNickNameHeight;
    }
    
    self.bubbleView.frame = CGRectMake(bubbleViewX, bubbleViewY, bubbleViewW, bubbleViewH);
    
    //菊花布局
    [self.indicatorView sizeToFit];
    self.indicatorView.centerY = self.bubbleView.centerY-4;
    self.indicatorView.left = indicatorViewX;

    //时间的布局
    self.timeLabel.size = CGSizeMake(30, 20);
    self.timeLabel.left = timeLabelX;
    self.timeLabel.centerY = self.bubbleView.centerY-4;

    //音量图标
    [self.voiceView sizeToFit];
    self.voiceView.left = voiceViewX;
    self.voiceView.centerY = self.bubbleView.centerY - 5;
}

- (NSArray<UIImage *> *)sender_animate_images {
    if (!_sender_animate_images) {
        NSMutableArray *list = [NSMutableArray array];
        for (int i=1; i<4; i++) {
            NSString *name = [NSString stringWithFormat:@"sender_voice_play_%02d",i];
            UIImage *image = [UIImage imageNamed:name];
            [list addObject:image];
        }
        _sender_animate_images = list;
    }
    return _sender_animate_images;
}

- (NSArray<UIImage *> *)receiver_animate_images {
    if (!_receiver_animate_images) {
        NSMutableArray *list = [NSMutableArray array];
        for (int i=1; i<4; i++) {
            NSString *name = [NSString stringWithFormat:@"receiver_voice_play_%02d",i];
            UIImage *image = [UIImage imageNamed:name];
            [list addObject:image];
        }
        _receiver_animate_images = list;
    }
    return _receiver_animate_images;
}

@end
