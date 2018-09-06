//
//  LSCelebrityTableViewController.h
//  LittleSix
//
//  Created by GMAR on 2017/4/18.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSCelebrityModel;
@interface LSCelebrityTableViewController : UITableViewController

@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSString *s_id;

@property (nonatomic,strong) LSCelebrityModel * model;

@end
