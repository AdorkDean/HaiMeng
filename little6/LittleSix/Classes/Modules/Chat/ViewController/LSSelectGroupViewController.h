//
//  LSSelectGroupViewController.h
//  LittleSix
//
//  Created by GMAR on 2017/4/19.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSMembersModel;
@interface LSSelectGroupViewController : UIViewController

@property (copy,nonatomic)NSString * groupid;
@property (copy,nonatomic)NSArray * listArr;
@property (assign,nonatomic)int index;


@end

@interface LSSelectGroupCell : UITableViewCell

@property (retain,nonatomic)UIButton * selectBtn;
@property (retain,nonatomic)UIImageView * iconImage;
@property (retain,nonatomic)UILabel * nameLabel;
@property (nonatomic,assign,getter=isCellSelected) BOOL cellSelected;

@property (retain,nonatomic)LSMembersModel * membersModel;

@end
