//
//  NSString+Util.m
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/14.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "NSString+Util.h"

@implementation NSString (Util)

- (NSDictionary *)toDictionary {
    
    if (self == nil || self.length == 0) return nil;
    
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    
    if (err) return nil;
    
    return dic;
}

- (NSString *)base64EncodedString {
    
    NSData *nsdata = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
    
    return base64Encoded;
}

- (NSString *)base64DecodedString {
    
    NSData *base64Data = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    NSString *decodedString = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    
    return decodedString;
}

#pragma mark - 动态高度
+ (CGSize)countingSize:(NSString *)str fontSize:(int)fontSize width:(float)width{
    
    // 高度估计文本大概要显示几行，宽度根据需求自己定义。 MAXFLOAT 可以算出具体要多高
    // label 可设置的最大高度和宽度
    CGSize size = CGSizeMake(width, MAXFLOAT);
    // 获取当前文本的属性
    NSDictionary *tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:fontSize],NSFontAttributeName,nil];
    
    CGSize actualsize = [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
    
    return actualsize;
}

#pragma mark - 动态宽度
+ (CGSize)countingSize:(NSString *)str fontSize:(int)fontSize height:(float)height{
    
    // label 可设置的最大高度和宽度
    CGSize size = CGSizeMake(MAXFLOAT, height);
    // 获取当前文本的属性
    NSDictionary *tdic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:fontSize],NSFontAttributeName,nil];
    
    CGSize actualsize = [str boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
    
    return actualsize;
}

@end
