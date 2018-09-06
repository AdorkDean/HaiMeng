//
//  LSEditEmotionViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/10.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSMyEmotionViewController.h"

@class LSEmotionModel;
@interface LSEditEmotionViewController : UIViewController

@property (nonatomic,strong) LSEmotionModel *model;

@property (nonatomic,copy) void(^completeBlock)(LSEmotionOperation operation,UIImage *image);

@end
