//
//  LSConversationHistoryCell.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSConversationModel;
@interface LSConversationHistoryCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *unReadLabel;

@property (nonatomic, strong) LSConversationModel *model;

@end
