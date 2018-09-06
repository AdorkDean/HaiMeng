//
//  LSConversationHistoryCell.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSConversationHistoryCell.h"
#import "LSConversationModel.h"
#import "NSDate+Util.h"

@implementation LSConversationHistoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _iconImageView = [UIImageView new];
        [self addSubview:_iconImageView];
        
        _nameLabel = [UILabel new];
        _nameLabel.font = SYSTEMFONT(16);
        _nameLabel.textColor = [UIColor blackColor];
        [self addSubview:_nameLabel];
        
        _timeLabel = [UILabel new];
        _timeLabel.font = SYSTEMFONT(12);
        _timeLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:_timeLabel];
        
        _messageLabel = [UILabel new];
        _messageLabel.font = SYSTEMFONT(14);
        _messageLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:_messageLabel];
        
        _unReadLabel = [UILabel new];
        _unReadLabel.font = [UIFont boldSystemFontOfSize:10];
        _unReadLabel.textColor = [UIColor whiteColor];
        _unReadLabel.backgroundColor = [UIColor redColor];
        _unReadLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_unReadLabel];
        
        [self makeConstraints];
    }
    return self;
}

- (void)makeConstraints {
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(50);
        make.centerY.equalTo(self);
        make.left.offset(10);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImageView);
        make.left.equalTo(self.iconImageView.mas_right).offset(10);
        make.right.equalTo(self).offset(-80);
        make.height.offset(26);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.offset(16);
        make.centerY.equalTo(self.nameLabel);
        make.right.equalTo(self).offset(-10);
    }];
    
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel);
        make.bottom.equalTo(self).offset(-13);
        make.height.offset(18);
        make.right.equalTo(self).offset(-10);
    }];
    
    [self.unReadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.offset(18);
        make.centerY.equalTo(self.iconImageView.mas_top).offset(4);
        make.centerX.equalTo(self.iconImageView.mas_right).offset(-4);
        self.unReadLabel.layer.cornerRadius = 9;
        self.unReadLabel.layer.masksToBounds = YES;
    }];
}

- (void)setModel:(LSConversationModel *)model {
    _model = model;
    
    NSString *formatDateStr = [NSDate formatTimeString:model.lastMessage.timeStamp];
    self.timeLabel.text = formatDateStr;
    
    self.unReadLabel.hidden = model.unReadCount == 0;
    
    self.unReadLabel.text = [NSString stringWithFormat:@"%ld",model.unReadCount];
    
    self.nameLabel.text = model.title;
    
    [self.iconImageView setImageWithURL:[NSURL URLWithString:model.avartar] placeholder:nil];
    
    NSString *message;
    
    switch (model.lastMessage.messageType) {
        case LSMessageTypeText:
        {
            LSTextMessageModel *textMessage = (LSTextMessageModel *)model.lastMessage;
            message = model.lastMessage.fromMe ? [NSString stringWithFormat:@"%@",textMessage.text] : [NSString stringWithFormat:@"%@:%@",model.lastMessage.sender,textMessage.text];
        }
            break;
        case LSMessageTypePicture:
            message = model.lastMessage.fromMe ? @"[图片]" : [NSString stringWithFormat:@"%@:%@",model.lastMessage.sender,@"[图片]"];
            break;
        case LSMessageTypeVideo:
            message = model.lastMessage.fromMe ? @"[视频]" : [NSString stringWithFormat:@"%@:%@",model.lastMessage.sender,@"[视频]"];
            break;
        case LSMessageTypeAudio:
            message = model.lastMessage.fromMe ? @"[语音]" : [NSString stringWithFormat:@"%@:%@",model.lastMessage.sender,@"[语音]"];
            break;
        case LSMessageTypeSystem:
            message = @"[系统提示]";
            break;
        case LSMessageTypeEmotion:
            message = model.lastMessage.fromMe ? @"[表情]" : [NSString stringWithFormat:@"%@:%@",model.lastMessage.sender,@"[表情]"];
            break;
        default:
            break;
    }
    
    self.messageLabel.text = message;
}

@end
