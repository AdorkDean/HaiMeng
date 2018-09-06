//
//  NSString+MLExpression.h
//  Pods
//
//  Created by GMAR on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "MLExpressionManager.h"

@interface NSString (MLExpression)

- (NSAttributedString*)expressionAttributedStringWithExpression:(MLExpression*)expression;

@end
