//
//  LSWebViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/1/20.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSWebViewController : UIViewController

@property (nonatomic,copy) NSString *urlString;
@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSString *localHtmlPath;
@property (nonatomic,copy) NSString *s_id;

@property (nonatomic,copy) NSString *user_id;

//宗亲和商会传
@property (nonatomic,copy) NSString * desc;
@property (nonatomic,copy) NSString * address;
@property (nonatomic,copy) NSString * phone;

@end
