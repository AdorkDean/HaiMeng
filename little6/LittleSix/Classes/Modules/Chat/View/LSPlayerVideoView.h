//
//  LSPlayerVideoView.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/8.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSMessageModel.h"

#define kAnimationDuration 0.25

@interface LSPlayerVideoView : UIView

@property (nonatomic,strong) LSVideoMessageModel *model;

+ (instancetype)playerVideoView;

+ (instancetype)showFromView:(UIView *)view withModel:(LSVideoMessageModel *)model;

+ (instancetype)showFromView:(UIView *)view withCoverImage:(UIImage *)coverImage playURL:(NSURL *)playURL;

@end
