//
//  LSPeopleNearbyViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/20.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSPersonsModel;
@interface LSPeopleNearbyViewController : UIViewController

@end

@interface LSPeopleNearbyCell : UITableViewCell

@property (retain,nonatomic) UIImageView *iconView;
@property (retain,nonatomic) YYLabel *detailLabel;
@property (retain,nonatomic) UILabel *nameLabel;
@property (retain,nonatomic) UILabel *distanceLabel;
@property (nonatomic,strong) UIImageView * sexImageView;

@property (retain,nonatomic) LSPersonsModel * personsModel;

@end
