//
//  LSMenuDetailButton.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/4/22.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSMenuDetailButton.h"
#import "LSMessageManager.h"

@implementation LSMenuDetailButton

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self setImage:[UIImage imageNamed:@"navi_menu"] forState:UIControlStateNormal];
        [self sizeToFit];
        
        UIView *redView = [UIView new];
        self.redView = redView;
        redView.backgroundColor = HEXRGB(0xd42136);
        [self addSubview:redView];
        [redView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_right).offset(2);
            make.centerY.equalTo(self.mas_top).offset(4);
            make.width.height.offset(10);
        }];
        ViewBorderRadius(redView, 5, 0.5, [UIColor whiteColor]);
        
        [self registNotification];
        
        [self setMessageUnReadCount];
    }
    return self;
}

- (void)registNotification {
    
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:kMessageUnReadCountDidChange object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        kDISPATCH_MAIN_THREAD(^{
            [self setMessageUnReadCount];
        })
    }];
}

- (void)setMessageUnReadCount {
    //设置未读消息
    NSInteger unReadCount = [LSMessageManager totalUnReadCount];
    self.redView.hidden = !(unReadCount>0);
}

@end
