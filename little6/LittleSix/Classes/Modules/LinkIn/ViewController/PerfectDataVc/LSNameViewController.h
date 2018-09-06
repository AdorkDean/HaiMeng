//
//  LSNameViewController.h
//  LittleSix
//
//  Created by GMAR on 2017/3/3.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSNameViewController : UIViewController

@property (copy,nonatomic) void (^saveClick)(NSString * name);
@property (retain,nonatomic)NSString *name;

@end
