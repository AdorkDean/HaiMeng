//
//  LSFuwaUserCodeView.m
//  LittleSix
//
//  Created by Jim huang on 17/4/19.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSFuwaUserCodeView.h"
#import "QRCodeImage.h"
#import "LSShareView.h"
#import "UIImage+QRCode.h"

@interface LSFuwaUserCodeView ()
@property (weak, nonatomic) IBOutlet UIImageView *codeImageView;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (nonatomic,strong) UIImage * codeIconImage;

@end

@implementation LSFuwaUserCodeView

+ (instancetype)fuwaUserCodeView {
    
    return [[[NSBundle mainBundle] loadNibNamed:@"LSFuwaUserCodeView" owner:nil options:nil]lastObject];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self showAnimation];
}

-(void)showCodeView{
    [LSKeyWindow addSubview:self];
    self.frame = LSKeyWindow.bounds;
    
    NSString * codeStr = [NSString stringWithFormat:@"fuwa:user:%@",[ShareAppManager.loginUser.user_id base64EncodedString]];
    
//    QRCodeImage *qrCodeImage = [QRCodeImage codeImageWithString:codeStr size:self.codeImageView.width color:HEXRGB(0x000000) icon:[UIImage imageNamed:@"fuwaerweima"] iconWidth:25];
    
//    [self.codeImageView setImage:qrCodeImage];
    
    
    UIImage * codeImage = [UIImage createQRImageWithString:codeStr size:CGSizeMake(500, 500)];
    
    UIImage * iconImage = [UIImage imageNamed:@"fuwaerweima"];
    self.codeIconImage = [self addImage:iconImage toImage:codeImage];
    self.codeImageView.image = self.codeIconImage;
}


-(UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2
{
    UIGraphicsBeginImageContext(image2.size);
    
    //Draw image2
    [image2 drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
    
    //Draw image1
    [image1 drawInRect:CGRectMake((image2.size.width-50)/2, (image2.size.height-50)/2, 50, 50)];
    
    UIImage *resultImage=UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultImage;
}
- (void)showAnimation {
    self.alpha = 0;
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1;
    }];
}


- (IBAction)bgBtnAction:(id)sender {
    [self removeFromSuperview];
}

- (IBAction)closeBtnAction:(id)sender {
    [self removeFromSuperview];

}

- (IBAction)shareBtnAction:(id)sender {
    
    //分享的参数
    NSMutableDictionary *shareParam = [NSMutableDictionary dictionary];
    [shareParam SSDKSetupShareParamsByText:nil images:self.codeIconImage url:nil title:@"嗨萌寻宝分享" type:SSDKContentTypeImage];
    
    [LSShareView showInView:LSKeyWindow withItems:[LSShareView shareItems] actionBlock:^(SSDKPlatformType type) {
        //分享出去
        [LSShareView shareTo:type withParams:shareParam onStateChanged:nil];
    }];
    
}

@end
