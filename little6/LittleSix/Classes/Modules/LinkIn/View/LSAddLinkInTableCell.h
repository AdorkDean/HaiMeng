//
//  LSAddLinkInTableCell.h
//  LittleSix
//
//  Created by GMAR on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSSearchMatchModel;
@interface LSAddLinkInTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *icomImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;

@property (weak, nonatomic) IBOutlet UIButton *addButton;

@property (retain,nonatomic)LSSearchMatchModel * searchModel;

@property (copy,nonatomic) void (^addFriendsClick)(LSSearchMatchModel * model);

@end
