//
//  LSFuwaPasswordView.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/18.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSFuwaPasswordView : UIView

+ (instancetype)showInView:(UIView *)view;

@property (nonatomic,copy) void(^fuwaUserCodeBlock)();


@end
