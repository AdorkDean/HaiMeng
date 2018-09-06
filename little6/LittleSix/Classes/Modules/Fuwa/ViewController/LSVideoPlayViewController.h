//
//  LSVideoPlayViewController.h
//  LittleSix
//
//  Created by ZhiHua Shen on 2017/6/2.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSRecomendViewController.h"

@class LSRecomendModel;
@interface LSVideoPlayViewController : UIViewController

@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) LSRecomendModel *videoModel;
@property (nonatomic,copy) NSString *classId;

@property (nonatomic,assign) LSRecomendType type;

@end
