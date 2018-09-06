//
//  LSLinkInHeaderView.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/15.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSLinkInHeaderView : UIView

@property (copy, nonatomic) void (^bottomClick)(UIButton *sender);

@property (assign, nonatomic) int type;
@property (retain, nonatomic) UIStackView *stackView;

@property (retain, nonatomic) UIImageView *bgView ;

@end
