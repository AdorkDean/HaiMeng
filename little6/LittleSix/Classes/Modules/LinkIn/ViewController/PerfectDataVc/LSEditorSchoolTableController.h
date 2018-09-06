//
//  LSEditorSchoolTableController.h
//  LittleSix
//
//  Created by GMAR on 2017/3/30.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSLSLinkInModel;
@interface LSEditorSchoolTableController : UITableViewController

@property (assign,nonatomic) int level;
@property (assign,nonatomic) LSLSLinkInModel * linkModel;

@end
