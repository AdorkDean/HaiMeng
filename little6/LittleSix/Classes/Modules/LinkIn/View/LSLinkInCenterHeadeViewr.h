//
//  LSLinkInCenterHeadeViewr.h
//  LittleSix
//
//  Created by GMAR on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSLinkInCenterHeadeViewr : UIView

@property (retain,nonatomic)UIImageView * icomImage;
@property (retain,nonatomic)UIImageView * headerImage;
@property (retain,nonatomic)UILabel * nameLabel;
@property (retain,nonatomic)UILabel * suTitleLabel;
@property (retain,nonatomic)UIButton * nextBtn;

@property (retain,nonatomic)NSString * userId;

@property (copy,nonatomic)void(^completeClick)();

@end
