//
//  LSEditProfileTableViewController.h
//  LittleSix
//
//  Created by GMAR on 2017/4/14.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSEditProfileTableViewController : UITableViewController

@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSString *s_id;

//宗亲和商会传
@property (nonatomic,copy) NSString * desc;
@property (nonatomic,copy) NSString * address;
@property (nonatomic,copy) NSString * phone;

@end
