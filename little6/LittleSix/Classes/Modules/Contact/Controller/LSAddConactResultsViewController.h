//
//  LSAddConactResultsViewController.h
//  LittleSix
//
//  Created by GMAR on 2017/3/10.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSContactModel;
@interface LSAddConactResultsViewController : UIViewController

@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) NSArray *searchResults;

@property (copy,nonatomic)void (^indexClick)(LSContactModel * model);

@end


