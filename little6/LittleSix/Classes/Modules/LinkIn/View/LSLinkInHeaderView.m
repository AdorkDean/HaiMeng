//
//  LSLinkInHeaderView.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/15.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSLinkInHeaderView.h"

@interface LSLinkInHeaderView ()

@end

@implementation LSLinkInHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        UIImageView *bgView = [UIImageView new];
        bgView.image = [UIImage imageNamed:@"pic5.jpg"];
        self.bgView = bgView;
        [self addSubview:bgView];
        
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.offset(220);
        }];
        
        UIView * transparent = [UIView new];
        transparent.alpha = 0.3;
        transparent.backgroundColor = [UIColor blackColor];
        [self addSubview:transparent];
        [transparent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self);
            make.height.offset(44);
        }];
        
        UIStackView *stackView = [UIStackView new];
        self.stackView = stackView;
        [self addSubview:stackView];
        stackView.distribution = UIStackViewDistributionFillEqually;
        [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self);
            make.height.offset(44);
        }];

    }
    
    return self;
}

-(void)menusButtonAction:(UIButton *)sender{

    if (self.bottomClick) {
        self.bottomClick(sender);
    }
}

-(void)setType:(int)type{

    _type = type;
    
    NSString * title = _type == 1?@"社团":@"商会";
    NSArray *menus = @[@"简介",@"名人",title,@"动态"];
    
    for (int i = 0; i<menus.count; i++) {
        
        NSString *title = menus[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:title forState:UIControlStateNormal];
        button.titleLabel.font = SYSTEMFONT(16);
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.tag = 1000+i;
        [self.stackView addArrangedSubview:button];
        [button addTarget:self action:@selector(menusButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}


@end
