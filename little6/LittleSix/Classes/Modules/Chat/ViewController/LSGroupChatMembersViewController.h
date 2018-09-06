//
//  LSGroupChatMembersViewController.h
//  LittleSix
//
//  Created by GMAR on 2017/6/3.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSGroupModel;
@interface LSGroupChatMembersViewController : UIViewController

@property (strong,nonatomic) NSArray * list;
@property (copy,nonatomic) NSString * userId;
@property (nonatomic, strong)LSGroupModel * gmodel;

@end
