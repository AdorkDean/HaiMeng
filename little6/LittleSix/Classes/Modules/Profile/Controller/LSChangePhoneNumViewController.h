//
//  LSChangePhoneNumViewController.h
//  LittleSix
//
//  Created by Jim huang on 17/3/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^phoneNumBlock)(NSString *);

@interface LSChangePhoneNumViewController : UIViewController

@property(nonatomic,copy) phoneNumBlock phoneNumBlock;

@end
