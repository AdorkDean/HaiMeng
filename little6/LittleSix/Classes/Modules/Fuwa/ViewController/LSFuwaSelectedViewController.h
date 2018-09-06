//
//  LSFuwaSelectedViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import "LSBaseFuwaModelCell.h"
#import <UIKit/UIKit.h>

@class LSFuwaModel;
@interface LSFuwaSelectedViewController : UIViewController

@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, strong) UIImage *cluesImage;

@property (nonatomic, copy) void (^hiddenCompleteBlock)();

@end

@interface LSFuwaSelectedCell : LSBaseFuwaModelCell

@property (nonatomic, strong) LSFuwaModel *model;

@end
