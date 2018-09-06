//
//  LSSchoolViewController.h
//  LittleSix
//
//  Created by GMAR on 2017/3/3.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSLSLinkInModel;
@interface LSSchoolViewController : UIViewController

@property (copy,nonatomic) void (^fristClick)(NSString * schoolName);

@end

@interface LSSchoolTableCell : UITableViewCell

@property (retain,nonatomic)UILabel * nameLabel;
@property (retain,nonatomic)UILabel * schoolLabel;
@property (retain,nonatomic)UILabel * departmentsLabel;
@property (retain,nonatomic)UILabel * timeLabel;

@property (retain,nonatomic)LSLSLinkInModel * linkModel;

@end
