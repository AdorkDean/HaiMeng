//
//  LSFuwaCatchViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/15.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSBaseFuwaCamerViewController.h"

@class LSFuwaModel;

@interface LSFuwaCatchViewController : LSBaseFuwaCamerViewController

@property (nonatomic, strong) LSFuwaModel *model;

@property (nonatomic, copy) void (^catchSuccessBlock)();

@end
