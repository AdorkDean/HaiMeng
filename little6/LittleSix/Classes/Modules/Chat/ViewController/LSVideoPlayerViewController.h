//
//  LSVideoPlayerViewController.h
//  LittleSix
//
//  Created by GMAR on 2017/6/24.
//  Copyright © 2017年 ZhiHua Shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSRecomendViewController.h"

@interface LSVideoPlayerViewController : UIViewController

//
@property (nonatomic,copy) NSURL * playURL;
@property (nonatomic,copy) UIImage * coverImage;
@property (nonatomic,copy) NSString * coverURL;

@end
