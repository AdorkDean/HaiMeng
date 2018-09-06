//
//  LSBaseFuwaModelCell.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSBaseFuwaModelCell.h"
#import "LSFuwaModel.h"

@implementation LSBaseFuwaModelCell

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        self.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"fuwa_model_bg"].CGImage);
        
        UIImageView *numBgView = [UIImageView new];
        self.numBgView = numBgView;
        numBgView.image = [UIImage imageNamed:@"fuwa_number_bg"];
        [self.contentView addSubview:numBgView];
        [numBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(6);
            make.top.equalTo(self).offset(6);
        }];
        
        UILabel *numLabel = [UILabel new];
        self.numLabel = numLabel;
        numLabel.textColor = HEXRGB(0xd3000f);
        numLabel.font = BOLDSYSTEMFONT(13);
        [self.contentView addSubview:numLabel];
        [numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(numBgView);
        }];
        
        UIImageView *imageView = [UIImageView new];
        self.imageView = imageView;
        imageView.image = [UIImage imageNamed:@"fuwa_model"];
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        
        UIView *lineView1 = [UIView new];
        self.lineView1 = lineView1;
        lineView1.backgroundColor = HEXRGB(0xff7f5b);
        [self.contentView addSubview:lineView1];
        [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(20);
            make.right.equalTo(self).offset(-20);
            make.height.offset(0.5);
            make.top.equalTo(imageView.mas_bottom);
        }];
        
        UIView *lineView2 = [UIView new];
        self.lineView2 = lineView2;
        lineView2.backgroundColor = HEXRGB(0xff7f5b);
        [self.contentView addSubview:lineView2];
        [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.centerX.equalTo(lineView1);
            make.bottom.equalTo(self).offset(-10);
        }];
        
        UILabel *countLabel = [UILabel new];
        countLabel.textAlignment = NSTextAlignmentCenter;
        self.countLabel = countLabel;
        countLabel.textColor = HEXRGB(0xd3000f);
        countLabel.font = SYSTEMFONT(12);
        [self.contentView addSubview:countLabel];
        [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(lineView1);
            make.bottom.equalTo(lineView2.mas_top);
        }];
    }
    return self;
}

- (void)setDisable:(BOOL)disable {
    _disable = disable;
    
    self.numLabel.text = @"4";
    self.countLabel.text = @"x5";
    
    if (disable) {
        self.numBgView.image = [UIImage imageNamed:@"fuwa_nonumber_bg"];
        self.imageView.image = [UIImage imageNamed:@"fuwabig_no"];
        self.lineView1.backgroundColor = HEXRGB(0xcccccc);
        self.lineView2.backgroundColor = HEXRGB(0xcccccc);
        self.countLabel.textColor = HEXRGB(0x999999);
        self.numLabel.textColor = HEXRGB(0x999999);
    }
    else {
        self.numBgView.image = [UIImage imageNamed:@"fuwa_number_bg"];
        self.imageView.image = [UIImage imageNamed:@"fuwa_model"];
        self.lineView1.backgroundColor = HEXRGB(0xff7f5b);
        self.lineView2.backgroundColor = HEXRGB(0xff7f5b);
        self.countLabel.textColor = HEXRGB(0xd3000f);
        self.numLabel.textColor = HEXRGB(0xd3000f);
    }
}

- (void)setModel:(LSFuwaModel *)model {
    _model = model;
    
    self.disable = (model.count==0);
    
    self.numLabel.text = model.id;
    
    NSString *countString = [NSString stringWithFormat:@"x%ld", model.count];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:countString];
    [attrStr addAttribute:NSFontAttributeName value:BOLDSYSTEMFONT(16) range:NSMakeRange(1, countString.length - 1)];
    
    self.countLabel.attributedText = attrStr;
}

@end
