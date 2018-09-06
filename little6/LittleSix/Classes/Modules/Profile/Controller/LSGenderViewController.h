//
//  LSGenderViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^changeSexBlock)(int);

@interface LSGenderViewController : UITableViewController

@property (nonatomic ,copy) changeSexBlock changeSex;
@property (assign,nonatomic) NSString * sex;


@end
