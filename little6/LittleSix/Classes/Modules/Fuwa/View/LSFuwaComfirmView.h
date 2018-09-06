//
//  LSFuwaSelectedView.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSFuwaModel;
@interface LSFuwaComfirmView : UIView

+ (instancetype)showInView:(UIView *)view;

@property (nonatomic,strong) LSFuwaModel *model;

@property (nonatomic,copy) void(^comfirmBlock)(LSFuwaComfirmView *view);

@end
