//
//  NSString+Util.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/14.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Util)

/// 字符串转字典
- (NSDictionary *)toDictionary;
/// base64编码
- (NSString *)base64EncodedString;
/// base64解码
- (NSString *)base64DecodedString;

// 动态高度
+ (CGSize)countingSize:(NSString *)str fontSize:(int)fontSize width:(float)width;
// 动态宽度
+ (CGSize)countingSize:(NSString *)str fontSize:(int)fontSize height:(float)height;

@end
