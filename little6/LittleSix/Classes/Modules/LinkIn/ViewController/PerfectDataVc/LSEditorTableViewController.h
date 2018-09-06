//
//  LSEditorTableViewController.h
//  LittleSix
//
//  Created by GMAR on 2017/4/15.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSEditorTableViewController : UITableViewController

@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSString *s_id;

@property (nonatomic,copy) NSString *editorType;
@property (nonatomic,copy) NSString * desc;
@property (nonatomic,copy) NSString * address;
@property (nonatomic,copy) NSString * phone;

@property (nonatomic,copy) void (^sureClick)(NSString * string);

@end
