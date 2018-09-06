//
//  LSMessagePictureCell.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/28.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSMessagePictureCell.h"
#import "LSMessageManager.h"
#import "YYPhotoGroupView.h"

@interface LSMessagePictureCell ()


@end

@implementation LSMessagePictureCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.avatarView];
        
        UIImageView *imageView = [UIImageView new];
        self.imgView = imageView;
        [self.contentView addSubview:imageView];
        
        [self.contentView addSubview:self.bubbleView];
    }
    
    return self;
}

- (void)setModel:(LSMessageModel *)model {
    [super setModel:model];
    
    LSPictureMessageModel *picModel = (LSPictureMessageModel *)model;
    
    if (picModel.fromMe) {
        //设置文件内容
        self.imgView.image = picModel.image;
        if (picModel.picUrl) {
            self.imgView.backgroundColor = [UIColor lightGrayColor];
            [self.imgView setImageWithURL:[NSURL URLWithString:picModel.picUrl] placeholder:nil];
        }
        //添加进度圈
        if (!picModel.uploadComplete) {
            self.progressView.frame = self.bubbleView.frame;
        }
        else {
            [self.progressView removeFromSuperview];
            self.progressView = nil;
        }
    }
    else {
        
        if (picModel.downloadComplete) {
            [self.imgView setImageWithURL:[NSURL URLWithString:picModel.picUrl] placeholder:nil];
        }
        else {
            @weakify(self)
            [self.imgView setImageWithURL:[NSURL URLWithString:picModel.picUrl] placeholder:nil options:YYWebImageOptionShowNetworkActivity progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                @strongify(self)
                self.progressView.frame = self.bubbleView.frame;
                self.progressView.ratio = receivedSize/expectedSize;
            } transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                @strongify(self)

                [self uploadComplete];
                
                if (!error) {
                    picModel.downloadComplete = YES;
                    [ShareMessageManager updateMessage:model];
                }
                
            }];
        }
        
    }
    
    [self setNeedsLayout];
}

- (void)bubbleViewDidTapAction {
    
    NSArray<YYPhotoGroupItem *> *items = self.photoItemsBlock(self.model);
    
    YYPhotoGroupView *v = [[YYPhotoGroupView alloc] initWithGroupItems:items];
    [v presentFromImageView:self.bubbleView toContainer:LSKeyWindow animated:YES completion:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.model) return;
    
    LSPictureMessageModel *picModel = (LSPictureMessageModel *)self.model;
    
    CGFloat imgX;
    CGFloat imgY;
    if (picModel.fromMe) {
        imgX = self.avatarView.frame.origin.x - kBubbleMarginLeft - picModel.scaleWidth;
        imgY = kBubbleMarginTop;
    }
    else {
        imgX = CGRectGetMaxX(self.avatarView.frame) + kBubbleMarginLeft;
        imgY = (picModel.conversation_type == LSConversationTypeChat) ?kBubbleMarginTop : kBubbleMarginTop + kNickNameHeight;
    }
    
    self.imgView.frame = CGRectMake(imgX, imgY, picModel.scaleWidth, picModel.scaleHeight);
    
    UIImage *image = picModel.fromMe?self.senderBubbleImage:self.receiverBubbleImage;
    [self makeMaskView:self.imgView withImage:image];
    
    self.bubbleView.frame = self.imgView.frame;
    
    if (![self hasProgressView]) return;
    
//    self.progressView.frame = self.imgView.frame;
    [self.progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.imgView);
    }];

}


@end
