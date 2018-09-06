//
//  LSAddPhoneContactViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/19.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSMatchingModel;
@interface LSAddPhoneContactViewController : UIViewController

@end

@interface LSMatchingCell : UITableViewCell

@property (retain,nonatomic) UIImageView *iconView;
@property (retain,nonatomic) UIButton *statusButton;
@property (retain,nonatomic) UILabel *nameLabel;
@property (retain,nonatomic) UILabel *descLabel;

@property (copy,nonatomic)void (^dealWithClick)(LSMatchingModel *model);

@property (retain,nonatomic)LSMatchingModel * matchingModel;

@end
