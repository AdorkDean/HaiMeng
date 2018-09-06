//
//  LSPersonCodeView.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/18.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSPersonCodeView.h"
#import "UIImage+QRCode.h"

@interface LSPersonCodeView ()

@property (weak, nonatomic) IBOutlet UIButton *bgView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentConstHeight;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *codeImage;

@property (retain,nonatomic)NSString *type;
@property (retain,nonatomic)NSString *user_id;
@property (retain,nonatomic)NSString *avatar;
@property (retain,nonatomic)NSString *user_name;
@property (retain,nonatomic)NSString *sex;
@property (retain,nonatomic)NSString *district_str;
@property (assign,nonatomic)int enter;

@end

@implementation LSPersonCodeView

+ (instancetype)personCodeView {

    return [[[NSBundle mainBundle] loadNibNamed:@"LSPersonCodeView" owner:nil options:nil] lastObject];
    
}


- (void)showInView:(UIView *)view andType:(NSString *)type andUser_id:(NSString *)user_id withAvatar:(NSString *)avatar withUser_name:(NSString *)user_name withSex:(NSString *)sex withDistrict_str:(NSString *)district_str enter:(int)enter{
    
    
    [view addSubview:self];
    self.frame = view.bounds;
    
    self.enter = enter;
    
    self.type = type;
    self.user_id = user_id;
    self.avatar = avatar;
    self.user_name = user_name;
    self.sex = sex;
    self.district_str = district_str;
    
    [self setCodeView:self.type andUserId:self.user_id withAvatar:self.avatar withUser_name:self.user_name withSex:self.sex withDistrict_str:self.district_str];

}

- (void)setCodeView:(NSString *)userType andUserId:(NSString *)user_id withAvatar:(NSString *)avatar withUser_name:(NSString *)user_name withSex:(NSString *)sex withDistrict_str:(NSString *)district_str{

    [self.iconView setImageWithURL:[NSURL URLWithString:avatar] placeholder:timeLineSmallPlaceholderName];
    
    self.nameLabel.text = user_name;
    self.sexLabel.text = sex;
    self.addressLabel.text = district_str;
    
    self.codeImage.image = [UIImage qrImageForString:[NSString stringWithFormat:@"https://api.66boss.com/web/download?%@=%@",userType,user_id] imageSize:300.0 logoImageSize:0.0];//[UIImage createQRImageWithString:[NSString stringWithFormat:@"https://api.66boss.com/web/download?%@=%@",userType,user_id] size:CGSizeMake(300,300)];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    ViewRadius(self.contentView, 5);
    ViewRadius(self.iconView, 4);
    
    CGFloat codeHeight = kScreenWidth - 140;
    self.contentConstHeight.constant = 184 + codeHeight;
    
    [self layoutIfNeeded];
    
    [self showAnimation];
}

- (void)showAnimation {
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.alpha = 0.3;
    }];
}

- (IBAction)bgViewTouchAction:(id)sender {
    
    if (self.enter == 1) {
        
        [self removeFromSuperview];
    }
    
}


@end
