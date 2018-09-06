//
//  LSFuwaApplyView.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/4/4.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSFuwaApplyView : UIView

@property (nonatomic,copy) void(^cancelBlock)();
@property (nonatomic,copy) void(^doneBlock)();

+ (instancetype)showInView:(UIView *)view doneAction:(void(^)(void))doneBlock cancelBlock:(void(^)(void))cancelBlock;

@end
