//
//  LSSclectSchoolViewController.h
//  LittleSix
//
//  Created by GMAR on 2017/3/30.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSSchoolModels;
@interface LSSclectSchoolViewController : UIViewController

@property (assign,nonatomic) int level;

@property (copy,nonatomic) void (^sureBackSchool) (LSSchoolModels * model);

@end
@interface LSSearchSchoolCells : UITableViewCell

@property (retain,nonatomic)UILabel * nameLabel;
@property (retain,nonatomic)UILabel * sunameLabel;

@property (retain,nonatomic)LSSchoolModels * model;

@end
