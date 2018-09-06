//
//  LSNewFriendsViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/19.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSNewFriendstModel;
@interface LSNewFriendsViewController : UITableViewController

@end

@interface LSNewFriendCell : UITableViewCell

@property (retain,nonatomic) UIImageView *iconView;
@property (retain,nonatomic) UIButton *statusButton;
@property (retain,nonatomic) UILabel *nameLabel;
@property (retain,nonatomic) UILabel *descLabel;

@property (copy,nonatomic)void (^dealWithClick)(LSNewFriendstModel *model);

@property (retain,nonatomic)LSNewFriendstModel * newfriendsModel;

@end
