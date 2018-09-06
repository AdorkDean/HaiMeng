//
//  LSMessageVideoCell.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/7.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSMessageVideoCell.h"
#import "LSPlayerVideoView.h"

@implementation LSMessageVideoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.avatarView];
        
        UIImageView *imageView = [UIImageView new];
        self.thumImageView = imageView;
        [self.contentView addSubview:imageView];
        
        UIImageView *playView = [UIImageView new];
        self.playView = playView;
        playView.image = [UIImage imageNamed:@"video_sm_play"];
        playView.hidden = YES;
        [imageView addSubview:playView];
        [playView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(imageView);
        }];
        
        [self.contentView addSubview:self.bubbleView];
    }
    
    return self;
}

- (void)setModel:(LSMessageModel *)model {
    [super setModel:model];
    
    LSVideoMessageModel *videoModel = (LSVideoMessageModel *)model;
    if (videoModel.fromMe&&!videoModel.isForward) {
        self.thumImageView.image = [videoModel thumImage];
        if (!videoModel.uploadComplete) {
            self.progressView.frame = self.bubbleView.frame;
            self.playView.hidden = YES;
        }
        else {
            [self.progressView removeFromSuperview];
            self.progressView = nil;
            self.playView.hidden = NO;
        }
    }
    else {
        [self.thumImageView setImageWithURL:[NSURL URLWithString:videoModel.remoteThumURL] placeholder:nil];
        self.playView.hidden = NO;
    }
}

- (void)uploadComplete {
    [super uploadComplete];
    self.playView.hidden = NO;
}

//播放视频
- (void)bubbleViewDidTapAction {
    
    LSVideoMessageModel *videoModel = (LSVideoMessageModel *)self.model;
    
    if (videoModel.fromMe&&!videoModel.uploadComplete) return;
    
    !self.playClick ? : self.playClick([NSURL URLWithString:videoModel.remoteVideoURL], self.thumImageView.image);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.model) return;
    
    LSVideoMessageModel *videoModel = (LSVideoMessageModel *)self.model;
    
    CGFloat imgX;
    CGFloat imgY;
    if (videoModel.fromMe) {
        imgX = self.avatarView.frame.origin.x - kBubbleMarginLeft - videoModel.scaleWidth;
        imgY = kBubbleMarginTop;
    }
    else {
        imgX = CGRectGetMaxX(self.avatarView.frame) + kBubbleMarginLeft;
        imgY = (videoModel.conversation_type == LSConversationTypeChat) ?kBubbleMarginTop : kBubbleMarginTop + kNickNameHeight;
    }
    
    self.thumImageView.frame = CGRectMake(imgX, imgY, videoModel.scaleWidth, videoModel.scaleHeight);
    
    UIImage *image = videoModel.fromMe?self.senderBubbleImage:self.receiverBubbleImage;
    [self makeMaskView:self.thumImageView withImage:image];
    
    self.bubbleView.frame = self.thumImageView.frame;
    
    if (![self hasProgressView]) return;
    
    [self.progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.thumImageView);
    }];
    
//    self.progressView.frame = self.thumImageView.frame;
}

@end
