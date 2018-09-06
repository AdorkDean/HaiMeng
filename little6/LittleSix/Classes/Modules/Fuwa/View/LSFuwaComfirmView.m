//
//  LSFuwaSelectedView.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaComfirmView.h"
#import "LSFuwaModel.h"
#import "LSPersonCodeView.h"

@interface LSFuwaComfirmView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;

@end

@implementation LSFuwaComfirmView

+ (instancetype)showInView:(UIView *)view {

    LSFuwaComfirmView *selectedView =
        [[[NSBundle mainBundle] loadNibNamed:@"LSFuwaComfirmView" owner:nil options:nil] lastObject];

    selectedView.frame = view.bounds;
    [selectedView layoutIfNeeded];

    [selectedView showAnimation];

    [view addSubview:selectedView];

    return selectedView;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    self.contentView.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"fuwa_bg"].CGImage);
    self.contentView.layer.contentMode = UIViewContentModeCenter;
    self.contentView.layer.masksToBounds = YES;
    self.saveButton.backgroundColor = HEXRGB(0xd3000f);
    ViewBorderRadius(self.saveButton, 5, 1, HEXRGB(0xff0012));
        ViewBorderRadius(self.codeBtn, 5, 1, HEXRGB(0xff0012));

    UILabel *tipsLabel = [UILabel new];
    tipsLabel.text = @"24小时内未被捕抓，福娃将退回";
    tipsLabel.textColor = HEXRGB(0xcccccc);
    tipsLabel.font = SYSTEMFONT(12);
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:tipsLabel];
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.saveButton.mas_bottom);
        make.bottom.equalTo(self.contentView).offset(-8);
    }];
}

- (void)showAnimation {
    self.bgView.alpha = 0;
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.bgView.alpha = 0.5;
                     }];
}

- (IBAction)codeAction:(id)sender {
    
//    LSUserModel * loginUser = ShareAppManager.loginUser;
//    
//    [[LSPersonCodeView personCodeView]showInView:LSKeyWindow andCodeType:LSCodeTypeFriend UserType:@"uid" andUser_id:loginUser.user_id withAvatar:loginUser.avatar withUser_name:loginUser.user_name withSex:loginUser.sex withDistrict_str:loginUser.district_str enter:1];

    
}

- (IBAction)closeButtonAction:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)comfirmButtonAction:(id)sender {
    !self.comfirmBlock ?: self.comfirmBlock(self);
}

- (void)setModel:(LSFuwaModel *)model {
    _model = model;

    self.titleLabel.text = [NSString stringWithFormat:@"%@号福娃", model.id];
    self.numLabel.text = model.id;
}

@end
