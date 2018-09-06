//
//  LSFuwaCatchViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/15.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface LSBaseFuwaCamerViewController : UIViewController

@property (nonatomic, strong) UIImageView *cycleView;
@property (nonatomic, strong) UIImageView *rectView;
@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, copy) NSString * screenShots;

//对焦完成的回调
@property (nonatomic, copy) void (^focusCompleteBlock)();

//生成截图
- (void)captureComplete:(void (^)(UIImage *image, NSError *error))block;

@end
