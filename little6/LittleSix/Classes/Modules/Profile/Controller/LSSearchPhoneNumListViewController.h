//
//  LSSearchPhoneNumListViewController.h
//  LittleSix
//
//  Created by Jim huang on 17/3/29.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LSPhoneNumListModel;
@interface LSSearchPhoneNumListViewController : UIViewController

@property (nonatomic,copy) NSString * listStr;

@end

@interface LSSearchPhoneNumListCell : UITableViewCell

@property (nonatomic,copy) LSPhoneNumListModel * model;

@end
