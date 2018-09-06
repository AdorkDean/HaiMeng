//
//  LSContactGroupsViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/20.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSGroupModel;
@interface LSContactGroupsViewController : UIViewController

@end

@interface LSContactGroupsCell : UITableViewCell

@property (nonatomic,retain) UIImageView *iconView;
@property (nonatomic,retain) UILabel *nameLabel;

@property (nonatomic,strong) NSIndexPath *indexPath;

@property (nonatomic,retain) LSGroupModel * groupModel;

@end
