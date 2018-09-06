//
//  LSFuwaFilterButton.m
//  LittleSix
//
//  Created by Jim huang on 17/3/24.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaFilterButton.h"

@interface LSFuwaFilterButton ()

@end

@implementation LSFuwaFilterButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setContraints];
    }
    return self;
}
-(void)setContraints{
    self.nameLabel = [UILabel new];
    self.nameLabel.font = [UIFont systemFontOfSize:12];
    
    [self addSubview:self.nameLabel];
    self.iconImageView = [UIImageView new];
    [self addSubview:self.iconImageView];
    
    self.nameLabel.contentMode = UIViewContentModeCenter;
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_centerY).offset(5);
        make.centerX.equalTo(self);
    }];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_centerY);
        make.centerX.equalTo(self);
        make.width.height.mas_equalTo(20);
    }];
}

-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        self.nameLabel.textColor= HEXRGB(0xe7d09a);
        [self.iconImageView setImage:self.selectImage];
    }else{
        self.nameLabel.textColor = [UIColor whiteColor];
        [self.iconImageView setImage:self.normalImage];
    }
}


@end
