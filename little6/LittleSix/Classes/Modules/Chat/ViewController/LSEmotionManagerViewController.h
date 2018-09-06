//
//  LSEmotionManagerViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/3/29.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSEmotionPackage;
@interface LSEmotionManagerViewController : UIViewController

@end

@interface LSEmotionManagerCell : UITableViewCell

@property (nonatomic,strong) LSEmotionPackage *package;

@property (nonatomic,strong) UIImageView *iconView;
@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UIButton *removeButton;

@end

@interface LSEmotionNormalCell : UITableViewCell

@end
