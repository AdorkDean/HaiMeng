//
//  LSFuwaApplyView.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/4/4.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaApplyView.h"

@interface LSFuwaApplyView ()

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@end

@implementation LSFuwaApplyView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"fuwa_obg"].CGImage);
    self.contentView.layer.contentMode = UIViewContentModeBottom;
    ViewBorderRadius(self.cancelButton, 5, 1, HEXRGB(0xff0000));
    ViewBorderRadius(self.doneButton, 5, 1, HEXRGB(0xff0000));
    ViewRadius(self.contentView, 3);
}

+ (instancetype)applyView {
    LSFuwaApplyView *view = [[NSBundle mainBundle] loadNibNamed:@"LSFuwaComfirmView" owner:nil options:nil][2];
    return view;
}

+ (instancetype)showInView:(UIView *)view doneAction:(void (^)(void))doneBlock cancelBlock:(void (^)(void))cancelBlock {
    
    LSFuwaApplyView *applyView = [LSFuwaApplyView applyView];
    
    [view addSubview:applyView];
    applyView.frame = view.bounds;
    
    applyView.doneBlock = doneBlock;
    applyView.cancelBlock = cancelBlock;
    
    return applyView;
}

- (IBAction)cancelAction:(id)sender {
    
    !self.cancelBlock ? : self.cancelBlock();
    
    [self removeFromSuperview];
}

- (IBAction)doneAction:(id)sender {
    
    !self.doneBlock ? : self.doneBlock();
    
    [self removeFromSuperview];
}


@end
