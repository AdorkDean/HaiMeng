//
//  LSContactViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/19.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSContactModel;
@interface LSContactViewController : UIViewController

@end

@interface LSContactCell : UITableViewCell

@property (nonatomic,strong) UIImageView *iconView;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *numberLabel;

@property (nonatomic,strong) NSIndexPath *indexPath;

@property (nonatomic,strong) LSContactModel * contactModel;

@end
