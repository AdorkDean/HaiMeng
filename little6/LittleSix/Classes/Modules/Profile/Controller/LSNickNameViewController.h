//
//  LSNickNameViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/21.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^changeNameBlock)(NSString*);


@interface LSNickNameViewController : UITableViewController

@property (nonatomic ,copy) changeNameBlock changeNameBlock;

@end
