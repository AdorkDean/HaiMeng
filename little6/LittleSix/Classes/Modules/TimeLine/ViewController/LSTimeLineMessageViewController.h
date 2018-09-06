//
//  LSTimeLineMessageViewController.h
//  LittleSix
//
//  Created by Jim huang on 17/3/1.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSTimeLineMsgModel;
@interface LSTimeLineMessageViewController : UIViewController

@end

@interface LSTimeLineMsgTableViewCell : UITableViewCell
@property (nonatomic,strong) LSTimeLineMsgModel *model;

@end
