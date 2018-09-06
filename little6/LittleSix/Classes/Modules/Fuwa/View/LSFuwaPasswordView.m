//
//  LSFuwaPasswordView.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/18.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaPasswordView.h"
#import "UIView+HUD.h"

@interface LSFuwaPasswordView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;

@end

@implementation LSFuwaPasswordView

+ (instancetype)showInView:(UIView *)view {
    LSFuwaPasswordView *passwordView =
        [[[NSBundle mainBundle] loadNibNamed:@"LSFuwaComfirmView" owner:nil options:nil] firstObject];

    passwordView.frame = view.bounds;
    [passwordView layoutIfNeeded];

    [passwordView showAnimation];

    [view addSubview:passwordView];

    return passwordView;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    ViewRadius(self.passwordLabel, 3);
    self.passwordLabel.backgroundColor = [UIColor colorWithRGB:0x000000 alpha:0.3];

    NSString *text = [ShareAppManager.loginUser.user_id base64EncodedString];
    self.passwordLabel.text = text;

    self.passwordLabel.textColor = HEXRGB(0xcccccc);
    @weakify(self) UILongPressGestureRecognizer *longGest =
        [[UILongPressGestureRecognizer alloc] initWithActionBlock:^(id _Nonnull sender) {
            @strongify(self) UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = self.passwordLabel.text;
            [self showSucceed:@"复制成功" hideAfterDelay:1.0];
        }];
    self.passwordLabel.userInteractionEnabled = YES;
    [self.passwordLabel addGestureRecognizer:longGest];
}

- (void)showAnimation {
    self.bgView.alpha = 0;
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.bgView.alpha = 0.5;
                     }];
}
- (IBAction)codeAction:(UIButton *)sender {
    self.fuwaUserCodeBlock();

}

- (IBAction)closeButtonAction:(id)sender {
    [self removeFromSuperview];
}

@end
