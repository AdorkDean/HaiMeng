//
//  LSMessageEmotionCell.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/9.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSMessageEmotionCell.h"

@implementation LSMessageEmotionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.avatarView];
        
        UIImageView *emotionView = [YYAnimatedImageView new];
        emotionView.clipsToBounds = YES;
        emotionView.contentMode = UIViewContentModeScaleAspectFill;
        self.emotionView = emotionView;
        [self.contentView addSubview:emotionView];
        [self.contentView addSubview:self.bubbleView];
    }
    return self;
}

- (void)setModel:(LSMessageModel *)model {
    [super setModel:model];
    
    LSEmotionMessageModel *emotionModel = (LSEmotionMessageModel *)model;
    [self.emotionView setImageWithURL:[NSURL URLWithString:emotionModel.emo_url] placeholder:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    LSEmotionMessageModel *emotionModel = (LSEmotionMessageModel *)self.model;
    
    CGFloat emotionX;
    CGFloat emotionY;
    
    if (self.model.fromMe) {
        emotionX = self.avatarView.frame.origin.x - kBubbleMarginLeft - emotionModel.scaleWidth - kEmotionOffsetL;
        emotionY = kBubbleMarginTop;
    }
    else {
        emotionX = CGRectGetMaxX(self.avatarView.frame) + kBubbleMarginLeft + kEmotionOffsetL;
        emotionY = (self.model.conversation_type == LSConversationTypeChat) ? kBubbleMarginTop : kBubbleMarginTop + kNickNameHeight;
    }
    
    self.emotionView.frame = CGRectMake(emotionX, emotionY, emotionModel.scaleWidth, emotionModel.scaleHeight);
    CGRect frame = self.emotionView.frame;
    self.bubbleView.frame = frame;
}

@end
