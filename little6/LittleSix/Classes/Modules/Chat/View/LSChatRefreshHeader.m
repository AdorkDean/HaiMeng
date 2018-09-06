//
//  LSChatRefreshHeader.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/4/1.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSChatRefreshHeader.h"

@interface LSChatRefreshHeader ()

@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

@end

@implementation LSChatRefreshHeader

- (void)prepare
{
    [super prepare];
    
    // 设置控件的高度
    self.mj_h = 50;
    
    // loading
    UIActivityIndicatorView *indicatorView = [UIActivityIndicatorView new];
    self.indicatorView = indicatorView;
    
    indicatorView.hidesWhenStopped = YES;
    indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [indicatorView startAnimating];
    
    [self addSubview:indicatorView];
    [indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}

- (void)placeSubviews {
    [super placeSubviews];
}

@end
