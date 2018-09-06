//
//  LSEmotionInfoHeaderView.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/28.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSEmotionPackage;
@interface LSEmotionInfoHeaderView : UICollectionReusableView

@property (nonatomic,strong) LSEmotionPackage *package;

+ (instancetype)emotionInfoHeaderView;

- (CGFloat)viewHeight:(LSEmotionPackage *)package;

@end
