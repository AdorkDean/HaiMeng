//
//  LSMyLinkCenterViewController.h
//  LittleSix
//
//  Created by GMAR on 2017/3/6.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSMyLinkCenterViewController : UIViewController

@property (copy,nonatomic) NSString *user_id;

@end


@interface LSLinkInMessageButton : UIButton

@property (nonatomic,strong) UIView *redView;

@property (nonatomic,assign) BOOL hasNewMessage;

@end
