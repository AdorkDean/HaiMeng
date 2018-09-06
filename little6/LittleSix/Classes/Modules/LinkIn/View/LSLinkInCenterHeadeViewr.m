//
//  LSLinkInCenterHeadeViewr.m
//  LittleSix
//
//  Created by GMAR on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSLinkInCenterHeadeViewr.h"

@interface LSLinkInCenterHeadeViewr ()

@end

@implementation LSLinkInCenterHeadeViewr

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        
        UIImageView *bgView = [UIImageView new];
        bgView.image = timeLineBigPlaceholderName;
        [self addSubview:bgView];
        self.headerImage = bgView;
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        UIImageView * headerImage = [UIImageView new];
        headerImage.image = [UIImage imageNamed:@"icon2.jpg"];
        headerImage.layer.cornerRadius = 35;
        headerImage.clipsToBounds = YES;
        self.icomImage = headerImage;
        [self addSubview:headerImage];
        [headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.offset(70);
            make.height.offset(70);
        }];
        
        UILabel * nameLabel = [UILabel new];
        nameLabel.text = @"苏热西";
        self.nameLabel = nameLabel;
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.font = [UIFont systemFontOfSize:15];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.centerX.equalTo(self);
            make.top.equalTo(headerImage.mas_bottom).offset(10);
            make.width.offset(130);
            make.height.offset(20);
        }];
        
        UILabel * suTitleLabel = [UILabel new];
        suTitleLabel.text = @"广州 中山大学";
        self.suTitleLabel = suTitleLabel;
        suTitleLabel.font = [UIFont systemFontOfSize:14];
        suTitleLabel.textColor = [UIColor whiteColor];
        suTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:suTitleLabel];
        [suTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerX.equalTo(self);
            make.top.equalTo(nameLabel.mas_bottom).offset(10);
            make.width.offset(180);
            make.height.offset(20);
        }];
        
        UIButton * userInfo = [UIButton buttonWithType:UIButtonTypeCustom];
        self.nextBtn = userInfo;
        [userInfo setImage:[UIImage imageNamed:@"rightw_arrows"] forState:UIControlStateNormal];
        [userInfo addTarget:self action:@selector(userInfoClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:userInfo];
        [userInfo mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(nameLabel.mas_top).offset(0);
            make.left.equalTo(nameLabel.mas_right).offset(0);
            make.width.offset(20);
            make.height.offset(30);
        }];
        
    }
    
    return self;
}

- (void)setUserId:(NSString *)userId {

    _userId = userId;
    
}

-(void)userInfoClick:(UIButton *)sender{

    if (self.completeClick) {
        self.completeClick();
    }
}


@end
