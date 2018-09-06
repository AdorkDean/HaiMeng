//
//  MLLabel+Override.h
//  MLLabel
//
//  Created by GMAR on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "MLLabel.h"

@class MLLabelLayoutManager;
@interface MLLabel (Override)

@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, strong) MLLabelLayoutManager *layoutManager;
@property (nonatomic, strong) NSTextContainer *textContainer;

@property (nonatomic, strong) NSAttributedString *lastAttributedText;
@property (nonatomic, assign) MLLastTextType lastTextType;

//初始化
- (void)commonInit;

//复写这个可以最终文本改变
- (NSMutableAttributedString*)attributedTextForTextStorageFromLabelProperties;

//获取绘制起点
- (CGPoint)textOffsetWithTextSize:(CGSize)textSize;

//可以完全重绘当前label
- (void)reSetText;

@end
