//
//  LSSearchGResultsViewController.h
//  LittleSix
//
//  Created by GMAR on 2017/3/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSGroupModel;
@interface LSSearchGResultsViewController : UIViewController
@property (retain, nonatomic) UITableView * tableView;
@property (retain, nonatomic) NSArray * searchResults;
@property (copy, nonatomic) void (^indexClick)(LSGroupModel * model);
@end
