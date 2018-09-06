//
//  UIImage+LSCompression.m
//  LittleSix
//
//  Created by Jim huang on 17/4/1.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "UIImage+LSCompression.h"

@implementation UIImage (LSCompression)

+(NSData *)compressionImage:(UIImage *)image {
    
    if (!image) {
        return nil;
    }
    

    NSData * AllImageData = UIImageJPEGRepresentation(image, 1);
    int maxDataLength = 2 * 1024 * 1024;
    NSData *imageData;
    
    if (AllImageData.length<maxDataLength) {
        return  AllImageData;
    }else{
        CGFloat compression = 0.95f;
        CGFloat maxCompression = 0.1f;
        imageData = UIImageJPEGRepresentation(image, compression);
        while ([imageData length] > maxDataLength && compression > maxCompression) {
            compression -= 0.05;
            imageData = UIImageJPEGRepresentation(image, compression);
        }
        
        return imageData;
    }

    
    
    
}

@end
