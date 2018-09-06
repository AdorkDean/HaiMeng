//
//  ZHRecordView.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/4.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "ZHRecordView.h"


@interface ZHRecordView ()

@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIImageView *alertImageView;
@property (nonatomic,strong) UIImageView *microphoneView;
@property (nonatomic,strong) UIImageView *signalView;

@end

@implementation ZHRecordView
singleton_implementation(ZHRecordView)

+ (instancetype)showInKeyWindow {
    ZHRecordView *recordView = [self showInView:LSKeyWindow];
    return recordView;
}

+ (instancetype)showInView:(UIView *)view {
    ZHRecordView *recordView = [ZHRecordView new];
    recordView.frame = view.bounds;
    recordView.status = LSRecordStatusSignalVol;
    [view addSubview:recordView];
    return recordView;
}

- (void)dismissHUD {
    [self removeFromSuperview];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        //添加自定义view
        UIView *contentView = [UIView new];
        contentView.backgroundColor = [UIColor lightGrayColor];
        contentView.layer.cornerRadius = 10;
        contentView.layer.masksToBounds = YES;
        self.contentView = contentView;
        [self addSubview:contentView];
        
        //标题控件
        UILabel *titleLabel = [UILabel new];
        self.titleLabel = titleLabel;
        titleLabel.numberOfLines = 0;
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel = titleLabel;
        
        UIImageView *alertImageView = [UIImageView new];
        self.alertImageView = alertImageView;
        alertImageView.hidden = YES;
        
        UIImageView *microphoneView = [UIImageView new];
        microphoneView.image = [UIImage imageNamed:@"ZHRecor.bundle/record_background"];
        self.microphoneView = microphoneView;
        
        UIImageView *signalView = [UIImageView new];
        self.signalView = signalView;
        
        [contentView addSubview:titleLabel];
        [contentView addSubview:alertImageView];
        [contentView addSubview:microphoneView];
        [contentView addSubview:signalView];
        
        //给子控件添加约束
        [self makeConstraintsToSubviews];
    }
    return self;
}

- (void)makeConstraintsToSubviews {
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.height.offset(150);
        make.width.offset(160);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView).offset(50);
        make.centerX.equalTo(self.contentView);
        make.width.offset(180);
    }];
    
    [self.alertImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.centerY.equalTo(self.contentView).offset(-15);
    }];
    
    [self.microphoneView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView).offset(-24);
        make.centerY.equalTo(self.alertImageView);
    }];
    
    [self.signalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView).offset(34);
        make.centerY.equalTo(self.microphoneView);
        make.width.offset(38);
        make.height.offset(100);
    }];
}

- (void)updateMetersValue:(NSInteger)value {
    
    if (value < 1) value = 1;
    if (value > 8) value = 8;
    
    self.status = LSRecordStatusSignalVol;
    
    NSString *fileName = [NSString stringWithFormat:@"ZHRecor.bundle/record_animate_%01ld",value];
    
    self.signalView.image = [UIImage imageNamed:fileName];
}

- (void)setStatus:(LSRecordStatus)status {
    _status = status;
    
    switch (status) {
        case LSRecordStatusShortTime:
        {
            self.titleLabel.text = @"说话时间太短";
            self.alertImageView.hidden = NO;
            self.alertImageView.image = [UIImage imageNamed:@"ZHRecor.bundle/record_shorttime"];
            self.signalView.hidden = YES;
            self.microphoneView.hidden = YES;
        }
            break;
            
        case LSRecordStatusRecocation:
        {
            self.titleLabel.text = @"松开手指,取消发送";
            self.alertImageView.hidden = NO;
            self.alertImageView.image = [UIImage imageNamed:@"ZHRecor.bundle/record_revocation"];
            self.signalView.hidden = YES;
            self.microphoneView.hidden = YES;
        }
            break;

        case LSRecordStatusSignalVol:
        {
            self.alertImageView.hidden = YES;
            self.signalView.hidden = NO;
            self.microphoneView.hidden = NO;
            self.titleLabel.text = @"手指上滑,取消发送";
        }
            break;

        default:
            break;
    }
    
}

@end
