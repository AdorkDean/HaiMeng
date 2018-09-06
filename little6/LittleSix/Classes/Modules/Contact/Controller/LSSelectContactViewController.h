//
//  LSSelectContactViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/17.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSMessageModel.h"

@class LSContactModel;
@interface LSSelectContactViewController : UIViewController

@property (copy,nonatomic)NSString * groupid;

@property (assign,nonatomic)int type;

//转发
@property (nonatomic,strong) LSMessageModel *message;

@end

@interface LSSelectContactCell : UITableViewCell

@property (retain,nonatomic)LSContactModel * model;

@property (retain,nonatomic)UIButton * selectBtn;
@property (retain,nonatomic)UIImageView * iconImage;
@property (retain,nonatomic)UILabel * nameLabel;
@property (nonatomic,assign,getter=isCellSelected) BOOL cellSelected;

-(void)selectClick:(LSContactModel *)model;

@end

@interface LSSelectContactNormalCell : UITableViewCell

@end
