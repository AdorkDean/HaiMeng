//
//  LSMessageSystemCell.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/27.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSMessageSystemCell.h"
#import "NSDate+Util.h"

#define kTextFont SYSTEMFONT(12)

@interface LSMessageSystemCell ()

@property (nonatomic,strong) YYLabel *contentLabel;

@end

@implementation LSMessageSystemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if ([super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        YYLabel *label = [YYLabel new];
        self.contentLabel = label;
        [self.contentView addSubview:label];
        
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.font = kTextFont;
        label.backgroundColor = HEXRGB(0xcecece);
        ViewRadius(label, 4);
        
    }
    
    return self;
}

- (void)setModel:(LSMessageModel *)model {
    [super setModel:model];
    
    if (model.messageType == LSMessageTypeTime) {
        NSString *time = [NSDate formatTimeString:model.timeStamp];
        self.contentLabel.text = time;
    }
    
    [self layoutSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.contentLabel.text) return;
    
    CGSize textSize = [self.contentLabel.text sizeForFont:kTextFont size:CGSizeMake(kScreenWidth-70, CGFLOAT_MAX) mode:NSLineBreakByWordWrapping];
    
    CGFloat textW = textSize.width + 10;
    CGFloat textH = textSize.height + 4;
    CGFloat textX = (self.width - textW) * 0.5;
    CGFloat textY = 0;
    
    self.contentLabel.frame = CGRectMake(textX, textY, textW, textH);
}

@end
