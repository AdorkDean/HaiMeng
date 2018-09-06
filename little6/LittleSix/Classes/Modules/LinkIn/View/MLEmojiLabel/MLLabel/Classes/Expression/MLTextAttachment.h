//
//  MLTextAttachment.h
//  MLLabel
//
//  Created by GMAR on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLTextAttachment : NSTextAttachment

@property (readonly, nonatomic, assign) CGFloat width;
@property (readonly, nonatomic, assign) CGFloat height;

/**
 *  优先级比上面的高，以lineHeight为根据来决定高度
 *  宽度根据imageAspectRatio来定
 */
@property (readonly, nonatomic, assign) CGFloat lineHeightMultiple;

/**
 *  image.size.width/image.size.height
 */
@property (readonly, nonatomic, assign) CGFloat imageAspectRatio;

+ (instancetype)textAttachmentWithWidth:(CGFloat)width height:(CGFloat)height imageBlock:(UIImage * (^)(CGRect imageBounds,NSTextContainer *textContainer,NSUInteger charIndex,MLTextAttachment *textAttachment))imageBlock;

+ (instancetype)textAttachmentWithLineHeightMultiple:(CGFloat)lineHeightMultiple imageBlock:(UIImage * (^)(CGRect imageBounds,NSTextContainer *textContainer,NSUInteger charIndex,MLTextAttachment *textAttachment))imageBlock
                                    imageAspectRatio:(CGFloat)imageAspectRatio;

@end
