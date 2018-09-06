//
//  UIImage+QRCode.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/24.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QRCode)

//生成制定大小的黑白二维码
+ (UIImage *)createQRImageWithString:(NSString *)string size:(CGSize)size;


+ (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)Imagesize logoImageSize:(CGFloat)waterImagesize;

@end
