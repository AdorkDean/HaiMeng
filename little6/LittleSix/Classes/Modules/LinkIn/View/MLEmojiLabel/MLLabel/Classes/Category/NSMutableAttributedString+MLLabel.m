//
//  NSMutableAttributedString+MLLabel.m
//  MLLabel
//
//  Created by GMAR on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "NSMutableAttributedString+MLLabel.h"

@implementation NSMutableAttributedString (MLLabel)

- (void)removeAllNSOriginalFontAttributes
{
    [self enumerateAttribute:@"NSOriginalFont" inRange:NSMakeRange(0, self.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        if (value){
            [self removeAttribute:@"NSOriginalFont" range:range];
        }
    }];
}


- (void)removeAttributes:(NSArray *)names range:(NSRange)range
{
    for (NSString *name in names) {
        [self removeAttribute:name range:range];
    }
}
@end
