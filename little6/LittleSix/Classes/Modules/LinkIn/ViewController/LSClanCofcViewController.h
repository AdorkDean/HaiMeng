//
//  LSClanCofcViewController.h
//  LittleSix
//
//  Created by GMAR on 2017/4/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSClanCofcViewController : UIViewController

@property (assign,nonatomic)int sh_id;
@property (assign,nonatomic)int type;

@property (retain,nonatomic)NSString * titleStr;

@property (copy,nonatomic)NSString * isFuwa;

@end

@interface LSClanCofcHeaderView : UIView

@property (copy, nonatomic) void (^setCoverClick)();
@property (copy, nonatomic) void (^bottomClick)(UIButton *sender);

@property (copy, nonatomic) void (^setFocusClick)(UIButton * sender);

@property (assign, nonatomic) int type;
@property (strong, nonatomic) UIStackView *stackView;

@property (strong, nonatomic) UIImageView *bgView ;
@property (strong, nonatomic) UIButton * fouceBtn ;
@property (strong, nonatomic) UILabel * focusLabel;

@end
