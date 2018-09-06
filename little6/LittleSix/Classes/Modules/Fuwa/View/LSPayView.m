//
//  LSWechatAndZFBBuyView.m
//  LittleSix
//
//  Created by Jim huang on 17/3/23.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSPayView.h"

@interface LSPayView()

@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewConstH;

@property (weak, nonatomic) IBOutlet UIButton *wechatCheckButton;
@property (weak, nonatomic) IBOutlet UIButton *alipayCheckButton;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (assign,nonatomic) LSPayType type;

@end

@implementation LSPayView

+ (instancetype)showInView:(UIView *)view price:(NSString *)price withPayBlock:(void (^)(LSPayType type))block {
    
    LSPayView *payView = [[[NSBundle mainBundle] loadNibNamed:@"LSPayView" owner:nil options:nil] lastObject];
    
    payView.payBlock = block;
    payView.priceLabel.text = price;
    
    payView.frame = view.bounds;
    [view addSubview:payView];
    
    [payView showAnimation];
    
    return payView;
}

- (void)showAnimation {
    [self layoutIfNeeded];
    
    self.bgView.alpha = 0;
    
    self.contentView.transform = CGAffineTransformMakeTranslation(0, self.contentViewConstH.constant);
    
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.alpha = 0.25;
        self.contentView.transform = CGAffineTransformIdentity;
    }];
}

- (void)dismissAnimation {
    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.transform = CGAffineTransformMakeTranslation(0, self.contentViewConstH.constant);
        self.bgView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissAnimation];
}

- (IBAction)closeButtonAction:(id)sender {
    [self dismissAnimation];
}

- (IBAction)alipayButtonAction:(id)sender {
    self.type = LSPayTypeAlipay;
    self.wechatCheckButton.selected = NO;
    self.alipayCheckButton.selected = YES;
}

- (IBAction)wechatButtonAction:(id)sender {
    self.type = LSPayTypeWechat;
    self.wechatCheckButton.selected = YES;
    self.alipayCheckButton.selected = NO;
}

- (IBAction)comfirmPayAction:(id)sender {
    
    !self.payBlock?:self.payBlock(self.type);
    
    [self dismissAnimation];
}

@end
