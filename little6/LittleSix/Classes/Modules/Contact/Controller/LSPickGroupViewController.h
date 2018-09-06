//
//  LSPickGroupViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/18.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSMessageModel.h"

@class LSGroupModel;
@interface LSPickGroupViewController : UIViewController

@property (nonatomic,strong) LSMessageModel *message;

@end

@interface LSPickGroupCell : UITableViewCell

@property (retain,nonatomic)LSGroupModel * model;

@end
