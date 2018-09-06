//
//  LSChangeNameViewController.h
//  LittleSix
//
//  Created by GMAR on 2017/3/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSChangeNameViewController : UIViewController

@property (retain,nonatomic)NSString * groupid;

@property (copy,nonatomic)NSString * name;
@property (copy,nonatomic)NSString * notic;

@property (assign,nonatomic)NSInteger type;

@property (copy,nonatomic)void (^sureClick)(NSString * name,NSInteger type);

@end
