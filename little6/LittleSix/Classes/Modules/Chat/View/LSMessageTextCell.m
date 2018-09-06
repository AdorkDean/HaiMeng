//
//  LSMessageTextCell.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/27.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSMessageTextCell.h"

#define kTextFont SYSTEMFONT(16)

@interface LSMessageTextCell ()

@property (nonatomic,strong) YYLabel *contentLabel;

@end

@implementation LSMessageTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.avatarView];
        [self.contentView addSubview:self.bubbleView];
        
        YYLabel *contentLabel = [YYLabel new];
        _contentLabel = contentLabel;
        contentLabel.font = kTextFont;
        contentLabel.numberOfLines = 0;
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
        
        UILongPressGestureRecognizer *longGest = [UILongPressGestureRecognizer new];
        longGest.minimumPressDuration = 0.8;
        [contentLabel addGestureRecognizer:longGest];
        [longGest addTarget:self action:@selector(bubbleViewDidLongTapAction)];

        [self.contentView addSubview:contentLabel];
    }
    return self;
}

- (void)setModel:(LSMessageModel *)model {
    [super setModel:model];
    
    LSTextMessageModel *textMessage = (LSTextMessageModel *)model;
    
    if (!textMessage.richTextAttributedString) {
        NSMutableAttributedString *attributedString = [LSTextParaser parseText:textMessage.text withFont:kTextFont];
        textMessage.richTextAttributedString = attributedString;
    }
    
    self.contentLabel.attributedText = textMessage.richTextAttributedString;
    
    [self layoutSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.model) return;
    
    LSTextMessageModel *textMessage = (LSTextMessageModel *)self.model;

    CGFloat bubbleViewW = textMessage.textWidth + kBubblePadding.left + kBubblePadding.right;
    CGFloat bubbleViewH = textMessage.textHeight + kBubblePadding.top + kBubblePadding.bottom;
    
    bubbleViewW = MAX(bubbleViewW, kBubbleMinWidth);
    bubbleViewH = MAX(bubbleViewH, kBubbleMinHeight);
    
    CGFloat bubbleViewY;
    CGFloat bubbleViewX;
    
    if (textMessage.fromMe) {
        bubbleViewX = (self.avatarView.frame.origin.x - kBubbleMarginLeft)-bubbleViewW;
        bubbleViewY = kBubbleMarginTop;
    }
    else {
        bubbleViewX = CGRectGetMaxX(self.avatarView.frame) + kBubbleMarginLeft;
        
        bubbleViewY = (textMessage.conversation_type == LSConversationTypeGroup) ? kBubbleMarginTop + kNickNameHeight : kBubbleMarginTop;
    }
    
    self.bubbleView.frame = CGRectMake(bubbleViewX, bubbleViewY, bubbleViewW, bubbleViewH);
    
    CGFloat textX = (CGRectGetWidth(self.bubbleView.frame)-textMessage.textWidth) * 0.5 + bubbleViewX;
    CGFloat textY = (CGRectGetHeight(self.bubbleView.frame)-textMessage.textHeight) * 0.5 + bubbleViewY - 5;
    self.contentLabel.frame = CGRectMake(textX, textY, textMessage.textWidth, textMessage.textHeight);
}

@end
