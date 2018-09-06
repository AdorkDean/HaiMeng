//
//  NSMutableAttributedString+MLLabel.h
//  MLLabel
//
//  Created by GMAR on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableAttributedString (MLLabel)

- (void)removeAllNSOriginalFontAttributes;

- (void)removeAttributes:(NSArray *)names range:(NSRange)range;

@end
