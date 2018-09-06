//
//  LSFuwaMessageViewController.h
//  LittleSix
//
//  Created by Jim huang on 17/3/20.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSFuwaMessageModel;
@interface LSFuwaMessageViewController : UIViewController

@end

@interface LSFuwaMessageCell : UITableViewCell

@property(nonatomic,strong) LSFuwaMessageModel * model;

@end
