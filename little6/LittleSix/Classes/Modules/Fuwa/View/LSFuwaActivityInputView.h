//
//  LSFuwaActivityInputView.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/4/5.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSAnimationView.h"
#import "LSFuwaHiddenViewController.h"
@class LSCaptureModel;
@interface LSFuwaActivityInputView : LSAnimationView

@property (nonatomic,strong)LSCaptureModel *model;
@property (nonatomic,assign)fuwaHiddenCountType hiddenType;

@property (nonatomic,copy) void(^selectVideoBlock)();

@property (nonatomic,copy) void(^recordVideoBlock)();

@property (nonatomic,copy) void(^doneBlock)(NSString *detailString,LSCaptureModel * model,NSString * day,NSString * fuwaType);
@property (nonatomic,copy) void(^skipBlock)(NSString *day);

+ (instancetype)showInView:(UIView *)view hiddenType:(fuwaHiddenCountType)hiddenType doneAction:(void(^)(NSString *detailString,LSCaptureModel * model,NSString * day,NSString * fuwaType))doneblock skipAction:(void(^)(NSString *day))skipblock selectVideo:(void(^)(void))selectVideo recordVideo:(void(^)(void))recordVideo;

@end
