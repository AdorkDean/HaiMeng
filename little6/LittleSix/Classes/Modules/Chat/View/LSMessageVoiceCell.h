//
//  LSMessageVoiceCell.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/3.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSBaseMessageCell.h"

@interface LSMessageVoiceCell : LSBaseMessageCell

@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic,strong) UILabel *timeLabel;

@property (nonatomic,strong) UIImageView *voiceView;

- (void)uploadComplete;

@end
