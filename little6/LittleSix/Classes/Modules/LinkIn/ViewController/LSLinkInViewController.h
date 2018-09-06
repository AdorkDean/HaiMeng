//
//  LSLinkInViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/2/13.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSIndexLinkInModel,LSLinkInApplyModel,LSSearchMatchModel;
@interface LSLinkInViewController : UIViewController

@end

@interface LSLinkInCell : UITableViewCell

@property (strong,nonatomic) UIImageView * iconImage;
@property (strong,nonatomic) UILabel * nameLabel;
@property (strong,nonatomic) UILabel * subtitleLabel;
@property (strong,nonatomic) UILabel *imgLabel;

@property (strong,nonatomic) LSIndexLinkInModel * indexModel;

@property (strong,nonatomic) LSLinkInApplyModel * applyModel;

@property (strong,nonatomic) LSSearchMatchModel * searchModel;

@end
