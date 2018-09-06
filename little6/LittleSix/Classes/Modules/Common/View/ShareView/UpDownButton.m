//
//  UpDownButton.m
//  SixtySixBoss
//
//  Created by ZhiHua Shen on 2017/1/5.
//  Copyright © 2017年 AdminZhiHua. All rights reserved.
//

#import "UpDownButton.h"

@implementation UpDownButton

- (instancetype)init {
    if ([super init]) {
        self.imageView.clipsToBounds = YES;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        self.imageView.clipsToBounds = YES;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    }
    return self;
}

- (void)setMargin:(CGFloat)margin {
    _margin = margin;

    [self layoutSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self.titleLabel sizeToFit];

    CGFloat margin = self.margin;
    CGFloat imageY = (HEIGHT(self) - HEIGHT(self.imageView) - margin - HEIGHT(self.titleLabel)) * 0.5;
    imageY = imageY < 0 ? 0 : imageY;
    CGFloat imageX = (WIDTH(self) - WIDTH(self.imageView)) * 0.5;
    CGFloat imageW = WIDTH(self.imageView) > WIDTH(self) ? WIDTH(self) : WIDTH(self.imageView);

    CGFloat rate = HEIGHT(self.imageView) / WIDTH(self.imageView);
    CGFloat imageH = self.cycleImage ? imageW : imageW * rate;

    imageH = isnan(imageH) ? 0 : imageH;

    self.imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);

    CGFloat labelX = (WIDTH(self) - WIDTH(self.titleLabel)) * 0.5;
    labelX = labelX < 0 ? 0 : labelX;
    CGFloat labelY = CGRectGetMaxY(self.imageView.frame) + margin;
    CGFloat labelW = labelX == 0 ? WIDTH(self) : WIDTH(self.titleLabel);
    CGFloat labelH = HEIGHT(self.titleLabel);
    self.titleLabel.frame = CGRectMake(labelX, labelY, labelW, labelH);

    if (self.cycleImage) {
        self.imageView.layer.cornerRadius = imageW * 0.5;
        self.imageView.layer.masksToBounds = YES;
    }
}

@end
