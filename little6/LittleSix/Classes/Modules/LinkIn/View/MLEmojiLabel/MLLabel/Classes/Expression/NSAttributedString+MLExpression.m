//
//  NSAttributedString+MLExpression.m
//  Pods
//
//  Created by GMAR on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//
//

#import "NSAttributedString+MLExpression.h"

@implementation NSAttributedString (MLExpression)


- (NSAttributedString*)expressionAttributedStringWithExpression:(MLExpression*)expression
{
    return [MLExpressionManager expressionAttributedStringWithString:self expression:expression];
}

@end
